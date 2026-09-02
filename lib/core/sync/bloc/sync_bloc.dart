import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

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
  StreamSubscription<bool>? _connectivitySubscription;

  /// [engine] is nullable so the bloc still works (reporting `offline`
  /// forever) when Supabase isn't configured yet — see `Env.isConfigured`
  /// and `service_locator.dart`.
  SyncBloc({required ConnectivityService connectivity, SyncEngine? engine})
    : _connectivity = connectivity,
      _engine = engine,
      super(const SyncState.initial()) {
    on<SyncStarted>(_onStarted);
    on<ConnectivityChanged>(_onConnectivityChanged);
    on<SyncRequested>(_onSyncRequested);
  }

  Future<void> _onStarted(SyncStarted event, Emitter<SyncState> emit) async {
    final isOnline = await _connectivity.isOnline;
    add(ConnectivityChanged(isOnline));
    _connectivitySubscription?.cancel();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((online) => add(ConnectivityChanged(online)));
  }

  Future<void> _onConnectivityChanged(ConnectivityChanged event, Emitter<SyncState> emit) async {
    if (!event.isOnline) {
      emit(state.copyWith(status: SyncStatus.offline));
      return;
    }
    await _runSync(emit);
  }

  Future<void> _onSyncRequested(SyncRequested event, Emitter<SyncState> emit) async {
    if (state.status == SyncStatus.offline) return;
    await _runSync(emit);
  }

  Future<void> _runSync(Emitter<SyncState> emit) async {
    final engine = _engine;
    if (engine == null) {
      emit(state.copyWith(status: SyncStatus.idle));
      return;
    }
    emit(state.copyWith(status: SyncStatus.syncing));
    try {
      await engine.pullCatalog();
      emit(state.copyWith(status: SyncStatus.idle, lastSyncedAt: DateTime.now()));
    } catch (e) {
      emit(state.copyWith(status: SyncStatus.error, errorMessage: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    return super.close();
  }
}
