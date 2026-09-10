import 'package:equatable/equatable.dart';

import 'app_release.dart';

enum UpdateStatus { idle, checking, available, downloading, error }

class UpdateState extends Equatable {
  final UpdateStatus status;
  final AppRelease? release;
  final double progress;
  final String? errorMessage;

  const UpdateState({
    this.status = UpdateStatus.idle,
    this.release,
    this.progress = 0,
    this.errorMessage,
  });

  UpdateState copyWith({
    UpdateStatus? status,
    AppRelease? release,
    double? progress,
    String? errorMessage,
  }) {
    return UpdateState(
      status: status ?? this.status,
      release: release ?? this.release,
      progress: progress ?? this.progress,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, release, progress, errorMessage];
}
