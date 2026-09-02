import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';

enum ShipmentType { prepaid, creditLimit }

extension ShipmentTypeLabel on ShipmentType {
  String get label => this == ShipmentType.prepaid ? 'common.shipmentType.prepaid'.tr() : 'common.shipmentType.creditLimit'.tr();
}

/// A balance top-up transaction against one company. Per
/// APP_CONTEXT.md's "Shipment" entity: adds to that company's available
/// balance; selling a line consumes from that balance at wholesale price.
class Shipment extends Equatable {
  final String id;
  final String companyName;
  final String companyInitials;
  final ShipmentType type;
  final double totalAmount;
  final double amountPaid;
  final String paymentMethod;
  final DateTime date;
  final String referenceNumber;
  final String notes;

  const Shipment({
    required this.id,
    required this.companyName,
    required this.companyInitials,
    required this.type,
    required this.totalAmount,
    required this.amountPaid,
    required this.paymentMethod,
    required this.date,
    this.referenceNumber = '',
    this.notes = '',
  });

  double get amountRemaining => (totalAmount - amountPaid).clamp(0, double.infinity).toDouble();

  @override
  List<Object?> get props =>
      [id, companyName, companyInitials, type, totalAmount, amountPaid, paymentMethod, date, referenceNumber, notes];
}
