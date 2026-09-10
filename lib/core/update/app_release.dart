import 'package:equatable/equatable.dart';

/// A published release row from Supabase's `app_releases` table (see
/// `supabase/migrations/0013_app_releases.sql`) — compared against the
/// installed app's own version code by `UpdateChecker`.
class AppRelease extends Equatable {
  final int versionCode;
  final String versionName;
  final String apkUrl;
  final String? releaseNotes;
  final bool mandatory;

  const AppRelease({
    required this.versionCode,
    required this.versionName,
    required this.apkUrl,
    this.releaseNotes,
    this.mandatory = false,
  });

  @override
  List<Object?> get props => [versionCode, versionName, apkUrl, releaseNotes, mandatory];
}
