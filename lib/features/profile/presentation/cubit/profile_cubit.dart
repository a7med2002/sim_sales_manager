import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/activity_log/activity_action_type.dart';
import '../../../../core/activity_log/activity_logger.dart';
import '../../../../core/auth/auth_service.dart';
import '../../../../core/config/env.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/sync/connectivity_service.dart';
import '../../domain/entities/profile.dart';

/// The signed-in seller's own profile. Real mode reads `profiles.display_name`
/// + the Supabase Auth email for the signed-in user; falls back to a
/// placeholder offline/in demo mode, same conditional pattern as
/// `LoginCubit`. App-lifetime singleton (via get_it) so More/Settings/Home
/// (for the "Welcome back" greeting) all read the same profile.
class ProfileCubit extends Cubit<Profile> {
  final AuthService? _auth;
  final AppDatabase? _db;
  final ConnectivityService? _connectivity;

  ProfileCubit({AuthService? auth, AppDatabase? db, ConnectivityService? connectivity})
    : _auth = auth ?? (Env.isConfigured ? getIt<AuthService>() : null),
      _db = db ?? (Env.isConfigured ? getIt<AppDatabase>() : null),
      _connectivity = connectivity ?? getIt<ConnectivityService>(),
      super(_initial(auth ?? (Env.isConfigured ? getIt<AuthService>() : null))) {
    if (_auth != null) _loadReal();
  }

  static Profile _initial(AuthService? auth) {
    final email = auth?.currentOwnerId != null ? Supabase.instance.client.auth.currentUser?.email : null;
    return Profile(name: email ?? 'Ahmed Mq', email: email ?? 'owner@simmanager.app');
  }

  Future<void> _loadReal() async {
    final auth = _auth!;
    final ownerId = auth.currentOwnerId;
    if (ownerId == null) return;
    final email = Supabase.instance.client.auth.currentUser?.email ?? '';

    // Checking connectivity first (a cheap, instant OS-level flag) skips
    // straight to the local cache below instead of waiting out a
    // multi-second connect/DNS timeout on a query that can't succeed
    // anyway — this is also what used to make "Welcome back" show the
    // raw email while offline: the query attempt failed, and the old
    // fallback had nothing better than the email to show.
    final online = await (_connectivity?.isOnline ?? Future.value(true));
    if (online) {
      try {
        final row = await Supabase.instance.client.from('profiles').select('display_name').eq('id', ownerId).single();
        final name = (row['display_name'] as String?)?.trim();
        final resolvedName = (name == null || name.isEmpty) ? email : name;
        emit(Profile(name: resolvedName, email: email));
        unawaited(_cacheDisplayName(ownerId, resolvedName));
        return;
      } catch (_) {
        // Falls through to the local cache below.
      }
    }

    final cachedName = await _readCachedDisplayName(ownerId);
    emit(Profile(name: cachedName ?? email, email: email));
  }

  Future<String?> _readCachedDisplayName(String ownerId) async {
    final db = _db;
    if (db == null) return null;
    try {
      final row = await (db.select(db.settingsTable)..where((t) => t.ownerId.equals(ownerId))).getSingleOrNull();
      final cached = row?.cachedDisplayName?.trim();
      return (cached == null || cached.isEmpty) ? null : cached;
    } catch (_) {
      return null;
    }
  }

  /// Upserts just `cachedDisplayName` (`insertOnConflictUpdate` only
  /// touches the columns present in the companion below, so an existing
  /// row's `currencySymbol`/`synced`/other settings are left alone) —
  /// this has to work even when no settings row exists yet (a seller who
  /// never opened Settings/changed currency, so `SettingsCubit` never
  /// created one) or the very first "Welcome back" while offline would
  /// still have nothing cached to fall back to.
  Future<void> _cacheDisplayName(String ownerId, String name) async {
    final db = _db;
    if (db == null) return;
    try {
      await db.into(db.settingsTable).insertOnConflictUpdate(
            SettingsTableCompanion.insert(ownerId: ownerId, updatedAt: DateTime.now(), cachedDisplayName: Value(name)),
          );
    } catch (_) {
      // Best-effort cache write — a miss here just means the next
      // offline cold start falls back to the email, same as before.
    }
  }

  void update({required String name, required String email}) {
    emit(state.copyWith(name: name, email: email));
    final auth = _auth;
    if (auth?.currentOwnerId == null) return;
    // Only the display name is persisted here — changing the account's
    // actual email requires Supabase Auth's own email-change flow
    // (re-verification), out of scope for this simple profile form.
    Supabase.instance.client.from('profiles').update({'display_name': name}).eq('id', auth!.currentOwnerId!).then(
          (_) {},
          onError: (_) {},
        );
    unawaited(_cacheDisplayName(auth.currentOwnerId!, name));
    getIt<ActivityLogger>().log(ActivityActionType.edit, 'Updated profile name to $name.');
  }
}
