import 'package:drift/drift.dart';

import 'tenant_columns.dart';

/// One row per Number Update attempt (see `NumberUpdateCubit`) — append-
/// only, same shape as `ActivityLogTable`/`SupportRequestsTable`.
class NumberUpdateLogTable extends Table with TenantColumns {
  @override
  String get tableName => 'number_update_log';

  TextColumn get id => text()();
  TextColumn get phoneNumber => text()();
  TextColumn get status => text()(); // 'success' | 'not_found' | 'failed'
  TextColumn get message => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
