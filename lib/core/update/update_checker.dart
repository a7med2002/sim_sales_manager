import 'package:package_info_plus/package_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/env.dart';
import 'app_release.dart';

/// This app is sold directly to sellers (a license per device), not
/// distributed through an app store — so there's no store to push an
/// update notification on its own. `app_releases` is a plain, publicly
/// readable Supabase table an admin adds one row to per published
/// build; this compares the highest `version_code` there against the
/// installed app's own build number (`PackageInfo.buildNumber`, which
/// mirrors `pubspec.yaml`'s `version: x.y.z+<version_code>`) and returns
/// the release to offer, or `null` if already current.
class UpdateChecker {
  final SupabaseClient? _client;

  UpdateChecker({SupabaseClient? client}) : _client = client ?? (Env.isConfigured ? Supabase.instance.client : null);

  Future<AppRelease?> checkForUpdate() async {
    final client = _client;
    if (client == null) return null;

    try {
      final rows = await client
          .from('app_releases')
          .select()
          .eq('platform', 'android')
          .order('version_code', ascending: false)
          .limit(1);
      if (rows.isEmpty) return null;

      final row = rows.first;
      final remoteVersionCode = row['version_code'] as int;

      final info = await PackageInfo.fromPlatform();
      final currentVersionCode = int.tryParse(info.buildNumber) ?? 0;
      if (remoteVersionCode <= currentVersionCode) return null;

      final apkPath = row['apk_path'] as String;
      return AppRelease(
        versionCode: remoteVersionCode,
        versionName: row['version_name'] as String,
        apkUrl: client.storage.from('app-releases').getPublicUrl(apkPath),
        releaseNotes: row['release_notes'] as String?,
        mandatory: row['mandatory'] as bool? ?? false,
      );
    } catch (_) {
      // Offline or transient failure — never blocks normal app use over
      // an update check.
      return null;
    }
  }
}
