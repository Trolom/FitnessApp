import 'package:equatable/equatable.dart';
import 'user_profile.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object?> get props => [];
}

class LoadProfile extends ProfileEvent {}
class UpdateProfileEvent extends ProfileEvent {
  final UserProfile profile;
  const UpdateProfileEvent(this.profile);
  @override
  List<Object?> get props => [profile];
}
class ProfileChanged extends ProfileEvent {
  final UserProfile? profile;
  const ProfileChanged(this.profile);
  @override
  List<Object?> get props => [profile];
}



