import 'package:equatable/equatable.dart';

enum LoginStatus {
  idle,
  submitting,
  success,
  emailConfirmationRequired,
  failure,
}

class LoginState extends Equatable {
  final String username;
  final String password;
  final bool rememberMe;
  final LoginStatus status;
  final String? errorMessage;

  /// Only meaningful once [status] is [LoginStatus.success] — which
  /// route to land on (admin's own home vs. the seller shell), resolved
  /// by `LoginCubit.submit()` right after a successful sign-in.
  final bool isAdmin;
  final String? confirmationEmail;
  final bool isGoogleSubmitting;

  const LoginState({
    this.username = '',
    this.password = '',
    this.rememberMe = true,
    this.status = LoginStatus.idle,
    this.errorMessage,
    this.isAdmin = false,
    this.confirmationEmail,
    this.isGoogleSubmitting = false,
  });

  LoginState copyWith({
    String? username,
    String? password,
    bool? rememberMe,
    LoginStatus? status,
    String? errorMessage,
    bool? isAdmin,
    String? confirmationEmail,
    bool? isGoogleSubmitting,
  }) {
    return LoginState(
      username: username ?? this.username,
      password: password ?? this.password,
      rememberMe: rememberMe ?? this.rememberMe,
      status: status ?? this.status,
      errorMessage: errorMessage,
      isAdmin: isAdmin ?? this.isAdmin,
      confirmationEmail: confirmationEmail ?? this.confirmationEmail,
      isGoogleSubmitting: isGoogleSubmitting ?? this.isGoogleSubmitting,
    );
  }

  @override
  List<Object?> get props => [
    username,
    password,
    rememberMe,
    status,
    errorMessage,
    isAdmin,
    confirmationEmail,
    isGoogleSubmitting,
  ];
}
