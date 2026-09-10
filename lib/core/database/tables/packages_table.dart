import 'package:drift/drift.dart';

import 'companies_table.dart';
import 'tenant_columns.dart';

/// A package/bundle under one of the seller's own companies — fully
/// theirs, independent of `package_catalog` once created.
class PackagesTable extends Table with TenantColumns {
  @override
  String get tableName => 'packages';

  TextColumn get id => text()();
  TextColumn get companyId => text().references(CompaniesTable, #id)();
  TextColumn get name => text()();
  // Which SIM/line this bundle runs on (e.g. "Cellcom Bundle — monthly")
  // — see CompanyPackage's doc comment. Nullable since packages saved
  // before this field existed don't have one.
  TextColumn get simType => text().nullable()();
  RealColumn get wholesaleCost => real().withDefault(const Constant(0))();
  RealColumn get retailPrice => real().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}
