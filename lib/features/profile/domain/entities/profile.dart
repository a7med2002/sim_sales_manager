import 'package:equatable/equatable.dart';

/// The single pre-provisioned owner/seller account (this is a single-user
/// app — no roles, no team). Editable from Settings.
class Profile extends Equatable {
  final String name;
  final String email;

  const Profile({required this.name, required this.email});

  Profile copyWith({String? name, String? email}) {
    return Profile(name: name ?? this.name, email: email ?? this.email);
  }

  @override
  List<Object?> get props => [name, email];
}
