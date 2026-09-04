import 'package:easy_localization/easy_localization.dart';

/// Lives in `core/` (not `features/support_feedback/`) because
/// `features/admin/` also needs it for the admin-side inbox — see
/// `AdminSupportRequest`.
enum SupportRequestType { adminSurvey, suggestion, problem }

extension SupportRequestTypeLabel on SupportRequestType {
  String get label {
    switch (this) {
      case SupportRequestType.adminSurvey:
        return 'supportFeedback.types.adminSurvey'.tr();
      case SupportRequestType.suggestion:
        return 'supportFeedback.types.suggestion'.tr();
      case SupportRequestType.problem:
        return 'supportFeedback.types.problem'.tr();
    }
  }
}

String supportRequestTypeToRow(SupportRequestType type) {
  switch (type) {
    case SupportRequestType.adminSurvey:
      return 'admin_survey';
    case SupportRequestType.problem:
      return 'problem';
    case SupportRequestType.suggestion:
      return 'suggestion';
  }
}

SupportRequestType supportRequestTypeFromRow(String value) {
  switch (value) {
    case 'admin_survey':
      return SupportRequestType.adminSurvey;
    case 'problem':
      return SupportRequestType.problem;
    default:
      return SupportRequestType.suggestion;
  }
}
