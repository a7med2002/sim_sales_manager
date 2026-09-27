/// An admin can deactivate a seller's account (Admin → Users) while that
/// seller's app is already open and signed in — `SyncBloc` is what
/// detects this (a `profiles` Realtime subscription, plus a periodic/
/// connectivity-triggered fallback check via `AuthService.fetchIsActive`),
/// but it's a plain Bloc with no `BuildContext` of its own to navigate
/// with. `main.dart` registers the actual handler once at startup (it
/// owns the navigator key and can sign out + reset the DI container the
/// same way `core/navigation/logout.dart`'s manual logout does); callers
/// elsewhere just call [ForceLogout.trigger].
class ForceLogout {
  ForceLogout._();

  static Future<void> Function()? _handler;

  static void register(Future<void> Function() handler) {
    _handler = handler;
  }

  static Future<void> trigger() async {
    await _handler?.call();
  }
}
