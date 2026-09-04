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
  /// Live mic input level while recording, normalized to 0..1 — driven
  /// by `AudioRecorder.onAmplitudeChanged` (see `SupportFeedbackCubit`).
  /// Purely a "yes, the mic is actually picking something up" indicator;
  /// not persisted or submitted anywhere.
  final double recordingLevel;
  final String? voiceNotePath;
  final int? voiceNoteSeconds;
  final bool isPlayingPreview;
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
    this.recordingLevel = 0,
    this.voiceNotePath,
    this.voiceNoteSeconds,
    this.isPlayingPreview = false,
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
    double? recordingLevel,
    bool clearVoiceNote = false,
    String? voiceNotePath,
    int? voiceNoteSeconds,
    bool? isPlayingPreview,
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
      recordingLevel: recordingLevel ?? this.recordingLevel,
      voiceNotePath: clearVoiceNote ? null : (voiceNotePath ?? this.voiceNotePath),
      voiceNoteSeconds: clearVoiceNote ? null : (voiceNoteSeconds ?? this.voiceNoteSeconds),
      isPlayingPreview: clearVoiceNote ? false : (isPlayingPreview ?? this.isPlayingPreview),
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
        recordingLevel,
        voiceNotePath,
        voiceNoteSeconds,
        isPlayingPreview,
        remainingToday,
        previousRequests,
        errorMessage,
        justSubmitted,
      ];
}
