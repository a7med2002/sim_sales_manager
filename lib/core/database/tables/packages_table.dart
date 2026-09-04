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
  RealColumn get wholesaleCost => real().withDefault(const Constant(0))();
  RealColumn get retailPrice => real().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}
