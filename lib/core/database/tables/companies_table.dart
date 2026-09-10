import 'package:drift/drift.dart';

import 'catalog_tables.dart';
import 'tenant_columns.dart';

/// A seller's own company record — name/logo/notes/packages are fully
/// theirs to add and edit, unlike a shared catalog entry. [catalogCompanyId]
/// is set only when this company was created via "Import Ready-Made"; it's
/// a one-time copy source, not a live link — see design/APP_CONTEXT.md
/// "Multi-Tenant & Admin Architecture" and PROGRESS.md for why this
/// replaced the earlier `seller_companies` link-table design.
class CompaniesTable extends Table with TenantColumns {
  @override
  String get tableName => 'companies';

  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get logoUrl => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('active'))();
  BoolColumn get pinned => boolean().withDefault(const Constant(false))();
  TextColumn get catalogCompanyId => text().references(CompanyCatalogTable, #id).nullable()();
  TextColumn get numberUpdateProvider => text().nullable()();
  TextColumn get numberUpdateUrl => text().nullable()();
  // See CompaniesCubit._loadFromDrift's doc comment on availableToSell —
  // an explicit per-company opt-in letting one sale dip the balance
  // below zero as a one-time credit-line style grace.
  BoolColumn get allowNegativeBalance => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
