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
