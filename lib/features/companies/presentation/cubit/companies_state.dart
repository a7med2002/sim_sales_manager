import 'package:equatable/equatable.dart';

import '../../domain/entities/company.dart';

class CompaniesState extends Equatable {
  final List<Company> companies;
  final CompanyStatus selectedTab;

  const CompaniesState({
    this.companies = const [],
    this.selectedTab = CompanyStatus.active,
  });

  List<Company> get visibleCompanies {
    final filtered = companies.where((c) => c.status == selectedTab).toList();
    filtered.sort((a, b) {
      if (a.pinned != b.pinned) return a.pinned ? -1 : 1;
      return a.name.compareTo(b.name);
    });
    return filtered;
  }

  int get totalCount => companies.length;

  CompaniesState copyWith({
    List<Company>? companies,
    CompanyStatus? selectedTab,
  }) {
    return CompaniesState(
      companies: companies ?? this.companies,
      selectedTab: selectedTab ?? this.selectedTab,
    );
  }

  @override
  List<Object?> get props => [companies, selectedTab];
}
