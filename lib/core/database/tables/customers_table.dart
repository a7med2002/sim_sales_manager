import 'package:drift/drift.dart';

import 'tenant_columns.dart';

class CustomersTable extends Table with TenantColumns {
  @override
  String get tableName => 'customers';

  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get contactNumber => text()();
  TextColumn get status => text().withDefault(const Constant('normal'))();

  /// Comma-joined free-text tags — mirrors Postgres' `text[]`. A `,` in a
  /// tag itself isn't supported, consistent with tags being short labels
  /// picked from quick suggestions rather than free sentences.
  TextColumn get tags => text().withDefault(const Constant(''))();

  BoolColumn get pinned => boolean().withDefault(const Constant(false))();
  TextColumn get notes => text().nullable()();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
