import 'customer_summary.dart';
import 'line_summary.dart';

/// The read/write surface the Customers feature exposes to other
/// features (currently New Sale, Numbers) — see [CompanyCatalog] for why
/// this exists. Implemented by `CustomersCubit`.
abstract class CustomerCatalog {
  List<CustomerSummary> get activeCustomers;

  /// Every sold Line/SIM across every customer — used by the Numbers
  /// page, which is a global log rather than a per-customer view.
  List<LineSummary> get allLines;

  /// Quick customer creation from within the New Sale flow (name +
  /// contact only — full editing still happens on the Customers page).
  /// Returns the new customer's id.
  String quickAddCustomer({required String name, required String contactNumber});

  /// Adds a sold Line under an existing customer. Payment status is
  /// derived internally from `amountPaid` vs `retailPrice`.
  void addSaleLine({
    required String customerId,
    required String simNumber,
    required String companyName,
    required String companyInitials,
    required String packageName,
    required DateTime purchaseDate,
    required DateTime expiryDate,
    required double wholesaleCost,
    required double retailPrice,
    required double amountPaid,
  });
}
