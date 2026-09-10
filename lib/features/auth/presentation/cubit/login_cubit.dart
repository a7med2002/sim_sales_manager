import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/activity_log/activity_action_type.dart';
import '../../../../core/activity_log/activity_logger.dart';
import '../../../../core/auth/auth_service.dart';
import '../../../../core/config/env.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/sync/bloc/sync_bloc.dart';
import '../../../../core/sync/bloc/sync_event.dart';
import '../../../../core/utils/device_name.dart';
import 'login_state.dart';

/// Signs in against real Supabase Auth once a project is configured
/// (`Env.isConfigured` — see core/config/env.dart); until then, falls
/// back to the original mock behavior (any non-empty username + a
/// password of 6+ characters) so the app/demo still works without a
/// backend. The "Username or email" field is passed to Supabase as an
/// email — Supabase Auth requires one.
class LoginCubit extends Cubit<LoginState> {
  final AuthService? _authService;

  LoginCubit({AuthService? authService})
    : _authService = authService ?? (Env.isConfigured ? getIt<AuthService>() : null),
      super(const LoginState());

  void usernameChanged(String value) {
    emit(state.copyWith(username: value, status: LoginStatus.idle, errorMessage: null));
  }

  void passwordChanged(String value) {
    emit(state.copyWith(password: value, status: LoginStatus.idle, errorMessage: null));
  }

  void toggleRememberMe() {
    emit(state.copyWith(rememberMe: !state.rememberMe));
  }

  Future<void> submit() async {
    // errorMessage holds a translation key, not literal text — the Cubit
    // has no BuildContext, so the widget resolves it via `.tr()` at
    // display time. Same convention as ForgotPasswordCubit.
    if (state.username.trim().isEmpty) {
      emit(state.copyWith(status: LoginStatus.failure, errorMessage: 'login.errors.usernameRequired'));
      return;
    }
    if (state.password.length < 6) {
      emit(state.copyWith(status: LoginStatus.failure, errorMessage: 'login.errors.passwordTooShort'));
      return;
    }

    emit(state.copyWith(status: LoginStatus.submitting, errorMessage: null));

    final authService = _authService;
    if (authService == null) {
      await Future.delayed(const Duration(milliseconds: 500));
      emit(state.copyWith(status: LoginStatus.success));
      return;
    }

    try {
      await authService.signIn(email: state.username.trim(), password: state.password);
      // The app-startup sync ran before anyone was signed in, so it only
      // pulled the shared catalog — kick off a real sync now that a
      // real owner_id exists, so tenant data (Companies, ...) is fresh
      // by the time the seller reaches Home. `SyncStarted`, not
      // `SyncRequested` — this may be a *brand new* `SyncBloc` instance
      // (get_it gets reset on logout, see `core/navigation/logout.dart`)
      // that never had `SyncStarted` dispatched to it yet, and
      // `SyncRequested` is a no-op on a bloc still in its initial
      // `offline` state.
      getIt<SyncBloc>().add(const SyncStarted());
      final deviceName = await currentDeviceName();
      getIt<ActivityLogger>().log(ActivityActionType.login, 'Signed in from $deviceName.');
      // Which shell to land on (admin's own home vs. the seller shell) —
      // resolved here, once, right after sign-in, rather than the page
      // making its own async call; a failure here just means "not an
      // admin" rather than blocking a successful sign-in.
      var isAdmin = false;
      try {
        isAdmin = await authService.fetchCurrentRole() == 'admin';
      } catch (_) {
        // Offline or transient failure — fall back to the seller shell.
      }
      emit(state.copyWith(status: LoginStatus.success, isAdmin: isAdmin));
    } on AuthException catch (e) {
      // Never surface Supabase's raw message to the user (it can be a
      // low-level wrapped exception string, e.g. "ClientException with
      // SocketException: Failed host lookup..." when a network/DNS call
      // fails underneath gotrue) — always map to one of our own
      // translated, user-facing keys instead.
      final lower = e.message.toLowerCase();
      final String errorKey;
      if (lower.contains('invalid login credentials')) {
        errorKey = 'login.errors.invalidCredentials';
      } else if (lower.contains('socket') || lower.contains('host lookup') || lower.contains('connection') || lower.contains('network')) {
        errorKey = 'login.errors.networkError';
      } else {
        errorKey = 'login.errors.unexpected';
      }
      emit(state.copyWith(status: LoginStatus.failure, errorMessage: errorKey));
    } catch (_) {
      emit(state.copyWith(status: LoginStatus.failure, errorMessage: 'login.errors.networkError'));
    }
  }
}
