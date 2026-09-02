import 'package:equatable/equatable.dart';

enum LoginStatus { idle, submitting, success, failure }

class LoginState extends Equatable {
  final String username;
  final String password;
  final bool rememberMe;
  final LoginStatus status;
  final String? errorMessage;

  const LoginState({
    this.username = '',
    this.password = '',
    this.rememberMe = true,
    this.status = LoginStatus.idle,
    this.errorMessage,
  });

  LoginState copyWith({
    String? username,
    String? password,
    bool? rememberMe,
    LoginStatus? status,
    String? errorMessage,
  }) {
    return LoginState(
      username: username ?? this.username,
      password: password ?? this.password,
      rememberMe: rememberMe ?? this.rememberMe,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [username, password, rememberMe, status, errorMessage];
}
