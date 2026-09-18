import 'company_summary.dart';

/// The read/write surface the Companies feature exposes to other
/// features (New Sale, Shipments & Operations) — a narrow interface so
/// those features depend on a core-level contract instead of importing
/// Companies' Cubit/entities directly (see CLAUDE.md: no cross-feature
/// imports except through core/). Implemented by `CompaniesCubit`.
abstract class CompanyCatalog {
  List<CompanySummary> get activeCompanies;

  /// Fires whenever [activeCompanies] may have changed — including the
  /// cubit's own async initial load finishing (Drift/Supabase reads
  /// resolve after construction), so a reader built before that load
  /// completed (Home, on a cold app start) can react instead of staying
  /// stuck on an empty/zeroed snapshot until something else happens to
  /// call it again.
  Stream<void> get changes;

  /// Records a sale against a company's shipment balance: increases
  /// consumed, decreases available-to-sell, bumps operations count and
  /// profit generated.
  void recordSale({required String companyId, required double wholesaleCost, required double profit});

  /// Undoes a previously-recorded sale — call when the Line it was
  /// recorded for is deleted, or edited to a different company/cost
  /// (reverse the old values, then `recordSale` the new ones). Exact
  /// inverse of [recordSale]; without this, a company's consumed/
  /// available balance would never reflect a Line going away until the
  /// next full app reload recomputes it from scratch.
  void reverseSale({required String companyId, required double wholesaleCost, required double profit});

  /// Records a new shipment (balance top-up) against a company: grows
  /// available-to-sell by [totalAmount], and whatever wasn't paid now
  /// ([totalAmount] - [amountPaid]) adds to what's owed to the company.
  void addShipment({required String companyId, required double totalAmount, required double amountPaid});

  /// Records an "Additional Service" data top-up's cost against a
  /// company's balance — increases consumed, decreases available-to-sell.
  /// Unlike [recordSale], does not bump operations count or profit
  /// generated (this isn't a new Line being sold).
  void recordAdditionalServiceCharge({required String companyId, required double amount});

  /// Undoes a previously-recorded [recordAdditionalServiceCharge] — call
  /// when the Line it was charged against gets deleted. Exact inverse.
  void reverseAdditionalServiceCharge({required String companyId, required double amount});
}
