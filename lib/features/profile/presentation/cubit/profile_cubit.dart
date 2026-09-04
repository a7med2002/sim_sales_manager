import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/activity_log/activity_action_type.dart';
import '../../../../core/activity_log/activity_logger.dart';
import '../../../../core/auth/auth_service.dart';
import '../../../../core/config/env.dart';
import '../../../../core/di/service_locator.dart';
import '../../domain/entities/profile.dart';

/// The signed-in seller's own profile. Real mode reads `profiles.display_name`
/// + the Supabase Auth email for the signed-in user; falls back to a
/// placeholder offline/in demo mode, same conditional pattern as
/// `LoginCubit`. App-lifetime singleton (via get_it) so More/Settings/Home
/// (for the "Welcome back" greeting) all read the same profile.
class ProfileCubit extends Cubit<Profile> {
  final AuthService? _auth;

  ProfileCubit({AuthService? auth})
    : _auth = auth ?? (Env.isConfigured ? getIt<AuthService>() : null),
      super(_initial(auth ?? (Env.isConfigured ? getIt<AuthService>() : null))) {
    if (_auth != null) _loadReal();
  }

  static Profile _initial(AuthService? auth) {
    final email = auth?.currentOwnerId != null ? Supabase.instance.client.auth.currentUser?.email : null;
    return Profile(name: email ?? 'Ahmed Mq', email: email ?? 'owner@simmanager.app');
  }

  Future<void> _loadReal() async {
    final auth = _auth!;
    final ownerId = auth.currentOwnerId;
    if (ownerId == null) return;
    final email = Supabase.instance.client.auth.currentUser?.email ?? '';
    try {
      final row = await Supabase.instance.client.from('profiles').select('display_name').eq('id', ownerId).single();
      final name = (row['display_name'] as String?)?.trim();
      emit(Profile(name: (name == null || name.isEmpty) ? email : name, email: email));
    } catch (_) {
      // Offline or transient failure — keep the email-only fallback from
      // `_initial` rather than blocking on a name that isn't essential.
      emit(Profile(name: email, email: email));
    }
  }

  void update({required String name, required String email}) {
    emit(state.copyWith(name: name, email: email));
    final auth = _auth;
    if (auth?.currentOwnerId == null) return;
    // Only the display name is persisted here — changing the account's
    // actual email requires Supabase Auth's own email-change flow
    // (re-verification), out of scope for this simple profile form.
    Supabase.instance.client.from('profiles').update({'display_name': name}).eq('id', auth!.currentOwnerId!).then(
          (_) {},
          onError: (_) {},
        );
    getIt<ActivityLogger>().log(ActivityActionType.edit, 'Updated profile name to $name.');
  }
}
