import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../auth/auth_service.dart';
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
    return super.close();
  }
}
