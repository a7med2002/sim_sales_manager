/// Custom URL scheme the app registers on Android (`AndroidManifest.xml`
/// intent-filter) and iOS (`Info.plist` `CFBundleURLTypes`) so a Supabase
/// Auth "reset password" email link can reopen this app instead of a
/// browser. `supabase_flutter` already listens for and processes this
/// deep link internally (via its bundled `app_links` dependency) — it
/// exchanges the link for a session and fires
/// `AuthChangeEvent.passwordRecovery`, which `main.dart` listens for to
/// push the "set new password" screen.
class DeepLinks {
  DeepLinks._();

  static const resetPasswordCallback = 'simsalesmanager://reset-callback';
}
