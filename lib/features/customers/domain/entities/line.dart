import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';

enum PaymentStatus { paid, partial, unpaid }

extension PaymentStatusLabel on PaymentStatus {
  String get label {
    switch (this) {
      case PaymentStatus.paid:
        return 'customers.paymentStatus.paid'.tr();
      case PaymentStatus.partial:
        return 'customers.paymentStatus.partial'.tr();
      case PaymentStatus.unpaid:
        return 'customers.paymentStatus.unpaid'.tr();
    }
  }
}

enum LineStatus { active, expiringSoon, expired }

extension LineStatusLabel on LineStatus {
  String get label {
    switch (this) {
      case LineStatus.active:
        return 'customers.lineStatus.active'.tr();
      case LineStatus.expiringSoon:
        return 'customers.lineStatus.expiringSoon'.tr();
      case LineStatus.expired:
        return 'customers.lineStatus.expired'.tr();
    }
  }
}

/// A SIM/eSIM line sold to a customer. Belongs to exactly one [Customer].
class Line extends Equatable {
  final String id;
  final String customerId;
  final String simNumber;
  final String companyName;
  final String companyInitials;
  final String packageName;
  final DateTime purchaseDate;
  final DateTime expiryDate;
  final double wholesaleCost;
  final double retailPrice;
  final PaymentStatus paymentStatus;
  final double amountPaid;
  final double amountRemaining;

  const Line({
    required this.id,
    required this.customerId,
    required this.simNumber,
    required this.companyName,
    required this.companyInitials,
    required this.packageName,
    required this.purchaseDate,
    required this.expiryDate,
    required this.wholesaleCost,
    required this.retailPrice,
    required this.paymentStatus,
    required this.amountPaid,
    required this.amountRemaining,
  });

  double get profit => retailPrice - wholesaleCost;

  LineStatus statusAt(DateTime now) {
    if (expiryDate.isBefore(now)) return LineStatus.expired;
    if (expiryDate.difference(now).inDays <= 7) return LineStatus.expiringSoon;
    return LineStatus.active;
  }

  /// Records an additional payment against this line (e.g. a customer
  /// paying off part of what they still owe on a partially-paid line).
  /// Clamped so `amountPaid` never exceeds `retailPrice`.
  Line applyPayment(double amount) {
    final newPaid = (amountPaid + amount).clamp(0, retailPrice).toDouble();
    final newRemaining = (retailPrice - newPaid).clamp(0, double.infinity).toDouble();
    final PaymentStatus newStatus;
    if (newPaid <= 0) {
      newStatus = PaymentStatus.unpaid;
    } else if (newRemaining <= 0) {
      newStatus = PaymentStatus.paid;
    } else {
      newStatus = PaymentStatus.partial;
    }
    return copyWith(amountPaid: newPaid, amountRemaining: newRemaining, paymentStatus: newStatus);
  }

  Line copyWith({
    String? simNumber,
    String? companyName,
    String? companyInitials,
    String? packageName,
    DateTime? purchaseDate,
    DateTime? expiryDate,
    double? wholesaleCost,
    double? retailPrice,
    PaymentStatus? paymentStatus,
    double? amountPaid,
    double? amountRemaining,
  }) {
    return Line(
      id: id,
      customerId: customerId,
      simNumber: simNumber ?? this.simNumber,
      companyName: companyName ?? this.companyName,
      companyInitials: companyInitials ?? this.companyInitials,
      packageName: packageName ?? this.packageName,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      expiryDate: expiryDate ?? this.expiryDate,
      wholesaleCost: wholesaleCost ?? this.wholesaleCost,
      retailPrice: retailPrice ?? this.retailPrice,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      amountPaid: amountPaid ?? this.amountPaid,
      amountRemaining: amountRemaining ?? this.amountRemaining,
    );
  }

  @override
  List<Object?> get props => [
        id,
        customerId,
        simNumber,
        companyName,
        companyInitials,
        packageName,
        purchaseDate,
        expiryDate,
        wholesaleCost,
        retailPrice,
        paymentStatus,
        amountPaid,
        amountRemaining,
      ];
}
