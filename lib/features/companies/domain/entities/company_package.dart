import 'package:equatable/equatable.dart';

/// A package/bundle offered by a company (e.g. "Weekly 500MB"). [simType]
/// is a free-typed label for which SIM/line this bundle runs on (e.g.
/// "Cellcom Bundle — monthly") — a company can resell the same data
/// amount under several different underlying line types, so this
/// disambiguates them; required for any package saved from now on, but
/// nullable at the data layer since packages saved before this field
/// existed don't have one (see `packageDisplayLabel`, which degrades to
/// just the name for those).
class CompanyPackage extends Equatable {
  final String id;
  final String name;
  final String? simType;
  final double wholesaleCost;

  /// No longer settable from the Add/Edit Company package form — a
  /// seller may charge different customers a different price for the
  /// same package, so retail price is now entered fresh every time a
  /// line is actually sold (New Sale / "+ Add Line") rather than stored
  /// here. Always `0` for any package saved from now on; the field
  /// itself (and its underlying `packages`/`package_catalog` column)
  /// stays only so packages saved before this change keep whatever
  /// value they already had, undisturbed — nothing reads it anymore.
  final double retailPrice;

  const CompanyPackage({
    required this.id,
    required this.name,
    this.simType,
    required this.wholesaleCost,
    required this.retailPrice,
  });

  CompanyPackage copyWith({String? name, String? simType, double? wholesaleCost, double? retailPrice}) {
    return CompanyPackage(
      id: id,
      name: name ?? this.name,
      simType: simType ?? this.simType,
      wholesaleCost: wholesaleCost ?? this.wholesaleCost,
      retailPrice: retailPrice ?? this.retailPrice,
    );
  }

  @override
  List<Object?> get props => [id, name, simType, wholesaleCost, retailPrice];
}
