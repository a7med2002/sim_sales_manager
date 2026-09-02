import 'package:drift/drift.dart';

import 'catalog_tables.dart';
import 'customers_table.dart';
import 'lines_table.dart';
import 'tenant_columns.dart';

class OperationsTable extends Table with TenantColumns {
  @override
  String get tableName => 'operations';

  TextColumn get id => text()();
  TextColumn get customerId => text().references(CustomersTable, #id)();
  TextColumn get lineId => text().references(LinesTable, #id).nullable()();
  TextColumn get companyCatalogId => text().references(CompanyCatalogTable, #id)();
  DateTimeColumn get occurredAt => dateTime()();
  RealColumn get salePrice => real().withDefault(const Constant(0))();
  RealColumn get cost => real().withDefault(const Constant(0))();
  RealColumn get profit => real().withDefault(const Constant(0))();
  TextColumn get paymentStatus => text().withDefault(const Constant('unpaid'))();
  TextColumn get repName => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
