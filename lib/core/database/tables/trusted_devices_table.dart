import 'package:drift/drift.dart';

import 'tenant_columns.dart';

class TrustedDevicesTable extends Table with TenantColumns {
  @override
  String get tableName => 'trusted_devices';

  TextColumn get id => text()();
  TextColumn get deviceName => text()();
  TextColumn get browserOs => text().nullable()();
  TextColumn get ipAddress => text().nullable()();
  DateTimeColumn get firstLogin => dateTime()();
  DateTimeColumn get lastLogin => dateTime()();
  DateTimeColumn get lastVerification => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
