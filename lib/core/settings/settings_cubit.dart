import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../activity_log/activity_action_type.dart';
import '../activity_log/activity_logger.dart';
import '../auth/auth_service.dart';
import '../config/env.dart';
import '../database/app_database.dart';
import '../di/service_locator.dart';
import '../sync/sync_engine.dart';
import 'app_settings.dart';

/// Real mode persists `currencySymbol` to Drift's `settings` table (one
/// row per owner, synced to Supabase like every other tenant table) —
/// same conditional real/mock pattern as the rest of Phase 3. Falls back
/// to a runtime-only default offline/in demo mode.
class SettingsCubit extends Cubit<AppSettings> {
  final AppDatabase? _db;
  final AuthService? _auth;
  final SyncEngine? _syncEngine;

  SettingsCubit({AppDatabase? db, AuthService? auth, SyncEngine? syncEngine})
    : _db = _resolveDb(db),
      _auth = _resolveAuth(auth),
      _syncEngine = syncEngine ?? (Env.isConfigured ? getIt<SyncEngine>() : null),
      super(const AppSettings()) {
    if (_db != null && _auth?.currentOwnerId != null) {
      _syncThenLoad();
    }
  }

  static AppDatabase? _resolveDb(AppDatabase? db) => db ?? (Env.isConfigured ? getIt<AppDatabase>() : null);
  static AuthService? _resolveAuth(AuthService? auth) => auth ?? (Env.isConfigured ? getIt<AuthService>() : null);

  bool get _isReal => _db != null && _auth?.currentOwnerId != null;

  Future<void> _syncThenLoad() async {
    final engine = _syncEngine;
    final ownerId = _auth?.currentOwnerId;
    if (engine != null && ownerId != null) {
      try {
        await engine.pushPendingSettings(ownerId);
        await engine.pullSettings(ownerId);
      } catch (_) {
        // Offline or transient failure — proceed with local data.
      }
    }
    await _loadFromDrift();
  }

  Future<void> _loadFromDrift() async {
    final db = _db!;
    final ownerId = _auth!.currentOwnerId!;
    final row = await (db.select(db.settingsTable)..where((t) => t.ownerId.equals(ownerId))).getSingleOrNull();
    if (row != null) emit(state.copyWith(currencySymbol: row.currencySymbol));
  }

  void updateCurrencySymbol(String symbol) {
    final trimmed = symbol.trim();
    if (trimmed.isEmpty) return;
    emit(state.copyWith(currencySymbol: trimmed));
    if (_isReal) unawaited(_persist());
    getIt<ActivityLogger>().log(ActivityActionType.edit, 'Changed the app currency symbol to $trimmed.');
  }

  Future<void> _persist() async {
    final db = _db!;
    final ownerId = _auth!.currentOwnerId!;
    try {
      await db.into(db.settingsTable).insert(
            SettingsTableCompanion.insert(
              ownerId: ownerId,
              currencySymbol: Value(state.currencySymbol),
              synced: const Value(false),
              updatedAt: DateTime.now(),
            ),
            mode: InsertMode.insertOrReplace,
          );
      if (_syncEngine != null) {
        await _syncEngine.pushPendingSettings(ownerId);
      }
    } catch (_) {
      // Offline or transient failure — row stays local, next sync retries.
    }
  }
}
