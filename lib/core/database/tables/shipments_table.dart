import 'package:drift/drift.dart';

import 'companies_table.dart';
import 'tenant_columns.dart';

class ShipmentsTable extends Table with TenantColumns {
  @override
  String get tableName => 'shipments';

  TextColumn get id => text()();
  TextColumn get companyId => text().references(CompaniesTable, #id)();
  TextColumn get type => text()(); // 'prepaid' | 'credit_limit'
  RealColumn get totalAmount => real().withDefault(const Constant(0))();
  RealColumn get amountPaid => real().withDefault(const Constant(0))();
  RealColumn get amountRemaining => real().withDefault(const Constant(0))();
  TextColumn get paymentMethod => text().nullable()();
  TextColumn get referenceNumber => text().nullable()();
  DateTimeColumn get shipmentDate => dateTime()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
