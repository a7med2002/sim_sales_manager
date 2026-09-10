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
  // Nullable: a permanently-deleted company detaches from its historical
  // Lines instead of taking them with it (a real "sold history vanished"
  // bug found in testing — Postgres cascade-deleted Lines along with the
  // company; now `on delete set null` server-side instead, see
  // supabase/migrations/0012_lines_company_set_null.sql). The
  // `companyName`/`companyInitials` snapshot columns below are exactly
  // what keeps a detached Line still displaying its (now historical)
  // company correctly.
  TextColumn get companyId => text().nullable().references(CompaniesTable, #id)();
  TextColumn get packageId => text().references(PackagesTable, #id).nullable()();
  TextColumn get simNumber => text()();
  // Historical snapshot of the company/package names at sale time —
  // stored here (not just live-joined from the current Companies list)
  // so a Line keeps displaying correctly even if the company hasn't
  // finished loading yet on this device (a real race seen in practice:
  // Lines and Companies sync independently, so a just-added company's
  // own pull can still be in flight when a Line referencing it loads),
  // is later renamed, or is archived. Nullable so pre-migration rows
  // fall back to the old live-join in `CustomersCubit._lineFromRow`.
  TextColumn get companyName => text().nullable()();
  TextColumn get companyInitials => text().nullable()();
  TextColumn get packageName => text().nullable()();
  TextColumn get packageSimType => text().nullable()();
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
