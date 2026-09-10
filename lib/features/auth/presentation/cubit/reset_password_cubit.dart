import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'reset_password_state.dart';

/// Sets a new password for the temporary session Supabase establishes
/// when the user opens the "reset password" email link (see
/// `main.dart`'s `AuthChangeEvent.passwordRecovery` listener, which
/// navigates here). No "current password" field is needed — the
/// recovery link itself is the proof of ownership.
class ResetPasswordCubit extends Cubit<ResetPasswordState> {
  ResetPasswordCubit() : super(const ResetPasswordState());

  void newPasswordChanged(String value) {
    emit(state.copyWith(newPassword: value, status: ResetPasswordStatus.idle, errorMessage: null));
  }

  void confirmPasswordChanged(String value) {
    emit(state.copyWith(confirmPassword: value, status: ResetPasswordStatus.idle, errorMessage: null));
  }

  Future<void> submit() async {
    if (state.newPassword.length < 6) {
      emit(state.copyWith(status: ResetPasswordStatus.failure, errorMessage: 'resetPassword.errors.tooShort'));
      return;
    }
    if (state.newPassword != state.confirmPassword) {
      emit(state.copyWith(status: ResetPasswordStatus.failure, errorMessage: 'resetPassword.errors.mismatch'));
      return;
    }

    emit(state.copyWith(status: ResetPasswordStatus.submitting, errorMessage: null));

    try {
      await Supabase.instance.client.auth.updateUser(UserAttributes(password: state.newPassword));
      emit(state.copyWith(status: ResetPasswordStatus.success));
    } on AuthException {
      emit(state.copyWith(status: ResetPasswordStatus.failure, errorMessage: 'resetPassword.errors.expiredLink'));
    } catch (_) {
      emit(state.copyWith(status: ResetPasswordStatus.failure, errorMessage: 'resetPassword.errors.generic'));
    }
  }
}
