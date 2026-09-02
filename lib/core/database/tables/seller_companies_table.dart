import 'package:drift/drift.dart';

import 'catalog_tables.dart';
import 'tenant_columns.dart';

/// A seller's own relationship with a catalog company: their archive/pin
/// state. The company's own name/logo/packages live in
/// [CompanyCatalogTable] and are shared — this table is what makes two
/// sellers' views of "the same" company independent of each other.
class SellerCompaniesTable extends Table with TenantColumns {
  @override
  String get tableName => 'seller_companies';

  TextColumn get id => text()();
  TextColumn get companyCatalogId => text().references(CompanyCatalogTable, #id)();
  TextColumn get status => text().withDefault(const Constant('active'))();
  BoolColumn get pinned => boolean().withDefault(const Constant(false))();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
