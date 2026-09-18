import 'package:equatable/equatable.dart';

/// One "Additional Service" top-up applied to a [Line] — see
/// `additional_services_table.dart`'s doc comment for why this is its
/// own entity/table rather than fields on `Line` itself.
class AdditionalService extends Equatable {
  final String id;
  final String lineId;
  final String customerId;
  final String? companyId;
  final double amountDeducted;
  final double amountCharged;
  final double gbAdded;
  final bool collected;
  final DateTime createdAt;

  const AdditionalService({
    required this.id,
    required this.lineId,
    required this.customerId,
    required this.companyId,
    required this.amountDeducted,
    required this.amountCharged,
    required this.gbAdded,
    required this.collected,
    required this.createdAt,
  });

  AdditionalService copyWith({
    double? amountDeducted,
    double? amountCharged,
    double? gbAdded,
    bool? collected,
  }) {
    return AdditionalService(
      id: id,
      lineId: lineId,
      customerId: customerId,
      companyId: companyId,
      amountDeducted: amountDeducted ?? this.amountDeducted,
      amountCharged: amountCharged ?? this.amountCharged,
      gbAdded: gbAdded ?? this.gbAdded,
      collected: collected ?? this.collected,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [id, lineId, customerId, companyId, amountDeducted, amountCharged, gbAdded, collected, createdAt];
}
