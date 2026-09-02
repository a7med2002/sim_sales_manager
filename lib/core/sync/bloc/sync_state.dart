import 'package:equatable/equatable.dart';

enum SyncStatus { offline, idle, syncing, error }

/// Drives the app bar's sync-status indicator (CLAUDE.md: "a subtle
/// sync-status indicator — never a blocking spinner").
class SyncState extends Equatable {
  final SyncStatus status;
  final DateTime? lastSyncedAt;
  final String? errorMessage;

  const SyncState({required this.status, this.lastSyncedAt, this.errorMessage});

  const SyncState.initial() : this(status: SyncStatus.offline);

  SyncState copyWith({SyncStatus? status, DateTime? lastSyncedAt, String? errorMessage}) {
    return SyncState(
      status: status ?? this.status,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, lastSyncedAt, errorMessage];
}
