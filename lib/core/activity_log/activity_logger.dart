import 'package:drift/drift.dart';

import '../auth/auth_service.dart';
import '../config/env.dart';
import '../database/app_database.dart';
import '../di/service_locator.dart';
import '../sync/sync_engine.dart';
import '../utils/uuid.dart';
import 'activity_action_type.dart';

/// Cross-cutting audit trail: any mutating Cubit calls
/// `getIt<ActivityLogger>().log(...)` right after a real write succeeds
/// (Companies, Customers, Lines, Shipments, Settings, Profile, Login).
/// A single shared class rather than each Cubit writing to
/// `activity_log` itself, since the insert shape is identical everywhere
/// and this is the one thing every feature needs from `core/` without a
/// cross-feature import.
///
/// No-op in mock/offline mode (`Env.isConfigured` false, or no signed-in
/// owner yet) — there's nothing to log for a demo session, and no
/// `owner_id` to tag a row with anyway. Fire-and-forget like every other
/// write in this app: a failure (offline, transient error) just leaves
/// the row out of Drift; since these are only ever appended (never read
/// back within the same call), there's no `synced = false` row to worry
/// about losing except via the normal sync engine picking it up next
/// time — except here, if the *local* Drift insert itself never
/// happened, there is nothing for sync to find. That's an accepted gap
/// for a nice-to-have audit trail (not a source of truth for balances or
/// anything else the app depends on).
class ActivityLogger {
  final AppDatabase? _db;
  final AuthService? _auth;
  final SyncEngine? _syncEngine;

  ActivityLogger({AppDatabase? db, AuthService? auth, SyncEngine? syncEngine})
    : _db = db ?? (Env.isConfigured ? getIt<AppDatabase>() : null),
      _auth = auth ?? (Env.isConfigured ? getIt<AuthService>() : null),
      _syncEngine = syncEngine ?? (Env.isConfigured ? getIt<SyncEngine>() : null);

  void log(ActivityActionType type, String details) {
    final db = _db;
    final ownerId = _auth?.currentOwnerId;
    if (db == null || ownerId == null) return;
    _write(db, ownerId, type, details);
  }

  Future<void> _write(AppDatabase db, String ownerId, ActivityActionType type, String details) async {
    try {
      await db.into(db.activityLogTable).insert(ActivityLogTableCompanion.insert(
            id: generateUuidV4(),
            ownerId: ownerId,
            occurredAt: DateTime.now(),
            actionType: activityActionTypeToRow(type),
            details: Value(details),
            synced: const Value(false),
            updatedAt: DateTime.now(),
          ));
      if (_syncEngine != null) {
        await _syncEngine.pushPendingActivityLog(ownerId);
      }
    } catch (_) {
      // Offline or transient failure — see class doc comment.
    }
  }
}
