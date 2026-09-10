import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/number_update/number_update_provider.dart';
import '../../../../core/utils/uuid.dart';
import '../../domain/entities/catalog_company_admin.dart';

class AdminCompanyCatalogState extends Equatable {
  final List<CatalogCompanyAdmin> companies;
  final bool isLoading;
  final String? errorMessage;

  const AdminCompanyCatalogState({required this.companies, this.isLoading = false, this.errorMessage});

  AdminCompanyCatalogState copyWith({List<CatalogCompanyAdmin>? companies, bool? isLoading, String? errorMessage}) {
    return AdminCompanyCatalogState(
      companies: companies ?? this.companies,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [companies, isLoading, errorMessage];
}

/// Admin → Company Catalog: full CRUD directly against Supabase's
/// `company_catalog`/`package_catalog` — no Drift/offline-first here on
/// purpose (see design/APP_CONTEXT.md: Admin screens are built directly
/// against real data, skipping the mock-first/offline-first treatment
/// every seller-facing feature gets, since managing the shared catalog
/// only ever makes sense while online as an admin). Every seller's own
/// device picks up these changes on its next `SyncEngine.pullCatalog()`.
class AdminCompanyCatalogCubit extends Cubit<AdminCompanyCatalogState> {
  final SupabaseClient _client;

  AdminCompanyCatalogCubit({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client,
      super(const AdminCompanyCatalogState(companies: [], isLoading: true)) {
    load();
  }

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final companyRows = await _client.from('company_catalog').select().order('name');
      final packageRows = await _client.from('package_catalog').select();

      final companies = companyRows.map((c) {
        final packages = packageRows
            .where((p) => p['company_catalog_id'] == c['id'])
            .map((p) => CatalogPackageAdmin(
                  id: p['id'] as String,
                  name: p['name'] as String,
                  simType: p['sim_type'] as String?,
                  wholesaleCost: (p['wholesale_cost'] as num).toDouble(),
                  suggestedRetailPrice: (p['suggested_retail_price'] as num).toDouble(),
                ))
            .toList();
        return CatalogCompanyAdmin(
          id: c['id'] as String,
          name: c['name'] as String,
          notes: (c['notes'] as String?) ?? '',
          numberUpdateUrl: (c['number_update_url'] as String?) ?? '',
          numberUpdateProvider: numberUpdateProviderFromRow(c['number_update_provider'] as String?),
          logoUrl: c['logo_url'] as String?,
          status: c['status'] == 'archived' ? CatalogStatus.archived : CatalogStatus.active,
          packages: packages,
        );
      }).toList();

      emit(state.copyWith(companies: companies, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: 'common.genericError'));
    }
  }

  Future<void> addCompany({
    required String name,
    required String notes,
    required String numberUpdateUrl,
    NumberUpdateProviderKey? numberUpdateProvider,
    String? logoLocalPath,
    required List<CatalogPackageAdmin> packages,
  }) async {
    final id = generateUuidV4();
    final now = DateTime.now().toIso8601String();
    final createdBy = _client.auth.currentUser?.id;
    final logoUrl = logoLocalPath == null ? null : await _uploadLogo(id, logoLocalPath);

    await _client.from('company_catalog').insert({
      'id': id,
      'name': name,
      'notes': notes.isEmpty ? null : notes,
      'number_update_url': numberUpdateUrl.isEmpty ? null : numberUpdateUrl,
      'number_update_provider': numberUpdateProvider == null ? null : numberUpdateProviderToRow(numberUpdateProvider),
      'logo_url': logoUrl,
      'created_by': createdBy,
      'created_at': now,
      'updated_at': now,
    });
    if (packages.isNotEmpty) {
      await _client.from('package_catalog').insert(packages
          .map((p) => {
                'id': generateUuidV4(),
                'company_catalog_id': id,
                'name': p.name,
                'sim_type': p.simType,
                'wholesale_cost': p.wholesaleCost,
                'suggested_retail_price': p.suggestedRetailPrice,
                'created_at': now,
                'updated_at': now,
              })
          .toList());
    }
    await load();
  }

  Future<void> updateCompany(
    String id, {
    required String name,
    required String notes,
    required String numberUpdateUrl,
    NumberUpdateProviderKey? numberUpdateProvider,
    String? logoLocalPath,
    bool removeLogo = false,
    required List<CatalogPackageAdmin> packages,
  }) async {
    final now = DateTime.now().toIso8601String();
    final update = <String, dynamic>{
      'name': name,
      'notes': notes.isEmpty ? null : notes,
      'number_update_url': numberUpdateUrl.isEmpty ? null : numberUpdateUrl,
      'number_update_provider': numberUpdateProvider == null ? null : numberUpdateProviderToRow(numberUpdateProvider),
      'updated_at': now,
    };
    if (logoLocalPath != null) {
      update['logo_url'] = await _uploadLogo(id, logoLocalPath);
    } else if (removeLogo) {
      update['logo_url'] = null;
    }
    await _client.from('company_catalog').update(update).eq('id', id);

    // Packages have no stable identity worth diffing (same reasoning as
    // the seller-facing CompanyFormSheet) — replace wholesale.
    await _client.from('package_catalog').delete().eq('company_catalog_id', id);
    if (packages.isNotEmpty) {
      await _client.from('package_catalog').insert(packages
          .map((p) => {
                'id': generateUuidV4(),
                'company_catalog_id': id,
                'name': p.name,
                'sim_type': p.simType,
                'wholesale_cost': p.wholesaleCost,
                'suggested_retail_price': p.suggestedRetailPrice,
                'created_at': now,
                'updated_at': now,
              })
          .toList());
    }
    await load();
  }

  /// Uploads a catalog company's logo to the public `company-logos`
  /// bucket's shared `catalog/` folder (see
  /// `supabase/migrations/0007_company_logos_storage.sql`'s admin-only
  /// RLS policy for that folder) and returns its public URL. Returns
  /// null and swallows the error on failure — a logo that fails to
  /// upload just leaves the catalog entry without one for now.
  Future<String?> _uploadLogo(String catalogCompanyId, String localPath) async {
    try {
      final ext = localPath.contains('.') ? localPath.split('.').last : 'jpg';
      final objectPath = 'catalog/$catalogCompanyId.$ext';
      final bytes = await File(localPath).readAsBytes();
      await _client.storage.from('company-logos').uploadBinary(objectPath, bytes, fileOptions: const FileOptions(upsert: true));
      return _client.storage.from('company-logos').getPublicUrl(objectPath);
    } catch (_) {
      return null;
    }
  }

  Future<void> setStatus(String id, CatalogStatus status) async {
    await _client.from('company_catalog').update({
      'status': status == CatalogStatus.archived ? 'archived' : 'active',
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
    await load();
  }
}
