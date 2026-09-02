import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';

/// Decoupled from the Customers feature's own `CustomerStatus` enum, for
/// the same reason `LinePaymentStatus`/`LineHealthStatus` are decoupled
/// from `Line`'s enums (see `line_summary.dart`). `.label` calls `.tr()`
/// directly, so callers must compare the enum value itself, never the
/// label string, or comparisons break once the app runs in Arabic.
enum CustomerStatusSummary { normal, troubled, blocked }

extension CustomerStatusSummaryLabel on CustomerStatusSummary {
  String get label {
    switch (this) {
      case CustomerStatusSummary.normal:
        return 'customers.status.normal'.tr();
      case CustomerStatusSummary.troubled:
        return 'customers.status.troubled'.tr();
      case CustomerStatusSummary.blocked:
        return 'customers.status.blocked'.tr();
    }
  }
}

/// Read-only customer snapshot exposed to other features through
/// [CustomerCatalog] — a plain DTO, not the Customers feature's own
/// `Customer` entity, so features stay decoupled.
class CustomerSummary extends Equatable {
  final String id;
  final String name;
  final String contactNumber;
  final CustomerStatusSummary status;

  const CustomerSummary({
    required this.id,
    required this.name,
    required this.contactNumber,
    required this.status,
  });

  @override
  List<Object?> get props => [id, name, contactNumber, status];
}
