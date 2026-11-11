import 'dart:io';

/// Supabase project credentials. Defaulted below so a plain `flutter
/// run` / `flutter build apk --release` — no extra flags — just works,
/// same as any other app. This is safe to hardcode: it's the
/// *publishable* anon key, not a secret — Supabase's real access control
/// is Postgres RLS policies on the server, and this key is designed to
/// ship inside every client app's compiled binary the same way.
/// `--dart-define` still overrides these if ever needed (e.g. pointing a
/// build at a different Supabase project):
///
///   flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
///
/// [_isFlutterTest] checks the real OS process environment variable the
/// `flutter test` command sets on every test run (`FLUTTER_TEST=true`) —
/// not a `--dart-define` (a `flutter test` invocation never passes those,
/// so a `bool.fromEnvironment` check here would always read `false` and
/// can't tell a test run apart from a real one). Reading it via
/// `Platform.environment` at runtime instead forces [isConfigured] false
/// specifically under `flutter test`, so the whole suite keeps running
/// against predictable seeded mock data with zero setup, exactly as
/// before, while `run`/`build` get the real defaults with no flags
/// needed.
class Env {
  static bool get _isFlutterTest =>
      Platform.environment.containsKey('FLUTTER_TEST');

  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://bgieiaxbfoosbgemrppp.supabase.co',
  );
  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_iEjZSk-cM95tB8gAxIw0Kw_z2d_gUbM',
  );
  static const googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue:
        '559171186326-q4kccu37emq7e0uh1c76jodrape7r024.apps.googleusercontent.com',
  );

  static bool get isConfigured =>
      !_isFlutterTest && supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
