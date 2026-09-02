/// Supabase project credentials, supplied at build/run time via
/// `--dart-define` (never hardcoded/committed):
///
///   flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
///
/// Until these are supplied the app still runs fully offline against the
/// local Drift database — see `main.dart`, which only calls
/// `Supabase.initialize` when [isConfigured] is true.
class Env {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool get isConfigured => supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
