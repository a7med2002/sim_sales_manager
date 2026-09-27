import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../auth/auth_service.dart';
import '../../config/env.dart';
import '../../navigation/force_logout.dart';
import '../connectivity_service.dart';
import '../sync_engine.dart';
import 'sync_event.dart';
import 'sync_state.dart';

/// Event-driven by design (per CLAUDE.md, unlike the rest of the app's
/// Cubits) — it reacts to an external connectivity stream rather than
/// direct UI calls, which is exactly the case CLAUDE.md carves out for
/// full Bloc over Cubit.
class SyncBloc extends Bloc<SyncEvent, SyncState> {
  final ConnectivityService _connectivity;
  final SyncEngine? _engine;
  final AuthService? _auth;
  StreamSubscription<bool>? _connectivitySubscription;
  Timer? _periodicTimer;
  RealtimeChannel? _accountStatusChannel;

  /// Independent of write-time pushes/connectivity-change events/app-open
  /// syncs — see `PeriodicSyncTick`'s doc comment for why this exists at
  /// all: it's the safety net that catches up if every other sync
  /// opportunity happened to land during a bad-signal moment.
  static const _periodicInterval = Duration(minutes: 3);

  /// [engine]/[auth] are nullable so the bloc still works (reporting
  /// `offline` forever) when Supabase isn't configured yet — see
  /// `Env.isConfigured` and `service_locator.dart`. Without a signed-in
  /// owner (before login, or offline demo mode) only the shared catalog
  /// syncs — tenant tables need a real `owner_id` to scope to.
  SyncBloc({required ConnectivityService connectivity, SyncEngine? engine, AuthService? auth})
    : _connectivity = connectivity,
      _engine = engine,
      _auth = auth,
      super(const SyncState.initial()) {
    on<SyncStarted>(_onStarted);
    on<ConnectivityChanged>(_onConnectivityChanged);
    on<SyncRequested>(_onSyncRequested);
    on<PeriodicSyncTick>(_onPeriodicTick);
  }

  Future<void> _onStarted(SyncStarted event, Emitter<SyncState> emit) async {
    final isOnline = await _connectivity.isOnline;
    add(ConnectivityChanged(isOnline));
    _connectivitySubscription?.cancel();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((online) => add(ConnectivityChanged(online)));
    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(_periodicInterval, (_) => add(const PeriodicSyncTick()));
    // Called fresh after every real `SyncStarted` — both at app cold
    // start (already signed in) and right after a fresh login
    // (`LoginCubit.submit`) — so this always (re)subscribes against
    // whichever owner is actually signed in now.
    _subscribeToAccountStatus();
  }

  /// Lets an admin deactivating this seller's account (Admin → Users)
  /// end an already-open session on another device almost immediately,
  /// instead of only on that session's next natural token refresh —
  /// `admin-manage-user`'s `set_active` action already bans further
  /// sign-ins/refreshes, but nothing was listening for that here before,
  /// so an already-signed-in session just kept working. RLS ("profiles:
  /// read own row") limits this subscription to the signed-in user's own
  /// row. See `_stillActiveOrForceLogout` for the periodic/connectivity-
  /// triggered fallback that covers the case where this device was
  /// offline (or the app wasn't open) when the deactivation happened, so
  /// no Realtime event was ever delivered for it.
  void _subscribeToAccountStatus() {
    final existing = _accountStatusChannel;
    if (existing != null) {
      Supabase.instance.client.removeChannel(existing);
      _accountStatusChannel = null;
    }
    final ownerId = _auth?.currentOwnerId;
    if (!Env.isConfigured || ownerId == null) return;
    _accountStatusChannel = Supabase.instance.client
        .channel('own-profile-status-$ownerId')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'profiles',
          filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'id', value: ownerId),
          callback: (payload) {
            final isActive = payload.newRecord['is_active'] as bool? ?? true;
            if (!isActive) unawaited(ForceLogout.trigger());
          },
        )
        .subscribe();
  }

  Future<void> _onConnectivityChanged(ConnectivityChanged event, Emitter<SyncState> emit) async {
    if (!event.isOnline) {
      emit(state.copyWith(status: SyncStatus.offline));
      await _refreshPendingCount(emit);
      return;
    }
    await _runSync(emit);
  }

  Future<void> _onSyncRequested(SyncRequested event, Emitter<SyncState> emit) async {
    if (state.status == SyncStatus.offline) return;
    await _runSync(emit);
  }

  /// Silent — no `syncing` state transition, so this never flickers the
  /// indicator or interrupts anything; it just quietly tries to catch up
  /// and updates the pending count either way.
  Future<void> _onPeriodicTick(PeriodicSyncTick event, Emitter<SyncState> emit) async {
    final engine = _engine;
    final ownerId = _auth?.currentOwnerId;
    if (engine == null || ownerId == null) return;
    if (!await _connectivity.isOnline) {
      await _refreshPendingCount(emit);
      return;
    }
    if (!await _stillActiveOrForceLogout()) return;
    try {
      await engine.syncAll(ownerId);
      emit(state.copyWith(status: SyncStatus.idle, lastSyncedAt: DateTime.now()));
    } catch (_) {
      // Still offline or a transient failure — quietly retried next tick.
    }
    await _refreshPendingCount(emit);
  }

  Future<void> _runSync(Emitter<SyncState> emit) async {
    final engine = _engine;
    if (engine == null) {
      emit(state.copyWith(status: SyncStatus.idle));
      return;
    }
    emit(state.copyWith(status: SyncStatus.syncing));
    try {
      final ownerId = _auth?.currentOwnerId;
      if (ownerId != null) {
        if (!await _stillActiveOrForceLogout()) return;
        await engine.syncAll(ownerId);
      } else {
        await engine.pullCatalog();
      }
      emit(state.copyWith(status: SyncStatus.idle, lastSyncedAt: DateTime.now()));
    } catch (e) {
      emit(state.copyWith(status: SyncStatus.error, errorMessage: e.toString()));
    }
    await _refreshPendingCount(emit);
  }

  /// Fallback safety net for `_subscribeToAccountStatus`'s Realtime
  /// subscription — covers a deactivation that happened while this
  /// device was offline or the app wasn't running, so no Realtime event
  /// was ever delivered. Fails open on a network/transient error (never
  /// force-logs-out a real seller over a flaky connection) — only an
  /// explicit `is_active == false` triggers `ForceLogout`. Returns
  /// `false` once it has already triggered that, so the caller can skip
  /// the sync attempt that would otherwise just fail anyway.
  Future<bool> _stillActiveOrForceLogout() async {
    final auth = _auth;
    if (auth == null) return true;
    try {
      final active = await auth.fetchIsActive();
      if (!active) {
        await ForceLogout.trigger();
        return false;
      }
    } catch (_) {
      // Offline or transient failure — next check retries.
    }
    return true;
  }

  Future<void> _refreshPendingCount(Emitter<SyncState> emit) async {
    final engine = _engine;
    final ownerId = _auth?.currentOwnerId;
    if (engine == null || ownerId == null) return;
    try {
      final count = await engine.countPendingChanges(ownerId);
      emit(state.copyWith(pendingCount: count));
    } catch (_) {
      // Best-effort — the indicator just keeps whatever count it last had.
    }
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    _periodicTimer?.cancel();
    final channel = _accountStatusChannel;
    if (channel != null) Supabase.instance.client.removeChannel(channel);
    return super.close();
  }
}
