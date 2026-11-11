import 'dart:async';

import 'package:flutter/widgets.dart';
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

/// Owns the sign-in and sign-up flows. A single instance is shared by the
/// login and registration routes so OAuth and email-confirmation callbacks
/// can finish the same pending flow after returning to the app.
class LoginCubit extends Cubit<LoginState> with WidgetsBindingObserver {
  final AuthService? _authService;
  StreamSubscription<AuthState>? _authSubscription;
  bool _isCompletingSignIn = false;
  bool _awaitingGoogleRedirect = false;

  LoginCubit({AuthService? authService})
    : _authService =
          authService ?? (Env.isConfigured ? getIt<AuthService>() : null),
      super(const LoginState()) {
    if (_authService != null) {
      _authSubscription = Supabase.instance.client.auth.onAuthStateChange
          .listen((data) {
            if (data.event == AuthChangeEvent.signedIn) {
              if (_awaitingGoogleRedirect) {
                _awaitingGoogleRedirect = false;
                WidgetsBinding.instance.removeObserver(this);
              }
              unawaited(_completeSignIn());
            }
          });
    }
  }

  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  void usernameChanged(String value) {
    emit(
      state.copyWith(
        username: value,
        status: LoginStatus.idle,
        errorMessage: null,
      ),
    );
  }

  void passwordChanged(String value) {
    emit(
      state.copyWith(
        password: value,
        status: LoginStatus.idle,
        errorMessage: null,
      ),
    );
  }

  void toggleRememberMe() {
    emit(state.copyWith(rememberMe: !state.rememberMe));
  }

  Future<void> submit() async {
    final email = state.username.trim();
    if (!_emailPattern.hasMatch(email)) {
      emit(
        state.copyWith(
          status: LoginStatus.failure,
          errorMessage: 'login.errors.invalidEmail',
        ),
      );
      return;
    }
    if (state.password.length < 6) {
      emit(
        state.copyWith(
          status: LoginStatus.failure,
          errorMessage: 'login.errors.passwordTooShort',
        ),
      );
      return;
    }

    emit(state.copyWith(status: LoginStatus.submitting, errorMessage: null));
    final auth = _authService;
    if (auth == null) {
      await Future.delayed(const Duration(milliseconds: 500));
      emit(state.copyWith(status: LoginStatus.success));
      return;
    }

    try {
      await auth.signIn(email: email, password: state.password);
      await _completeSignIn();
    } on AuthException catch (error) {
      _emitAuthFailure(error);
    } catch (_) {
      emit(
        state.copyWith(
          status: LoginStatus.failure,
          errorMessage: 'login.errors.networkError',
        ),
      );
    }
  }

  Future<void> signUp({
    required String displayName,
    required String email,
    required String password,
    required String confirmation,
  }) async {
    final cleanName = displayName.trim();
    final cleanEmail = email.trim();
    if (cleanName.isEmpty) {
      emit(
        state.copyWith(
          status: LoginStatus.failure,
          errorMessage: 'signUp.errors.nameRequired',
        ),
      );
      return;
    }
    if (!_emailPattern.hasMatch(cleanEmail)) {
      emit(
        state.copyWith(
          status: LoginStatus.failure,
          errorMessage: 'signUp.errors.invalidEmail',
        ),
      );
      return;
    }
    if (password.length < 6) {
      emit(
        state.copyWith(
          status: LoginStatus.failure,
          errorMessage: 'signUp.errors.passwordTooShort',
        ),
      );
      return;
    }
    if (password != confirmation) {
      emit(
        state.copyWith(
          status: LoginStatus.failure,
          errorMessage: 'signUp.errors.passwordMismatch',
        ),
      );
      return;
    }

    emit(state.copyWith(status: LoginStatus.submitting, errorMessage: null));
    final auth = _authService;
    if (auth == null) {
      await Future.delayed(const Duration(milliseconds: 500));
      emit(state.copyWith(status: LoginStatus.success));
      return;
    }

    try {
      final response = await auth.signUp(
        email: cleanEmail,
        password: password,
        displayName: cleanName,
      );
      if (response.session != null || auth.currentOwnerId != null) {
        await _completeSignIn();
      } else {
        emit(
          state.copyWith(
            status: LoginStatus.emailConfirmationRequired,
            confirmationEmail: cleanEmail,
          ),
        );
      }
    } on AuthException catch (error) {
      _emitAuthFailure(error, fallbackKey: 'signUp.errors.generic');
    } catch (_) {
      emit(
        state.copyWith(
          status: LoginStatus.failure,
          errorMessage: 'login.errors.networkError',
        ),
      );
    }
  }

  Future<void> signInWithGoogle() async {
    final auth = _authService;
    if (auth == null) {
      emit(
        state.copyWith(
          status: LoginStatus.failure,
          errorMessage: 'login.errors.googleUnavailable',
        ),
      );
      return;
    }
    _awaitingGoogleRedirect = true;
    WidgetsBinding.instance.addObserver(this);
    emit(
      state.copyWith(
        status: LoginStatus.submitting,
        errorMessage: null,
        isGoogleSubmitting: true,
      ),
    );
    try {
      final launched = await auth.signInWithGoogle();
      if (!launched && !isClosed) {
        _clearGoogleWait();
        emit(
          state.copyWith(status: LoginStatus.idle, isGoogleSubmitting: false),
        );
      }
    } on AuthException catch (error) {
      _clearGoogleWait();
      _emitAuthFailure(error, fallbackKey: 'login.errors.googleFailed');
    } catch (_) {
      _clearGoogleWait();
      emit(
        state.copyWith(
          status: LoginStatus.failure,
          errorMessage: 'login.errors.googleFailed',
          isGoogleSubmitting: false,
        ),
      );
    }
  }

  void _clearGoogleWait() {
    _awaitingGoogleRedirect = false;
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed || !_awaitingGoogleRedirect) return;
    Future<void>.delayed(const Duration(milliseconds: 500), () {
      if (isClosed ||
          !_awaitingGoogleRedirect ||
          _authService?.currentOwnerId != null) {
        return;
      }
      _clearGoogleWait();
      emit(
        this.state.copyWith(
          status: LoginStatus.idle,
          isGoogleSubmitting: false,
        ),
      );
    });
  }

  void resetStatus() {
    emit(state.copyWith(status: LoginStatus.idle, errorMessage: null));
  }

  Future<void> _completeSignIn() async {
    if (_isCompletingSignIn ||
        isClosed ||
        _authService?.currentOwnerId == null) {
      return;
    }
    _isCompletingSignIn = true;
    var isAdmin = false;
    try {
      getIt<SyncBloc>().add(const SyncStarted());
      final deviceName = await currentDeviceName();
      getIt<ActivityLogger>().log(
        ActivityActionType.login,
        'Signed in from $deviceName.',
      );
      try {
        isAdmin = await _authService!.fetchCurrentRole() == 'admin';
      } catch (_) {
        // A fresh self-registered account defaults to seller; keep the
        // seller route if a transient profile read fails.
      }
      if (!isClosed) {
        emit(state.copyWith(status: LoginStatus.success, isAdmin: isAdmin));
      }
    } catch (_) {
      _isCompletingSignIn = false;
      if (!isClosed) {
        emit(
          state.copyWith(
            status: LoginStatus.failure,
            errorMessage: 'login.errors.networkError',
          ),
        );
      }
    }
  }

  void _emitAuthFailure(
    AuthException error, {
    String fallbackKey = 'login.errors.unexpected',
  }) {
    final lower = error.message.toLowerCase();
    final key =
        lower.contains('socket') ||
            lower.contains('host lookup') ||
            lower.contains('connection') ||
            lower.contains('network')
        ? 'login.errors.networkError'
        : (fallbackKey == 'login.errors.unexpected' &&
              lower.contains('invalid login credentials'))
        ? 'login.errors.invalidCredentials'
        : fallbackKey;
    if (_awaitingGoogleRedirect) _clearGoogleWait();
    emit(
      state.copyWith(
        status: LoginStatus.failure,
        errorMessage: key,
        isGoogleSubmitting: false,
      ),
    );
  }

  @override
  Future<void> close() async {
    if (_awaitingGoogleRedirect) _clearGoogleWait();
    await _authSubscription?.cancel();
    return super.close();
  }
}
