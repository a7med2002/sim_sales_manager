import 'package:flutter_bloc/flutter_bloc.dart';

import 'login_state.dart';

/// Mock authentication only — no Supabase call yet. Per the demo notice on
/// the login screen: any non-empty username/email + a password of 6+
/// characters is accepted.
class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(const LoginState());

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
    await Future.delayed(const Duration(milliseconds: 500));
    emit(state.copyWith(status: LoginStatus.success));
  }
}
