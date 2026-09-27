import 'package:supabase_flutter/supabase_flutter.dart';

/// Thin wrapper around Supabase Auth — every tenant-scoped Drift row
/// needs a real `ownerId`, and this is the one place that knows how to
/// get one. See design/APP_CONTEXT.md "Multi-Tenant & Admin
/// Architecture": `profiles.role` (fetched here after sign-in) is what
/// gates the admin section, on top of the owner_id every table carries.
class AuthService {
  final SupabaseClient _client;

  AuthService(this._client);

  /// The logged-in seller/admin's id — every tenant-scoped Drift write
  /// must be tagged with this. Null when signed out.
  String? get currentOwnerId => _client.auth.currentUser?.id;

  bool get isSignedIn => _client.auth.currentUser != null;

  Future<void> signIn({required String email, required String password}) {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() => _client.auth.signOut();

  /// Re-authenticates with [currentPassword] to verify it's correct
  /// (Supabase has no standalone "verify password" call — signing in
  /// again is the standard way), then updates to [newPassword]. Throws
  /// an `AuthException` from the re-auth step if the current password
  /// is wrong, before ever touching the real password.
  Future<void> changePassword({required String currentPassword, required String newPassword}) async {
    final email = _client.auth.currentUser?.email;
    if (email == null) throw StateError('No signed-in user');
    await _client.auth.signInWithPassword(email: email, password: currentPassword);
    await _client.auth.updateUser(UserAttributes(password: newPassword));
  }

  /// `'seller'` or `'admin'` — read fresh from `profiles` rather than
  /// cached, since an admin can change a role while this session is
  /// still active.
  Future<String> fetchCurrentRole() async {
    final userId = currentOwnerId;
    if (userId == null) throw StateError('No signed-in user');
    final row = await _client.from('profiles').select('role').eq('id', userId).single();
    return row['role'] as String;
  }

  /// Whether this account is still active — an admin deactivating a
  /// seller (Admin → Users, `set_active`) both bans further sign-ins and
  /// flips `profiles.is_active`, but a session already signed in on some
  /// other device keeps its access token working until it next needs
  /// refreshing. `SyncBloc` calls this (via its `profiles` Realtime
  /// subscription and, as a fallback, on every periodic/connectivity-
  /// triggered sync) to force that session out promptly instead of
  /// waiting on an unbounded natural token-refresh failure. Defaults to
  /// `true` when signed out — nothing to force out.
  Future<bool> fetchIsActive() async {
    final userId = currentOwnerId;
    if (userId == null) return true;
    final row = await _client.from('profiles').select('is_active').eq('id', userId).single();
    return row['is_active'] as bool? ?? true;
  }

  /// Calls the `admin-manage-user` Edge Function (service-role account
  /// management — create/activate/deactivate a seller, change a role).
  /// The function itself re-verifies the caller is an active admin via
  /// their own JWT before doing anything privileged; this client never
  /// holds a service-role key. Throws with the function's own error
  /// message on failure (e.g. "Admin role required", a 403).
  Future<Map<String, dynamic>> callAdminManageUser(Map<String, dynamic> body) async {
    final response = await _client.functions.invoke('admin-manage-user', body: body);
    final data = response.data;
    if (response.status >= 400) {
      final message = data is Map && data['error'] != null ? data['error'].toString() : 'Request failed (${response.status})';
      throw Exception(message);
    }
    return data is Map<String, dynamic> ? data : <String, dynamic>{};
  }
}
