import 'package:flutter_bloc/flutter_bloc.dart';

import 'forgot_password_state.dart';

/// Mock only — no Supabase Auth "reset password" call yet. Accepts any
/// value that looks like an email and simulates the "reset link sent"
/// outcome.
class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  ForgotPasswordCubit() : super(const ForgotPasswordState());

  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  void emailChanged(String value) {
    emit(state.copyWith(email: value, status: ForgotPasswordStatus.idle, errorMessage: null));
  }

  Future<void> submit() async {
    // errorMessage holds a translation key, not literal text — resolved
    // via `.tr()` in the widget, since the Cubit has no BuildContext.
    if (!_emailPattern.hasMatch(state.email.trim())) {
      emit(state.copyWith(
        status: ForgotPasswordStatus.failure,
        errorMessage: 'forgotPassword.errors.invalidEmail',
      ));
      return;
    }

    emit(state.copyWith(status: ForgotPasswordStatus.submitting, errorMessage: null));
    await Future.delayed(const Duration(milliseconds: 500));
    emit(state.copyWith(status: ForgotPasswordStatus.success));
  }
}
