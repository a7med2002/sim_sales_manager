import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';

enum ShipmentType { prepaid, creditLimit }

extension ShipmentTypeLabel on ShipmentType {
  String get label => this == ShipmentType.prepaid ? 'common.shipmentType.prepaid'.tr() : 'common.shipmentType.creditLimit'.tr();
}

class CompanyBalance extends Equatable {
  final String id;
  final String name;
  final String initials;
  final ShipmentType type;
  final int usagePercent;
  final double consumed;
  final double availableToSell;
  final double owedToCompany;

  const CompanyBalance({
    required this.id,
    required this.name,
    required this.initials,
    required this.type,
    required this.usagePercent,
    required this.consumed,
    required this.availableToSell,
    required this.owedToCompany,
  });

  @override
  List<Object?> get props =>
      [id, name, initials, type, usagePercent, consumed, availableToSell, owedToCompany];
}
