import 'package:drift/drift.dart';

import 'companies_table.dart';
import 'customers_table.dart';
import 'packages_table.dart';
import 'tenant_columns.dart';

class LinesTable extends Table with TenantColumns {
  @override
  String get tableName => 'lines';

  TextColumn get id => text()();
  TextColumn get customerId => text().references(CustomersTable, #id)();
  TextColumn get companyId => text().references(CompaniesTable, #id)();
  TextColumn get packageId => text().references(PackagesTable, #id).nullable()();
  TextColumn get simNumber => text()();
  DateTimeColumn get purchaseDate => dateTime()();
  DateTimeColumn get expiryDate => dateTime()();
  RealColumn get wholesaleCost => real().withDefault(const Constant(0))();
  RealColumn get retailPrice => real().withDefault(const Constant(0))();
  RealColumn get profit => real().withDefault(const Constant(0))();
  TextColumn get paymentStatus => text().withDefault(const Constant('unpaid'))();
  RealColumn get amountPaid => real().withDefault(const Constant(0))();
  RealColumn get amountRemaining => real().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}
