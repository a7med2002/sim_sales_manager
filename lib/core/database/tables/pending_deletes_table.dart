import 'package:drift/drift.dart';

/// A tombstone for a row permanently deleted locally whose matching
/// remote delete hasn't been confirmed yet. Without this, a permanent
/// delete's remote call is fire-and-forget with nothing tracking whether
/// it actually reached the server — if it hadn't (offline, or the app
/// closed before it finished), the next pull for that table re-fetches
/// the row (it's still sitting on the server) and silently resurrects
/// it locally. A row here blocks that: `SyncEngine`'s pull for
/// [entityTable] skips any id listed here, and a dedicated push step
/// keeps retrying the real remote delete until it succeeds, only then
/// removing the tombstone.
class PendingDeletesTable extends Table {
  @override
  String get tableName => 'pending_deletes';

  TextColumn get entityTable => text()();
  TextColumn get entityId => text()();
  TextColumn get ownerId => text()();

  @override
  Set<Column> get primaryKey => {entityTable, entityId};
}
