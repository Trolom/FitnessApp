import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'profile_service.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  StreamSubscription? _profileSubscription;

  ProfileBloc() : super(ProfileInitial()) {
    on<LoadProfile>((event, emit) {
      emit(ProfileLoading());
      _profileSubscription?.cancel();
      _profileSubscription = ProfileService.streamProfile().listen(
        (profile) => add(ProfileChanged(profile)),
      );
    });

    on<ProfileChanged>((event, emit) => emit(ProfileLoaded(event.profile)));

    on<UpdateProfileEvent>((event, emit) async {
      try {
        await ProfileService.saveProfile(event.profile);
      } catch (e) {
        emit(ProfileError(e.toString()));
      }
    });
  }

  @override
  Future<void> close() {
    _profileSubscription?.cancel();
    return super.close();
  }
}