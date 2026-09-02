import 'package:equatable/equatable.dart';

/// A package/bundle offered by a company (e.g. "Weekly 500MB").
class CompanyPackage extends Equatable {
  final String id;
  final String name;
  final double wholesaleCost;
  final double retailPrice;

  const CompanyPackage({
    required this.id,
    required this.name,
    required this.wholesaleCost,
    required this.retailPrice,
  });

  CompanyPackage copyWith({String? name, double? wholesaleCost, double? retailPrice}) {
    return CompanyPackage(
      id: id,
      name: name ?? this.name,
      wholesaleCost: wholesaleCost ?? this.wholesaleCost,
      retailPrice: retailPrice ?? this.retailPrice,
    );
  }

  @override
  List<Object?> get props => [id, name, wholesaleCost, retailPrice];
}
