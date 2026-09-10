import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import 'update_checker.dart';
import 'update_state.dart';

/// Drives the in-app update flow: check `app_releases` for something
/// newer than the installed build, download the APK straight to a temp
/// file with progress, then hand it to `open_filex` — which opens
/// Android's own package-install screen for that file, the same UX a
/// Play Store update would end with, just triggered manually since this
/// app isn't distributed through a store. See `UpdateChecker`'s doc
/// comment for why this exists at all.
class UpdateCubit extends Cubit<UpdateState> {
  final UpdateChecker _checker;

  UpdateCubit({UpdateChecker? checker}) : _checker = checker ?? UpdateChecker(), super(const UpdateState());

  Future<void> check() async {
    if (state.status == UpdateStatus.checking || state.status == UpdateStatus.downloading) return;
    emit(state.copyWith(status: UpdateStatus.checking));
    final release = await _checker.checkForUpdate();
    if (isClosed) return;
    emit(release == null
        ? const UpdateState()
        : state.copyWith(status: UpdateStatus.available, release: release));
  }

  /// Dismisses the "update available" prompt for this app session
  /// without downloading — `check()` will offer it again next launch.
  /// Not offered in the UI at all when the release is `mandatory`.
  void dismiss() {
    if (state.status == UpdateStatus.available) emit(const UpdateState());
  }

  Future<void> download() async {
    final release = state.release;
    if (release == null) return;

    emit(state.copyWith(status: UpdateStatus.downloading, progress: 0));
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}${Platform.pathSeparator}esimly_update_${release.versionCode}.apk');

      final request = http.Request('GET', Uri.parse(release.apkUrl));
      final response = await request.send();
      if (response.statusCode != 200) {
        throw HttpException('Unexpected status ${response.statusCode}');
      }

      final total = response.contentLength ?? 0;
      var received = 0;
      final sink = file.openWrite();
      await for (final chunk in response.stream) {
        received += chunk.length;
        sink.add(chunk);
        if (total > 0 && !isClosed) {
          emit(state.copyWith(progress: received / total));
        }
      }
      await sink.close();

      if (isClosed) return;
      emit(const UpdateState());
      await OpenFilex.open(file.path);
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(status: UpdateStatus.error, errorMessage: 'update.errors.downloadFailed', release: release));
    }
  }
}
