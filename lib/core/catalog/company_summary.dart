import 'package:equatable/equatable.dart';

import '../number_update/number_update_provider.dart';

/// Read-only package snapshot exposed to other features through
/// [CompanyCatalog] — deliberately a plain DTO, not the Companies
/// feature's own `CompanyPackage` entity, so features stay decoupled.
class PackageSummary extends Equatable {
  final String id;
  final String name;
  final String? simType;
  final double wholesaleCost;
  final double retailPrice;

  const PackageSummary({
    required this.id,
    required this.name,
    this.simType,
    required this.wholesaleCost,
    required this.retailPrice,
  });

  @override
  List<Object?> get props => [id, name, simType, wholesaleCost, retailPrice];
}

/// Read-only company snapshot exposed to other features through
/// [CompanyCatalog]. The financial fields default to 0 so existing call
/// sites that don't care about them (New Sale's company picker) don't
/// need updating — only Profits/Reports/Shipments read them.
class CompanySummary extends Equatable {
  final String id;
  final String name;
  final String initials;
  final List<PackageSummary> packages;
  final double profitGenerated;
  final int operationsCount;
  final int usagePercent;
  final double consumed;
  final double availableToSell;
  final double owedToCompany;
  final NumberUpdateProviderKey? numberUpdateProvider;
  final String? logoUrl;
  final String? numberUpdateUrl;

  /// See `Company.allowNegativeBalance`'s doc comment — carried through
  /// here so New Sale (the only consumer that needs it) can decide
  /// whether a sale exceeding [availableToSell] is still allowed.
  final bool allowNegativeBalance;

  const CompanySummary({
    required this.id,
    required this.name,
    required this.initials,
    required this.packages,
    this.profitGenerated = 0,
    this.operationsCount = 0,
    this.usagePercent = 0,
    this.consumed = 0,
    this.availableToSell = 0,
    this.owedToCompany = 0,
    this.numberUpdateProvider,
    this.logoUrl,
    this.numberUpdateUrl,
    this.allowNegativeBalance = false,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        initials,
        packages,
        profitGenerated,
        operationsCount,
        usagePercent,
        consumed,
        availableToSell,
        owedToCompany,
        numberUpdateProvider,
        logoUrl,
        numberUpdateUrl,
        allowNegativeBalance,
      ];
}
