import 'package:drift/drift.dart';

import 'tenant_columns.dart';

class SupportRequestsTable extends Table with TenantColumns {
  @override
  String get tableName => 'support_requests';

  TextColumn get id => text()();
  TextColumn get type => text()(); // 'suggestion' | 'problem' | 'admin_survey'
  TextColumn get body => text()();
  TextColumn get attachmentUrl => text().nullable()();
  TextColumn get voiceNoteUrl => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
