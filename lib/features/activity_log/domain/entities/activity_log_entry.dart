import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';

/// Per APP_CONTEXT.md: "single-user, so no User column needed". Colors
/// map onto the app's existing accent palette (no blue, per
/// DESIGN_SYSTEM.md) rather than the reference app's blue/amber/green/red
/// scheme: create/login -> neutral, edit -> warning, delete -> danger,
/// fullCollection -> success.
enum ActivityActionType { login, create, edit, delete, fullCollection }

extension ActivityActionTypeLabel on ActivityActionType {
  String get label {
    switch (this) {
      case ActivityActionType.login:
        return 'activityLog.actionType.login'.tr();
      case ActivityActionType.create:
        return 'activityLog.actionType.create'.tr();
      case ActivityActionType.edit:
        return 'activityLog.actionType.edit'.tr();
      case ActivityActionType.delete:
        return 'activityLog.actionType.delete'.tr();
      case ActivityActionType.fullCollection:
        return 'activityLog.actionType.fullCollection'.tr();
    }
  }
}

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
