import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/auth/auth_service.dart';
import '../../domain/entities/admin_user.dart';

class AdminUsersState extends Equatable {
  final List<AdminUser> users;
  final bool isLoading;
  final String? errorMessage;

  const AdminUsersState({required this.users, this.isLoading = false, this.errorMessage});

  AdminUsersState copyWith({List<AdminUser>? users, bool? isLoading, String? errorMessage}) {
    return AdminUsersState(users: users ?? this.users, isLoading: isLoading ?? this.isLoading, errorMessage: errorMessage);
  }

  @override
  List<Object?> get props => [users, isLoading, errorMessage];
}

/// Admin → Users: lists every `profiles` row (readable by an admin per
/// that table's RLS policy) and manages accounts through
/// `admin-manage-user` — the only path that can create/activate/
/// deactivate/re-role an account, since only the service role can touch
/// `auth.users` (see design/APP_CONTEXT.md).
class AdminUsersCubit extends Cubit<AdminUsersState> {
  final SupabaseClient _client;
  final AuthService _auth;

  AdminUsersCubit({required AuthService auth, SupabaseClient? client})
    : _auth = auth,
      _client = client ?? Supabase.instance.client,
      super(const AdminUsersState(users: [], isLoading: true)) {
    load();
  }

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final rows = await _client.from('profiles').select().order('email');
      final users = rows
          .map((r) => AdminUser(
                id: r['id'] as String,
                email: (r['email'] as String?) ?? '',
                displayName: (r['display_name'] as String?) ?? '',
                role: r['role'] == 'admin' ? AppRole.admin : AppRole.seller,
                isActive: r['is_active'] as bool? ?? true,
                createdAt: DateTime.parse(r['created_at'] as String).toLocal(),
              ))
          .toList();
      emit(state.copyWith(users: users, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: 'common.genericError'));
    }
  }

  Future<void> createUser({required String email, required String password, required String displayName}) async {
    await _auth.callAdminManageUser({
      'action': 'create',
      'email': email,
      'password': password,
      if (displayName.isNotEmpty) 'display_name': displayName,
    });
    await load();
  }

  Future<void> setActive(String userId, bool isActive) async {
    await _auth.callAdminManageUser({'action': 'set_active', 'user_id': userId, 'is_active': isActive});
    await load();
  }

  Future<void> setRole(String userId, AppRole role) async {
    await _auth.callAdminManageUser({'action': 'set_role', 'user_id': userId, 'role': role == AppRole.admin ? 'admin' : 'seller'});
    await load();
  }
}
