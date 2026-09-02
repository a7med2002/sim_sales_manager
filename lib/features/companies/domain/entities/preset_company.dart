import 'package:equatable/equatable.dart';

import 'company_package.dart';

/// A ready-made supplier brand offered in the "Import Ready-Made" sheet,
/// with its default package list.
class PresetCompany extends Equatable {
  final String name;
  final String initials;
  final List<CompanyPackage> defaultPackages;

  const PresetCompany({
    required this.name,
    required this.initials,
    required this.defaultPackages,
  });

  @override
  List<Object?> get props => [name, initials, defaultPackages];
}
