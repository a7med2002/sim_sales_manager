import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';

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

/// A submitted support/feedback request. Per APP_CONTEXT.md's "5. More →
/// Support & Feedback" spec — photo/voice attachments are optional.
class SupportRequest extends Equatable {
  final String id;
  final SupportRequestType type;
  final String message;
  final String? photoPath;
  final String? voiceNotePath;
  final int? voiceNoteSeconds;
  final DateTime createdAt;

  const SupportRequest({
    required this.id,
    required this.type,
    required this.message,
    this.photoPath,
    this.voiceNotePath,
    this.voiceNoteSeconds,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, type, message, photoPath, voiceNotePath, voiceNoteSeconds, createdAt];
}
