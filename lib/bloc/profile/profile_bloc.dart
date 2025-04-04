import 'package:bloc/bloc.dart';
import 'package:cart_veg/locator.dart';
import 'package:cart_veg/model/verify_otp_model.dart';
import 'package:cart_veg/service/authentication_service.dart';
import 'package:equatable/equatable.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileInitial()) {
    final authenticationservice = AuthenticationService();
    on<GetProfileEvent>((event, emit) {
      try {
        final user = locator.get<AuthenticationService>().user;

        if (user != null) {
          emit(ProfileLoaded(user));
        } else {
          emit(ProfileError("User not found"));
        }
      } catch (e) {
        emit(ProfileError("Failed to load profile"));
      }
    });
  }
}
