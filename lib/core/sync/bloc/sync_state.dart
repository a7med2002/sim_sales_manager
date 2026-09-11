import 'package:equatable/equatable.dart';

enum SyncStatus { offline, idle, syncing, error }

/// Drives the app bar's sync-status indicator (CLAUDE.md: "a subtle
/// sync-status indicator — never a blocking spinner").
class SyncState extends Equatable {
  final SyncStatus status;
  final DateTime? lastSyncedAt;
  final String? errorMessage;

  /// How many local rows haven't reached Supabase yet — see
  /// `SyncEngine.countPendingChanges`. Recomputed after every sync
  /// attempt (success, failure, or offline) so it stays accurate even
  /// while nothing's actively syncing; drives the "not backed up yet"
  /// indicator, distinct from [status] (a sync can be `idle` — nothing
  /// running right now — while still carrying pending rows it just
  /// hasn't gotten to push yet).
  final int pendingCount;

  const SyncState({required this.status, this.lastSyncedAt, this.errorMessage, this.pendingCount = 0});

  const SyncState.initial() : this(status: SyncStatus.offline);

  SyncState copyWith({SyncStatus? status, DateTime? lastSyncedAt, String? errorMessage, int? pendingCount}) {
    return SyncState(
      status: status ?? this.status,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      errorMessage: errorMessage,
      pendingCount: pendingCount ?? this.pendingCount,
    );
  }

  @override
  List<Object?> get props => [status, lastSyncedAt, errorMessage, pendingCount];
}
