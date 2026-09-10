import 'package:equatable/equatable.dart';

enum ResetPasswordStatus { idle, submitting, success, failure }

class ResetPasswordState extends Equatable {
  final String newPassword;
  final String confirmPassword;
  final ResetPasswordStatus status;
  final String? errorMessage;

  const ResetPasswordState({
    this.newPassword = '',
    this.confirmPassword = '',
    this.status = ResetPasswordStatus.idle,
    this.errorMessage,
  });

  ResetPasswordState copyWith({
    String? newPassword,
    String? confirmPassword,
    ResetPasswordStatus? status,
    String? errorMessage,
  }) {
    return ResetPasswordState(
      newPassword: newPassword ?? this.newPassword,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [newPassword, confirmPassword, status, errorMessage];
}
