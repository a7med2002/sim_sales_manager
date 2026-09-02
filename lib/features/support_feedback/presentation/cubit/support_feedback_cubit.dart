import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../domain/entities/support_request.dart';
import 'support_feedback_state.dart';

/// Mock-only submission (no backend to send requests to yet) — but photo
/// attach and voice recording are wired to the real `image_picker` and
/// `record` plugins. `previousRequests` and `remainingToday` only live
/// for the app session; a real backend would track the daily limit
/// server-side.
class SupportFeedbackCubit extends Cubit<SupportFeedbackState> {
  final ImagePicker _imagePicker;
  final AudioRecorder _recorder;
  Timer? _recordingTicker;
  int _requestIdCounter = 1;

  SupportFeedbackCubit({ImagePicker? imagePicker, AudioRecorder? recorder})
      : _imagePicker = imagePicker ?? ImagePicker(),
        _recorder = recorder ?? AudioRecorder(),
        super(const SupportFeedbackState());

  void selectType(SupportRequestType type) {
    emit(state.copyWith(selectedType: type, errorMessage: null));
  }

  void messageChanged(String value) {
    if (value.length > supportMessageMaxLength) return;
    emit(state.copyWith(message: value, errorMessage: null));
  }

  Future<void> attachPhoto(ImageSource source) async {
    try {
      final file = await _imagePicker.pickImage(source: source, imageQuality: 85);
      if (file == null) return;
      emit(state.copyWith(photoPath: file.path));
    } catch (_) {
      emit(state.copyWith(errorMessage: 'supportFeedback.errors.cameraAccess'));
    }
  }

  void removePhoto() {
    emit(state.copyWith(clearPhoto: true));
  }

  Future<void> startRecording() async {
    try {
      if (!await _recorder.hasPermission()) {
        emit(state.copyWith(errorMessage: 'supportFeedback.errors.micPermission'));
        return;
      }
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/voice_note_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _recorder.start(const RecordConfig(), path: path);

      emit(state.copyWith(isRecording: true, recordingSeconds: 0, clearVoiceNote: true, errorMessage: null));
      _recordingTicker = Timer.periodic(const Duration(seconds: 1), (_) {
        final next = state.recordingSeconds + 1;
        if (next >= supportVoiceNoteMaxSeconds) {
          stopRecording();
        } else {
          emit(state.copyWith(recordingSeconds: next));
        }
      });
    } catch (_) {
      emit(state.copyWith(errorMessage: 'supportFeedback.errors.startRecording'));
    }
  }

  Future<void> stopRecording() async {
    _recordingTicker?.cancel();
    _recordingTicker = null;
    try {
      final path = await _recorder.stop();
      emit(state.copyWith(
        isRecording: false,
        voiceNotePath: path,
        voiceNoteSeconds: path == null ? null : state.recordingSeconds,
      ));
    } catch (_) {
      emit(state.copyWith(isRecording: false, errorMessage: 'supportFeedback.errors.saveRecording'));
    }
  }

  void removeVoiceNote() {
    emit(state.copyWith(clearVoiceNote: true));
  }

  void submit() {
    if (!state.canSubmit) return;

    final request = SupportRequest(
      id: 'support-${_requestIdCounter++}',
      type: state.selectedType,
      message: state.message.trim(),
      photoPath: state.photoPath,
      voiceNotePath: state.voiceNotePath,
      voiceNoteSeconds: state.voiceNoteSeconds,
      createdAt: DateTime.now(),
    );

    emit(state.copyWith(
      previousRequests: [request, ...state.previousRequests],
      remainingToday: state.remainingToday - 1,
      message: '',
      clearPhoto: true,
      clearVoiceNote: true,
      justSubmitted: true,
      errorMessage: null,
    ));
  }

  @override
  Future<void> close() async {
    _recordingTicker?.cancel();
    await _recorder.dispose();
    return super.close();
  }
}
