import 'package:drift/drift.dart';

/// Read-only local mirror of the shared, admin-managed company/package
/// catalog — see design/APP_CONTEXT.md "Multi-Tenant & Admin
/// Architecture". Every seller's device holds the full catalog (small,
/// shared, rarely changes) rather than only the rows they've touched.
class CompanyCatalogTable extends Table {
  @override
  String get tableName => 'company_catalog';

  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get logoUrl => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get numberUpdateUrl => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('active'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class PackageCatalogTable extends Table {
  @override
  String get tableName => 'package_catalog';

  TextColumn get id => text()();
  TextColumn get companyCatalogId => text().references(CompanyCatalogTable, #id)();
  TextColumn get name => text()();
  RealColumn get wholesaleCost => real().withDefault(const Constant(0))();
  RealColumn get suggestedRetailPrice => real().withDefault(const Constant(0))();
  TextColumn get status => text().withDefault(const Constant('active'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
