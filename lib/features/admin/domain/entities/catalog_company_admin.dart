import 'package:equatable/equatable.dart';

import '../../../../core/number_update/number_update_provider.dart';

enum CatalogStatus { active, archived }

class CatalogPackageAdmin extends Equatable {
  final String id;
  final String name;
  final String? simType;
  final double wholesaleCost;
  final double suggestedRetailPrice;

  const CatalogPackageAdmin({
    required this.id,
    required this.name,
    this.simType,
    required this.wholesaleCost,
    required this.suggestedRetailPrice,
  });

  @override
  List<Object?> get props => [id, name, simType, wholesaleCost, suggestedRetailPrice];
}

/// A company template in the shared, admin-managed `company_catalog` —
/// see design/APP_CONTEXT.md "Multi-Tenant & Admin Architecture". This
/// is purely a library sellers' "Import Ready-Made" copies *from*, never
/// a live link to any seller's own company.
class CatalogCompanyAdmin extends Equatable {
  final String id;
  final String name;
  final String notes;
  final String numberUpdateUrl;
  final NumberUpdateProviderKey? numberUpdateProvider;
  final String? logoUrl;
  final CatalogStatus status;
  final List<CatalogPackageAdmin> packages;

  const CatalogCompanyAdmin({
    required this.id,
    required this.name,
    this.notes = '',
    this.numberUpdateUrl = '',
    this.numberUpdateProvider,
    this.logoUrl,
    this.status = CatalogStatus.active,
    this.packages = const [],
  });

  @override
  List<Object?> get props => [id, name, notes, numberUpdateUrl, numberUpdateProvider, logoUrl, status, packages];
}
