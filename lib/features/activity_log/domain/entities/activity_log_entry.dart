import 'package:equatable/equatable.dart';

import '../../../../core/activity_log/activity_action_type.dart';

export '../../../../core/activity_log/activity_action_type.dart' show ActivityActionType, ActivityActionTypeLabel;

class ActivityLogEntry extends Equatable {
  final String id;
  final DateTime timestamp;
  final ActivityActionType type;
  final String details;

  const ActivityLogEntry({
    required this.id,
    required this.timestamp,
    required this.type,
    required this.details,
  });

  @override
  List<Object?> get props => [id, timestamp, type, details];
}
