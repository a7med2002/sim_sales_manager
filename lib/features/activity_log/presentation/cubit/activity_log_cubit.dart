import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/activity_log/activity_action_type.dart';
import '../../../../core/auth/auth_service.dart';
import '../../../../core/config/env.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/sync/sync_engine.dart';
import '../../data/activity_log_mock_data.dart';
import '../../domain/entities/activity_log_entry.dart';
import 'activity_log_state.dart';

/// Real mode reads every `activity_log` row for the signed-in owner from
/// Drift, newest first — entries themselves are written elsewhere, by
/// `ActivityLogger` (see its doc comment: every mutating Cubit across the
/// app calls it right after a real write succeeds). This Cubit is purely
/// a read/filter surface, same conditional real/mock pattern as the rest
/// of the app; falls back to the static mock list offline/in demo mode.
class ActivityLogCubit extends Cubit<ActivityLogState> {
  final AppDatabase? _db;
  final AuthService? _auth;
  final SyncEngine? _syncEngine;

  ActivityLogCubit({AppDatabase? db, AuthService? auth, SyncEngine? syncEngine})
    : _db = _resolveDb(db),
      _auth = _resolveAuth(auth),
      _syncEngine = syncEngine ?? (Env.isConfigured ? getIt<SyncEngine>() : null),
      super(ActivityLogState(entries: _resolveDb(db) == null ? ActivityLogMockData.initialEntries() : const [])) {
    if (_db != null && _auth?.currentOwnerId != null) {
      _syncThenLoad();
    }
  }

  static AppDatabase? _resolveDb(AppDatabase? db) => db ?? (Env.isConfigured ? getIt<AppDatabase>() : null);
  static AuthService? _resolveAuth(AuthService? auth) => auth ?? (Env.isConfigured ? getIt<AuthService>() : null);

  Future<void> _syncThenLoad() async {
    final engine = _syncEngine;
    final ownerId = _auth?.currentOwnerId;
    if (engine != null && ownerId != null) {
      try {
        await engine.pushPendingActivityLog(ownerId);
        await engine.pullActivityLog(ownerId);
      } catch (_) {
        // Offline or transient failure — proceed with local data.
      }
    }
    await _loadFromDrift();
  }

  Future<void> _loadFromDrift() async {
    final db = _db!;
    final ownerId = _auth!.currentOwnerId!;
    final rows = await (db.select(db.activityLogTable)..where((t) => t.ownerId.equals(ownerId))).get();
    final entries = rows
        .map((row) => ActivityLogEntry(
              id: row.id,
              timestamp: row.occurredAt,
              type: activityActionTypeFromRow(row.actionType),
              details: row.details ?? '',
            ))
        .toList();
    emit(state.copyWith(entries: entries));
  }

  void searchChanged(String query) => emit(state.copyWith(searchQuery: query));

  void pageSizeChanged(int pageSize) => emit(state.copyWith(pageSize: pageSize));
}
