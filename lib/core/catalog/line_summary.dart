import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';

enum LineHealthStatus { active, expiringSoon, expired }

extension LineHealthStatusLabel on LineHealthStatus {
  String get label {
    switch (this) {
      case LineHealthStatus.active:
        return 'common.lineHealthStatus.active'.tr();
      case LineHealthStatus.expiringSoon:
        return 'common.lineHealthStatus.expiringSoon'.tr();
      case LineHealthStatus.expired:
        return 'common.lineHealthStatus.expired'.tr();
    }
  }
}

enum LinePaymentStatus { paid, partial, unpaid }

extension LinePaymentStatusLabel on LinePaymentStatus {
  String get label {
    switch (this) {
      case LinePaymentStatus.paid:
        return 'common.paymentStatus.paid'.tr();
      case LinePaymentStatus.partial:
        return 'common.paymentStatus.partial'.tr();
      case LinePaymentStatus.unpaid:
        return 'common.paymentStatus.unpaid'.tr();
    }
  }
}

/// Read-only line/SIM snapshot exposed to other features (Numbers,
/// Profits, Reports) through [CustomerCatalog] — a plain DTO, not the
/// Customers feature's own `Line` entity/`PaymentStatus` enum, so
/// features stay decoupled. Financial/customer fields default to
/// neutral values so existing call sites that don't care about them
/// (Numbers) don't need updating.
class LineSummary extends Equatable {
  final String id;
  final String customerName;
  final String customerContact;

  /// True when the customer this line belongs to is soft-deleted (or no
  /// longer exists at all) — set by `CustomersCubit.allLines`. Numbers/
  /// Profits/Reports keep showing these lines (a completed sale's
  /// history/profit doesn't stop being real just because the customer
  /// record was later deleted), but any "still owed"/"to collect" total
  /// built from [amountRemaining] should exclude them — that debt is no
  /// longer tracked/collectible through the app once its customer is
  /// gone, and leaving it in would show a seller a mystery balance with
  /// no customer left to explain or act on it.
  final bool customerDeleted;

  final String simNumber;

  /// Real FK into the seller's own `companies` — see `Line`'s doc
  /// comment for why this and `companyName` both exist. Defaults to ''
  /// only so old call sites that predate this field don't need touching;
  /// the one real implementer (`CustomersCubit.allLines`) always sets it.
  final String companyId;
  final String companyName;
  final String companyInitials;
  final String packageName;
  final String? packageSimType;
  final DateTime purchaseDate;
  final DateTime expiryDate;
  final double wholesaleCost;
  final double retailPrice;
  final double amountPaid;
  final double amountRemaining;
  final LinePaymentStatus paymentStatus;

  const LineSummary({
    required this.id,
    required this.simNumber,
    this.companyId = '',
    required this.companyName,
    required this.companyInitials,
    required this.packageName,
    this.packageSimType,
    required this.purchaseDate,
    required this.expiryDate,
    this.customerName = '',
    this.customerContact = '',
    this.customerDeleted = false,
    this.wholesaleCost = 0,
    this.retailPrice = 0,
    this.amountPaid = 0,
    this.amountRemaining = 0,
    this.paymentStatus = LinePaymentStatus.paid,
  });

  double get profit => retailPrice - wholesaleCost;

  LineHealthStatus statusAt(DateTime now) {
    if (expiryDate.isBefore(now)) return LineHealthStatus.expired;
    if (expiryDate.difference(now).inDays <= 7) return LineHealthStatus.expiringSoon;
    return LineHealthStatus.active;
  }

  @override
  List<Object?> get props => [
        id,
        customerName,
        customerContact,
        customerDeleted,
        simNumber,
        companyId,
        companyName,
        companyInitials,
        packageName,
        packageSimType,
        purchaseDate,
        expiryDate,
        wholesaleCost,
        retailPrice,
        amountPaid,
        amountRemaining,
        paymentStatus,
      ];
}
