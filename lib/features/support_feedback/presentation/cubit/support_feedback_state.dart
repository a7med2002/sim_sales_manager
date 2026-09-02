import 'package:equatable/equatable.dart';

import '../../domain/entities/support_request.dart';

const int supportMessageMaxLength = 4000;
const int supportDailyRequestLimit = 5;
const int supportVoiceNoteMaxSeconds = 90; // 1:30

class SupportFeedbackState extends Equatable {
  final SupportRequestType selectedType;
  final String message;
  final String? photoPath;
  final bool isRecording;
  final int recordingSeconds;
  final String? voiceNotePath;
  final int? voiceNoteSeconds;
  final int remainingToday;
  final List<SupportRequest> previousRequests;
  final String? errorMessage;
  final bool justSubmitted;

  const SupportFeedbackState({
    this.selectedType = SupportRequestType.suggestion,
    this.message = '',
    this.photoPath,
    this.isRecording = false,
    this.recordingSeconds = 0,
    this.voiceNotePath,
    this.voiceNoteSeconds,
    this.remainingToday = supportDailyRequestLimit,
    this.previousRequests = const [],
    this.errorMessage,
    this.justSubmitted = false,
  });

  bool get canSubmit => message.trim().isNotEmpty && remainingToday > 0 && !isRecording;

  SupportFeedbackState copyWith({
    SupportRequestType? selectedType,
    String? message,
    bool clearPhoto = false,
    String? photoPath,
    bool? isRecording,
    int? recordingSeconds,
    bool clearVoiceNote = false,
    String? voiceNotePath,
    int? voiceNoteSeconds,
    int? remainingToday,
    List<SupportRequest>? previousRequests,
    String? errorMessage,
    bool? justSubmitted,
  }) {
    return SupportFeedbackState(
      selectedType: selectedType ?? this.selectedType,
      message: message ?? this.message,
      photoPath: clearPhoto ? null : (photoPath ?? this.photoPath),
      isRecording: isRecording ?? this.isRecording,
      recordingSeconds: recordingSeconds ?? this.recordingSeconds,
      voiceNotePath: clearVoiceNote ? null : (voiceNotePath ?? this.voiceNotePath),
      voiceNoteSeconds: clearVoiceNote ? null : (voiceNoteSeconds ?? this.voiceNoteSeconds),
      remainingToday: remainingToday ?? this.remainingToday,
      previousRequests: previousRequests ?? this.previousRequests,
      errorMessage: errorMessage,
      justSubmitted: justSubmitted ?? false,
    );
  }

  @override
  List<Object?> get props => [
        selectedType,
        message,
        photoPath,
        isRecording,
        recordingSeconds,
        voiceNotePath,
        voiceNoteSeconds,
        remainingToday,
        previousRequests,
        errorMessage,
        justSubmitted,
      ];
}
