import 'package:equatable/equatable.dart';

import '../../../../core/number_update/number_update_provider.dart';
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

  /// Which supplier refresh integration (if any) this company maps to —
  /// see `features/number_update/`. Null means Number Update has nothing
  /// automated for this company (unsupported supplier, or a seller
  /// hasn't picked one).
  final NumberUpdateProviderKey? numberUpdateProvider;

  /// A `company-logos` Storage public URL — see
  /// `features/companies/presentation/widgets/company_form_sheet.dart`'s
  /// upload flow. Null shows the initials avatar instead.
  final String? logoUrl;

  /// A manual "open this supplier's update page yourself" link — the
  /// fallback Number Update offers when this company has no automated
  /// `numberUpdateProvider` (or as a reference even when it does).
  final String? numberUpdateUrl;

  /// Opt-in per company: lets one sale dip [availableToSell] below zero
  /// instead of being blocked — a one-time credit-line style grace. Only
  /// takes effect while the balance is still above zero (see
  /// `NewSaleState.exceedsCompanyBalance`, the only place that actually
  /// enforces the "one dip, then blocked again until topped up" rule);
  /// [applySale] here just reflects whatever the balance ends up being,
  /// clamped to zero when this is off (today's original behavior).
  final bool allowNegativeBalance;

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
    this.numberUpdateProvider,
    this.logoUrl,
    this.numberUpdateUrl,
    this.allowNegativeBalance = false,
  });

  Company copyWith({
    String? name,
    String? initials,
    String? notes,
    bool? pinned,
    CompanyStatus? status,
    List<CompanyPackage>? packages,
    bool clearNumberUpdateProvider = false,
    NumberUpdateProviderKey? numberUpdateProvider,
    bool clearLogoUrl = false,
    String? logoUrl,
    String? numberUpdateUrl,
    bool? allowNegativeBalance,
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
      numberUpdateProvider: clearNumberUpdateProvider ? null : (numberUpdateProvider ?? this.numberUpdateProvider),
      logoUrl: clearLogoUrl ? null : (logoUrl ?? this.logoUrl),
      numberUpdateUrl: numberUpdateUrl ?? this.numberUpdateUrl,
      allowNegativeBalance: allowNegativeBalance ?? this.allowNegativeBalance,
    );
  }

  /// Applies a sale against this company's shipment balance: wholesale
  /// cost moves from available-to-sell into consumed, usage% is
  /// recalculated, and operations/profit counters bump.
  Company applySale({required double wholesaleCost, required double profit}) {
    final newConsumed = consumed + wholesaleCost;
    final rawAvailable = availableToSell - wholesaleCost;
    // A negative balance is only ever meaningful for a company that
    // opted in — see this class's doc comment on [allowNegativeBalance].
    // `NewSaleState.exceedsCompanyBalance` is what actually decides
    // whether a sale that would go negative is allowed through at all;
    // this just reflects the resulting balance either way.
    final newAvailable = allowNegativeBalance ? rawAvailable : rawAvailable.clamp(0, double.infinity).toDouble();
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
      numberUpdateProvider: numberUpdateProvider,
      logoUrl: logoUrl,
      numberUpdateUrl: numberUpdateUrl,
      allowNegativeBalance: allowNegativeBalance,
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
      numberUpdateProvider: numberUpdateProvider,
      logoUrl: logoUrl,
      numberUpdateUrl: numberUpdateUrl,
      allowNegativeBalance: allowNegativeBalance,
    );
  }

  /// Applies an "Additional Service" data top-up's cost against this
  /// company's balance — same consumed/available-to-sell mechanics as
  /// [applySale], but deliberately leaves [operationsCount]/
  /// [profitGenerated] untouched: this isn't a new Line being sold, just
  /// an extra charge against an existing one (see
  /// `additional_services_table.dart`'s doc comment for why this is
  /// tracked as its own ledger rather than folded into the Line itself).
  Company applyAdditionalServiceCharge({required double amount}) {
    final newConsumed = consumed + amount;
    final rawAvailable = availableToSell - amount;
    final newAvailable = allowNegativeBalance ? rawAvailable : rawAvailable.clamp(0, double.infinity).toDouble();
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
      operationsCount: operationsCount,
      profitGenerated: profitGenerated,
      usagePercent: newUsagePercent,
      consumed: newConsumed,
      availableToSell: newAvailable,
      owedToCompany: owedToCompany,
      catalogCompanyId: catalogCompanyId,
      numberUpdateProvider: numberUpdateProvider,
      logoUrl: logoUrl,
      numberUpdateUrl: numberUpdateUrl,
      allowNegativeBalance: allowNegativeBalance,
    );
  }

  /// Undoes a previously-applied [applyAdditionalServiceCharge] — e.g.
  /// the Line it was charged against gets deleted. Exact inverse, same
  /// operations/profit-untouched reasoning.
  Company reverseAdditionalServiceCharge({required double amount}) {
    final newConsumed = (consumed - amount).clamp(0, double.infinity).toDouble();
    final newAvailable = availableToSell + amount;
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
      operationsCount: operationsCount,
      profitGenerated: profitGenerated,
      usagePercent: newUsagePercent,
      consumed: newConsumed,
      availableToSell: newAvailable,
      owedToCompany: owedToCompany,
      catalogCompanyId: catalogCompanyId,
      numberUpdateProvider: numberUpdateProvider,
      logoUrl: logoUrl,
      numberUpdateUrl: numberUpdateUrl,
      allowNegativeBalance: allowNegativeBalance,
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
      numberUpdateProvider: numberUpdateProvider,
      logoUrl: logoUrl,
      numberUpdateUrl: numberUpdateUrl,
      allowNegativeBalance: allowNegativeBalance,
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
        numberUpdateProvider,
        logoUrl,
        numberUpdateUrl,
        allowNegativeBalance,
      ];
}
