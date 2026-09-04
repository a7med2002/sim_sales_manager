import 'company_summary.dart';

/// The read/write surface the Companies feature exposes to other
/// features (New Sale, Shipments & Operations) — a narrow interface so
/// those features depend on a core-level contract instead of importing
/// Companies' Cubit/entities directly (see CLAUDE.md: no cross-feature
/// imports except through core/). Implemented by `CompaniesCubit`.
abstract class CompanyCatalog {
  List<CompanySummary> get activeCompanies;

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
}
