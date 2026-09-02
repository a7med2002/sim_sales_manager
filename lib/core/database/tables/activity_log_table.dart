import 'package:drift/drift.dart';

import 'tenant_columns.dart';

class ActivityLogTable extends Table with TenantColumns {
  @override
  String get tableName => 'activity_log';

  TextColumn get id => text()();
  DateTimeColumn get occurredAt => dateTime()();
  TextColumn get actionType => text()();
  TextColumn get details => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
