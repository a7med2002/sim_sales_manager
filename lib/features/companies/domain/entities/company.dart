import 'package:equatable/equatable.dart';

import 'company_package.dart';

enum CompanyStatus { active, archived, deleted }

/// A supplier company: buys eSIM/SIM bundles wholesale, resold to customers.
/// Balance fields (consumed/availableToSell/owedToCompany) reflect the
/// single shared shipment balance pool for this company.
class Company extends Equatable {
  final String id;
  final String name;
  final String initials;
  final String notes;
  final bool pinned;
  final CompanyStatus status;
  final List<CompanyPackage> packages;
  final int operationsCount;
  final double profitGenerated;
  final int usagePercent;
  final double consumed;
  final double availableToSell;
  final double owedToCompany;

  /// Set only when this company was created via "Import Ready-Made" — a
  /// one-time copy source (see `CompaniesCubit`'s doc comment), not a
  /// live link. Used to detect "already imported" in the import sheet
  /// and to look up the catalog's number-update URL, if any.
  final String? catalogCompanyId;

  const Company({
    required this.id,
    required this.name,
    required this.initials,
    this.notes = '',
    this.pinned = false,
    this.status = CompanyStatus.active,
    this.packages = const [],
    this.operationsCount = 0,
    this.profitGenerated = 0,
    this.usagePercent = 0,
    this.consumed = 0,
    this.availableToSell = 0,
    this.owedToCompany = 0,
    this.catalogCompanyId,
  });

  Company copyWith({
    String? name,
    String? initials,
    String? notes,
    bool? pinned,
    CompanyStatus? status,
    List<CompanyPackage>? packages,
  }) {
    return Company(
      id: id,
      name: name ?? this.name,
      initials: initials ?? this.initials,
      notes: notes ?? this.notes,
      pinned: pinned ?? this.pinned,
      status: status ?? this.status,
      packages: packages ?? this.packages,
      operationsCount: operationsCount,
      profitGenerated: profitGenerated,
      usagePercent: usagePercent,
      consumed: consumed,
      availableToSell: availableToSell,
      owedToCompany: owedToCompany,
      catalogCompanyId: catalogCompanyId,
    );
  }

  /// Applies a sale against this company's shipment balance: wholesale
  /// cost moves from available-to-sell into consumed, usage% is
  /// recalculated, and operations/profit counters bump.
  Company applySale({required double wholesaleCost, required double profit}) {
    final newConsumed = consumed + wholesaleCost;
    final newAvailable = (availableToSell - wholesaleCost).clamp(0, double.infinity).toDouble();
    final total = newConsumed + newAvailable;
    final newUsagePercent = total <= 0 ? 0 : ((newConsumed / total) * 100).round();

    return Company(
      id: id,
      name: name,
      initials: initials,
      notes: notes,
      pinned: pinned,
      status: status,
      packages: packages,
      operationsCount: operationsCount + 1,
      profitGenerated: profitGenerated + profit,
      usagePercent: newUsagePercent,
      consumed: newConsumed,
      availableToSell: newAvailable,
      owedToCompany: owedToCompany,
      catalogCompanyId: catalogCompanyId,
    );
  }

  /// Undoes a previously-applied sale (a Line being deleted, or edited
  /// to a different company/cost) — the exact inverse of [applySale]:
  /// wholesale cost moves back from consumed into available-to-sell,
  /// operations/profit counters drop back down.
  Company reverseSale({required double wholesaleCost, required double profit}) {
    final newConsumed = (consumed - wholesaleCost).clamp(0, double.infinity).toDouble();
    final newAvailable = availableToSell + wholesaleCost;
    final total = newConsumed + newAvailable;
    final newUsagePercent = total <= 0 ? 0 : ((newConsumed / total) * 100).round();

    return Company(
      id: id,
      name: name,
      initials: initials,
      notes: notes,
      pinned: pinned,
      status: status,
      packages: packages,
      operationsCount: (operationsCount - 1).clamp(0, 1 << 31),
      profitGenerated: profitGenerated - profit,
      usagePercent: newUsagePercent,
      consumed: newConsumed,
      availableToSell: newAvailable,
      owedToCompany: owedToCompany,
      catalogCompanyId: catalogCompanyId,
    );
  }

  /// Applies a new shipment (balance top-up) to this company: the full
  /// amount grows available-to-sell (the pool a shipment adds to), and
  /// whatever wasn't paid now adds to what's owed to the company.
  Company applyShipment({required double totalAmount, required double amountPaid}) {
    final newAvailable = availableToSell + totalAmount;
    final total = consumed + newAvailable;
    final newUsagePercent = total <= 0 ? 0 : ((consumed / total) * 100).round();
    final unpaid = (totalAmount - amountPaid).clamp(0, double.infinity).toDouble();

    return Company(
      id: id,
      name: name,
      initials: initials,
      notes: notes,
      pinned: pinned,
      status: status,
      packages: packages,
      operationsCount: operationsCount,
      profitGenerated: profitGenerated,
      usagePercent: newUsagePercent,
      consumed: consumed,
      availableToSell: newAvailable,
      owedToCompany: owedToCompany + unpaid,
      catalogCompanyId: catalogCompanyId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        initials,
        notes,
        pinned,
        status,
        packages,
        operationsCount,
        profitGenerated,
        usagePercent,
        consumed,
        availableToSell,
        catalogCompanyId,
        owedToCompany,
      ];
}
