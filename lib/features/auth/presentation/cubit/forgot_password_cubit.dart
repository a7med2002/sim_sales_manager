import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/env.dart';
import 'forgot_password_state.dart';

/// Sends a real Supabase Auth reset-password email once a project is
/// configured (`Env.isConfigured`); otherwise falls back to simulating
/// the "reset link sent" outcome, same as `LoginCubit`.
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

    if (!Env.isConfigured) {
      await Future.delayed(const Duration(milliseconds: 500));
      emit(state.copyWith(status: ForgotPasswordStatus.success));
      return;
    }

    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(state.email.trim());
      emit(state.copyWith(status: ForgotPasswordStatus.success));
    } catch (_) {
      // Deliberately still reports success on failure too: never reveal
      // whether an email is registered via this flow (standard practice
      // to avoid account enumeration).
      emit(state.copyWith(status: ForgotPasswordStatus.success));
    }
  }
}
