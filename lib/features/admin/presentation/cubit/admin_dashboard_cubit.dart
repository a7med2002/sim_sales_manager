import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/admin_user.dart';

class AdminDashboardState extends Equatable {
  final int totalSellers;
  final int activeSellers;
  final int totalAdmins;
  final int catalogCompaniesActive;
  final int catalogCompaniesArchived;
  final int catalogPackages;
  final int totalSupportRequests;
  final List<AdminUser> recentSignups;
  final bool isLoading;
  final String? errorMessage;

  const AdminDashboardState({
    this.totalSellers = 0,
    this.activeSellers = 0,
    this.totalAdmins = 0,
    this.catalogCompaniesActive = 0,
    this.catalogCompaniesArchived = 0,
    this.catalogPackages = 0,
    this.totalSupportRequests = 0,
    this.recentSignups = const [],
    this.isLoading = true,
    this.errorMessage,
  });

  int get inactiveSellers => totalSellers - activeSellers;

  AdminDashboardState copyWith({
    int? totalSellers,
    int? activeSellers,
    int? totalAdmins,
    int? catalogCompaniesActive,
    int? catalogCompaniesArchived,
    int? catalogPackages,
    int? totalSupportRequests,
    List<AdminUser>? recentSignups,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AdminDashboardState(
      totalSellers: totalSellers ?? this.totalSellers,
      activeSellers: activeSellers ?? this.activeSellers,
      totalAdmins: totalAdmins ?? this.totalAdmins,
      catalogCompaniesActive: catalogCompaniesActive ?? this.catalogCompaniesActive,
      catalogCompaniesArchived: catalogCompaniesArchived ?? this.catalogCompaniesArchived,
      catalogPackages: catalogPackages ?? this.catalogPackages,
      totalSupportRequests: totalSupportRequests ?? this.totalSupportRequests,
      recentSignups: recentSignups ?? this.recentSignups,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        totalSellers,
        activeSellers,
        totalAdmins,
        catalogCompaniesActive,
        catalogCompaniesArchived,
        catalogPackages,
        totalSupportRequests,
        recentSignups,
        isLoading,
        errorMessage,
      ];
}

/// Admin → Dashboard: app-wide numbers an admin can actually see. Reads
/// only `profiles`/`company_catalog`/`package_catalog` directly via
/// Supabase (no Drift — same reasoning as `AdminCompanyCatalogCubit`/
/// `AdminUsersCubit`: this isn't a seller's offline-first data).
///
/// **Deliberately does not, and cannot, show seller-specific business
/// data** (a seller's own companies, customers, sales, revenue, ...) —
/// `companies`/`customers`/`lines`/`shipments` are owner-only under RLS
/// with no admin override, by design (see design/APP_CONTEXT.md's
/// multi-tenant isolation model). An admin managing the account/catalog
/// layer was never meant to also see what any individual seller is
/// selling — that's a privacy boundary, not a gap to close later.
class AdminDashboardCubit extends Cubit<AdminDashboardState> {
  final SupabaseClient _client;

  AdminDashboardCubit({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client,
      super(const AdminDashboardState()) {
    load();
  }

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final profileRows = await _client.from('profiles').select('id, display_name, email, role, is_active, created_at');
      final companyRows = await _client.from('company_catalog').select('status');
      final packageRows = await _client.from('package_catalog').select('id');
      final supportRequestRows = await _client.from('support_requests').select('id');

      final sellers = profileRows.where((r) => r['role'] != 'admin').toList();
      final admins = profileRows.where((r) => r['role'] == 'admin').toList();
      final activeSellers = sellers.where((r) => r['is_active'] as bool? ?? true).length;
      final activeCompanies = companyRows.where((r) => (r['status'] as String? ?? 'active') == 'active').length;

      final sortedByNewest = List<Map<String, dynamic>>.from(profileRows)
        ..sort((a, b) => DateTime.parse(b['created_at'] as String).compareTo(DateTime.parse(a['created_at'] as String)));

      final recentSignups = sortedByNewest
          .take(5)
          .map((r) => AdminUser(
                id: r['id'] as String,
                email: (r['email'] as String?) ?? '',
                displayName: (r['display_name'] as String?) ?? '',
                role: r['role'] == 'admin' ? AppRole.admin : AppRole.seller,
                isActive: r['is_active'] as bool? ?? true,
                createdAt: DateTime.parse(r['created_at'] as String).toLocal(),
              ))
          .toList();

      emit(state.copyWith(
        totalSellers: sellers.length,
        activeSellers: activeSellers,
        totalAdmins: admins.length,
        catalogCompaniesActive: activeCompanies,
        catalogCompaniesArchived: companyRows.length - activeCompanies,
        catalogPackages: packageRows.length,
        totalSupportRequests: supportRequestRows.length,
        recentSignups: recentSignups,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: 'common.genericError'));
    }
  }
}
