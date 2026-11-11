/// Custom URL scheme registered by the native runners for Supabase Auth
/// callbacks: password recovery, email confirmation, and non-Android
/// Google OAuth sign-in.
/// `supabase_flutter` exchanges the callback for a session and emits the
/// corresponding auth event.
class DeepLinks {
  DeepLinks._();

  static const resetPasswordCallback = 'esimdafter://reset-callback';
  static const emailConfirmationCallback = 'esimdafter://login-callback';
  static const googleSignInCallback = 'esimdafter://login-callback';
}
