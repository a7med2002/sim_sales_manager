import 'package:easy_localization/easy_localization.dart';

/// Per APP_CONTEXT.md: "single-user, so no User column needed" (per
/// seller — each row is still tenant-scoped by `owner_id`). Colors map
/// onto the app's existing accent palette (no blue, per
/// DESIGN_SYSTEM.md) rather than the reference app's blue/amber/green/red
/// scheme: create/login -> neutral, edit -> warning, delete -> danger,
/// fullCollection -> success.
///
/// Lives in `core/` (not `features/activity_log/`) because every
/// mutating Cubit across the app needs to reference it to log an entry —
/// see `ActivityLogger`.
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

String activityActionTypeToRow(ActivityActionType type) => type.name;

ActivityActionType activityActionTypeFromRow(String value) {
  return ActivityActionType.values.firstWhere((t) => t.name == value, orElse: () => ActivityActionType.edit);
}
