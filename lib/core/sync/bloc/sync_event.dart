import 'package:equatable/equatable.dart';

sealed class SyncEvent extends Equatable {
  const SyncEvent();

  @override
  List<Object?> get props => [];
}

/// Starts the connectivity listener — call once at app startup.
class SyncStarted extends SyncEvent {
  const SyncStarted();
}

/// Dispatched internally from the connectivity stream subscription.
class ConnectivityChanged extends SyncEvent {
  final bool isOnline;
  const ConnectivityChanged(this.isOnline);

  @override
  List<Object?> get props => [isOnline];
}

/// Manual pull-to-refresh style trigger, independent of connectivity
/// changes (e.g. a "sync now" button).
class SyncRequested extends SyncEvent {
  const SyncRequested();
}

/// Fired by `SyncBloc`'s own internal timer every few minutes while the
/// app is open — a safety net independent of write-time pushes,
/// connectivity-change events, and app-open syncs: if every one of
/// those happened to land during a bad-signal moment (mobile data is
/// more prone to this than WiFi), this is what eventually catches up
/// instead of local changes sitting unsynced for an entire session.
class PeriodicSyncTick extends SyncEvent {
  const PeriodicSyncTick();
}
