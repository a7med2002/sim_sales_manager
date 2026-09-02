import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/catalog/company_catalog.dart';
import '../../../../core/catalog/company_summary.dart';
import '../../data/companies_mock_data.dart';
import '../../domain/entities/company.dart';
import '../../domain/entities/company_package.dart';
import '../../domain/entities/preset_company.dart';
import 'companies_state.dart';

/// Full CRUD over the in-memory mock company list — every company is
/// addable, editable, archivable and (soft/permanently) deletable. There is
/// no Drift/Supabase persistence yet: this only lives for the app session.
/// Also implements [CompanyCatalog], the narrow read/write surface other
/// features (New Sale) use instead of importing this Cubit directly.
class CompaniesCubit extends Cubit<CompaniesState> implements CompanyCatalog {
  CompaniesCubit() : super(CompaniesState(companies: CompaniesMockData.initialCompanies()));

  int _newIdCounter = 1;

  void selectTab(CompanyStatus tab) {
    emit(state.copyWith(selectedTab: tab));
  }

  void addCompany({required String name, required String notes, required List<CompanyPackage> packages}) {
    final company = Company(
      id: 'company-${_newIdCounter++}',
      name: name,
      initials: _initialsFor(name),
      notes: notes,
      packages: packages,
      status: CompanyStatus.active,
    );
    emit(state.copyWith(companies: [...state.companies, company]));
  }

  void updateCompany(
    String id, {
    required String name,
    required String notes,
    required List<CompanyPackage> packages,
  }) {
    _replace(id, (c) => c.copyWith(name: name, initials: _initialsFor(name), notes: notes, packages: packages));
  }

  void togglePin(String id) {
    _replace(id, (c) => c.copyWith(pinned: !c.pinned));
  }

  void archive(String id) {
    _replace(id, (c) => c.copyWith(status: CompanyStatus.archived));
  }

  void restoreToActive(String id) {
    _replace(id, (c) => c.copyWith(status: CompanyStatus.active));
  }

  void softDelete(String id) {
    _replace(id, (c) => c.copyWith(status: CompanyStatus.deleted));
  }

  void permanentlyDelete(String id) {
    emit(state.copyWith(companies: state.companies.where((c) => c.id != id).toList()));
  }

  void importPreset(PresetCompany preset) {
    final existingIndex = state.companies.indexWhere((c) => c.name == preset.name);
    if (existingIndex == -1) {
      final company = Company(
        id: 'company-${_newIdCounter++}',
        name: preset.name,
        initials: preset.initials,
        packages: preset.defaultPackages,
        status: CompanyStatus.active,
      );
      emit(state.copyWith(companies: [...state.companies, company]));
    } else {
      // Re-importing an archived preset restores it to active.
      _replace(preset.name, isName: true, (c) => c.copyWith(status: CompanyStatus.active));
    }
  }

  // --- CompanyCatalog ---

  @override
  List<CompanySummary> get activeCompanies => state.companies
      .where((c) => c.status == CompanyStatus.active)
      .map((c) => CompanySummary(
            id: c.id,
            name: c.name,
            initials: c.initials,
            packages: c.packages
                .map((p) => PackageSummary(id: p.id, name: p.name, wholesaleCost: p.wholesaleCost, retailPrice: p.retailPrice))
                .toList(),
            profitGenerated: c.profitGenerated,
            operationsCount: c.operationsCount,
            usagePercent: c.usagePercent,
            consumed: c.consumed,
            availableToSell: c.availableToSell,
            owedToCompany: c.owedToCompany,
          ))
      .toList();

  @override
  void recordSale({required String companyId, required double wholesaleCost, required double profit}) {
    _replace(companyId, (c) => c.applySale(wholesaleCost: wholesaleCost, profit: profit));
  }

  @override
  void addShipment({required String companyId, required double totalAmount, required double amountPaid}) {
    _replace(companyId, (c) => c.applyShipment(totalAmount: totalAmount, amountPaid: amountPaid));
  }

  void _replace(String key, Company Function(Company) update, {bool isName = false}) {
    emit(state.copyWith(
      companies: state.companies
          .map((c) => (isName ? c.name == key : c.id == key) ? update(c) : c)
          .toList(),
    ));
  }

  String _initialsFor(String name) {
    final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '?';
    if (words.length == 1) return words.first.substring(0, 1).toUpperCase();
    return (words.first.substring(0, 1) + words[1].substring(0, 1)).toUpperCase();
  }
}
