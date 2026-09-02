import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/profile.dart';

/// Mock-only for now — no Supabase Auth profile yet. App-lifetime
/// singleton (via get_it) so More/Settings/anywhere else read the same
/// profile.
class ProfileCubit extends Cubit<Profile> {
  ProfileCubit() : super(const Profile(name: 'Ahmed Mq', email: 'owner@simmanager.app'));

  void update({required String name, required String email}) {
    emit(state.copyWith(name: name, email: email));
  }
}
