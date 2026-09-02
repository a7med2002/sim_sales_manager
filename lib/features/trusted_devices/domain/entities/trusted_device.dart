import 'package:equatable/equatable.dart';

enum DeviceType { mobile, desktop, tablet }

/// A device/browser that has logged in and skips the verification code
/// until its session expires. Revoking one means it'll need a code again
/// next login. Per APP_CONTEXT.md's "6. Trusted Devices" spec.
class TrustedDevice extends Equatable {
  final String id;
  final String name;
  final DeviceType type;
  final String ipAddress;
  final DateTime firstLogin;
  final DateTime lastLogin;
  final DateTime lastVerification;
  final bool isThisDevice;

  const TrustedDevice({
    required this.id,
    required this.name,
    required this.type,
    required this.ipAddress,
    required this.firstLogin,
    required this.lastLogin,
    required this.lastVerification,
    this.isThisDevice = false,
  });

  @override
  List<Object?> get props => [id, name, type, ipAddress, firstLogin, lastLogin, lastVerification, isThisDevice];
}
