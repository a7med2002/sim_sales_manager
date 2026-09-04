import 'package:equatable/equatable.dart';

enum AppRole { seller, admin }

/// A row from `profiles`, as seen by Admin → Users. Account
/// creation/activation/role changes all go through the
/// `admin-manage-user` Edge Function (`AuthService.callAdminManageUser`)
/// — never a direct table write, since only the service role can touch
/// `auth.users`.
class AdminUser extends Equatable {
  final String id;
  final String email;
  final String displayName;
  final AppRole role;
  final bool isActive;
  final DateTime createdAt;

  const AdminUser({
    required this.id,
    required this.email,
    this.displayName = '',
    this.role = AppRole.seller,
    this.isActive = true,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, email, displayName, role, isActive, createdAt];
}
