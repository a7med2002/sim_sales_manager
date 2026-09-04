import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:drift/drift.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/activity_log/activity_action_type.dart';
import '../../../../core/activity_log/activity_logger.dart';
import '../../../../core/auth/auth_service.dart';
import '../../../../core/config/env.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/sync/sync_engine.dart';
import '../../../../core/utils/uuid.dart';
import '../../domain/entities/support_request.dart';
import 'support_feedback_state.dart';

/// Real mode persists the full request — `type`/`body` to Drift's
/// `support_requests` table (synced to Supabase like every other tenant
/// table), **and** any photo/voice-note attachment to the
/// `support-attachments` Storage bucket (see
/// `supabase/migrations/0003_support_attachments_storage.sql`) under
/// `{ownerId}/{requestId}/...` — matching that migration's owner-only
/// RLS policies. `attachmentUrl`/`voiceNoteUrl` then store the *storage
/// object path* (not a public URL — the bucket is private), which is all
/// the app currently needs since the Previous Requests list only shows a
/// present/absent icon for each, never renders the file itself; a future
/// viewer would fetch a signed URL for that path on demand.
///
/// `remainingToday` is still a client-only session count in real mode
/// too (derived from today's real requests on load) — a real daily-limit
/// enforcement would need to be checked server-side, out of scope here
/// since nothing else in this app enforces limits server-side either.
class SupportFeedbackCubit extends Cubit<SupportFeedbackState> {
  final ImagePicker _imagePicker;
  final AudioRecorder _recorder;
  final AudioPlayer _player;
  final AppDatabase? _db;
  final AuthService? _auth;
  final SyncEngine? _syncEngine;
  Timer? _recordingTicker;
  StreamSubscription<Amplitude>? _amplitudeSubscription;
  StreamSubscription<void>? _playerCompleteSubscription;
  int _requestIdCounter = 1;

  SupportFeedbackCubit({
    ImagePicker? imagePicker,
    AudioRecorder? recorder,
    AudioPlayer? player,
    AppDatabase? db,
    AuthService? auth,
    SyncEngine? syncEngine,
  })  : _imagePicker = imagePicker ?? ImagePicker(),
        _recorder = recorder ?? AudioRecorder(),
        _player = player ?? AudioPlayer(),
        _db = _resolveDb(db),
        _auth = _resolveAuth(auth),
        _syncEngine = syncEngine ?? (Env.isConfigured ? getIt<SyncEngine>() : null),
        super(const SupportFeedbackState()) {
    if (_db != null && _auth?.currentOwnerId != null) {
      _syncThenLoad();
    }
    _playerCompleteSubscription = _player.onPlayerComplete.listen((_) {
      emit(state.copyWith(isPlayingPreview: false));
    });
  }

  static AppDatabase? _resolveDb(AppDatabase? db) => db ?? (Env.isConfigured ? getIt<AppDatabase>() : null);
  static AuthService? _resolveAuth(AuthService? auth) => auth ?? (Env.isConfigured ? getIt<AuthService>() : null);

  bool get _isReal => _db != null && _auth?.currentOwnerId != null;

  Future<void> _syncThenLoad() async {
    final engine = _syncEngine;
    final ownerId = _auth?.currentOwnerId;
    if (engine != null && ownerId != null) {
      try {
        await engine.pushPendingSupportRequests(ownerId);
        await engine.pullSupportRequests(ownerId);
      } catch (_) {
        // Offline or transient failure — proceed with local data.
      }
    }
    await _loadFromDrift();
  }

  Future<void> _loadFromDrift() async {
    final db = _db!;
    final ownerId = _auth!.currentOwnerId!;
    final rows = await (db.select(db.supportRequestsTable)..where((t) => t.ownerId.equals(ownerId))).get();
    final requests = rows.map(_requestFromRow).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final now = DateTime.now();
    final todayCount = requests.where((r) => r.createdAt.year == now.year && r.createdAt.month == now.month && r.createdAt.day == now.day).length;

    emit(state.copyWith(
      previousRequests: requests,
      remainingToday: (supportDailyRequestLimit - todayCount).clamp(0, supportDailyRequestLimit),
    ));
  }

  SupportRequest _requestFromRow(SupportRequestsTableData row) {
    return SupportRequest(
      id: row.id,
      type: _typeFromRow(row.type),
      message: row.body,
      photoPath: row.attachmentUrl,
      voiceNotePath: row.voiceNoteUrl,
      createdAt: row.createdAt,
    );
  }

  SupportRequestType _typeFromRow(String type) {
    switch (type) {
      case 'admin_survey':
        return SupportRequestType.adminSurvey;
      case 'problem':
        return SupportRequestType.problem;
      default:
        return SupportRequestType.suggestion;
    }
  }

  String _typeToRow(SupportRequestType type) {
    switch (type) {
      case SupportRequestType.adminSurvey:
        return 'admin_survey';
      case SupportRequestType.problem:
        return 'problem';
      case SupportRequestType.suggestion:
        return 'suggestion';
    }
  }

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

      emit(state.copyWith(isRecording: true, recordingSeconds: 0, recordingLevel: 0, clearVoiceNote: true, errorMessage: null));
      _recordingTicker = Timer.periodic(const Duration(seconds: 1), (_) {
        final next = state.recordingSeconds + 1;
        if (next >= supportVoiceNoteMaxSeconds) {
          stopRecording();
        } else {
          emit(state.copyWith(recordingSeconds: next));
        }
      });
      // Live mic-level feedback while recording — see `recordingLevel`'s
      // doc comment on `SupportFeedbackState`. `current` is in dBFS,
      // roughly -45 (near silence) to 0 (peak) for normal speech; this
      // is a rough visual cue, not a precise meter, so a simple linear
      // clamp is enough.
      _amplitudeSubscription = _recorder.onAmplitudeChanged(const Duration(milliseconds: 200)).listen((amplitude) {
        final level = ((amplitude.current + 45) / 45).clamp(0.0, 1.0);
        emit(state.copyWith(recordingLevel: level));
      });
    } catch (_) {
      emit(state.copyWith(errorMessage: 'supportFeedback.errors.startRecording'));
    }
  }

  Future<void> stopRecording() async {
    _recordingTicker?.cancel();
    _recordingTicker = null;
    unawaited(_amplitudeSubscription?.cancel());
    _amplitudeSubscription = null;
    try {
      final path = await _recorder.stop();
      emit(state.copyWith(
        isRecording: false,
        recordingLevel: 0,
        voiceNotePath: path,
        voiceNoteSeconds: path == null ? null : state.recordingSeconds,
      ));
    } catch (_) {
      emit(state.copyWith(isRecording: false, recordingLevel: 0, errorMessage: 'supportFeedback.errors.saveRecording'));
    }
  }

  /// Plays back the just-recorded voice note in place, so the seller can
  /// confirm it actually captured audio before submitting — the gap that
  /// prompted this: previously there was no way to check a recording
  /// beyond trusting the duration label.
  Future<void> playPreview() async {
    final path = state.voiceNotePath;
    if (path == null) return;
    try {
      await _player.stop();
      await _player.play(DeviceFileSource(path));
      emit(state.copyWith(isPlayingPreview: true));
    } catch (_) {
      emit(state.copyWith(errorMessage: 'supportFeedback.errors.playPreview'));
    }
  }

  Future<void> stopPreview() async {
    await _player.stop();
    emit(state.copyWith(isPlayingPreview: false));
  }

  void removeVoiceNote() {
    unawaited(_player.stop());
    emit(state.copyWith(clearVoiceNote: true));
  }

  void submit() {
    if (!state.canSubmit) return;

    final request = SupportRequest(
      id: _isReal ? generateUuidV4() : 'support-${_requestIdCounter++}',
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
    if (_isReal) unawaited(_persistNewRequest(request));
    getIt<ActivityLogger>().log(ActivityActionType.create, 'Submitted a ${request.type.label.toLowerCase()} request.');
  }

  Future<void> _persistNewRequest(SupportRequest request) async {
    final db = _db!;
    final ownerId = _auth!.currentOwnerId!;
    try {
      final attachmentPath = request.photoPath == null
          ? null
          : await _uploadAttachment(ownerId, request.id, File(request.photoPath!), 'photo');
      final voiceNotePath = request.voiceNotePath == null
          ? null
          : await _uploadAttachment(ownerId, request.id, File(request.voiceNotePath!), 'voice');

      await db.into(db.supportRequestsTable).insert(SupportRequestsTableCompanion.insert(
            id: request.id,
            ownerId: ownerId,
            type: _typeToRow(request.type),
            body: request.message,
            attachmentUrl: Value(attachmentPath),
            voiceNoteUrl: Value(voiceNotePath),
            createdAt: request.createdAt,
            synced: const Value(false),
            updatedAt: DateTime.now(),
          ));
      if (_syncEngine != null) {
        await _syncEngine.pushPendingSupportRequests(ownerId);
      }
    } catch (_) {
      // Offline or transient failure — row stays local, next sync retries.
      // A partial failure (e.g. the photo uploaded but the Drift insert
      // then failed) just means an orphaned Storage object — acceptable
      // for a nice-to-have attachment, not worth extra rollback logic.
    }
  }

  /// Uploads a local attachment file to the `support-attachments` bucket
  /// under this owner's own folder (see class doc comment for the RLS
  /// shape that depends on this exact path structure) and returns the
  /// storage object path to store in Drift/Supabase. Returns null and
  /// swallows the error on failure (offline, transient) — an attachment
  /// that fails to upload just means that field stays null, same as if
  /// the seller never attached one; it never blocks the text submission
  /// itself from going through.
  Future<String?> _uploadAttachment(String ownerId, String requestId, File file, String kind) async {
    try {
      final ext = file.path.contains('.') ? file.path.split('.').last : (kind == 'photo' ? 'jpg' : 'm4a');
      final objectPath = '$ownerId/$requestId/$kind.$ext';
      final bytes = await file.readAsBytes();
      await Supabase.instance.client.storage.from('support-attachments').uploadBinary(objectPath, bytes);
      return objectPath;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> close() async {
    _recordingTicker?.cancel();
    await _amplitudeSubscription?.cancel();
    await _playerCompleteSubscription?.cancel();
    await _recorder.dispose();
    await _player.dispose();
    return super.close();
  }
}
