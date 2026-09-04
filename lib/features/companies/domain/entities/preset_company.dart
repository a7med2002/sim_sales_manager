import 'package:equatable/equatable.dart';

import 'company_package.dart';

/// A ready-made supplier brand offered in the "Import Ready-Made" sheet,
/// with its default package list. In real (multi-tenant) mode this is
/// sourced from the shared `company_catalog`/`package_catalog` tables —
/// [id] is then the catalog company's real id, the same id used as
/// `Company.id` once imported. In offline/demo mode it's a synthetic id
/// from the static preset list.
class PresetCompany extends Equatable {
  final String id;
  final String name;
  final String initials;
  final List<CompanyPackage> defaultPackages;

  const PresetCompany({
    required this.id,
    required this.name,
    required this.initials,
    required this.defaultPackages,
  });

  @override
  List<Object?> get props => [id, name, initials, defaultPackages];
}
