import 'package:bloc/bloc.dart';
import 'package:cart_veg/model/verify_otp_model.dart';
import 'package:cart_veg/service/authentication_service.dart';
import 'package:meta/meta.dart';

part 'authentication_bloc_event.dart';
part 'authentication_bloc_state.dart';

class AuthenticationBlocBloc
    extends Bloc<AuthenticationBlocEvent, AuthenticationBlocState> {
  AuthenticationBlocBloc() : super(AuthenticationBlocInitial()) {
    final _authenticationService = AuthenticationService();
    on<SendOtpToEmailEvent>((event, emit) async {
      try {
        final email = event.email;
        emit(AuthenticationBlocLoading());
        final response = await _authenticationService.sendOTPToEmail(email);
        response.fold(
          (errorMessage) => emit(AuthenticationBlocFailure(errorMessage)),
          (successMessage) => emit(AuthenticationBlocSuccess(successMessage)),
        );
      } catch (err) {
        emit(AuthenticationBlocFailure("Failed to send OTP"));
      }
    });
    on<VerifyOtpEvent>((
      event,
      emit,
    ) async {
      try {
        final otp = event.otp;
        final email = event.email;
        emit(AuthenticationBlocLoading());
        final response = await _authenticationService.verifyOTP(otp, email);
        response.fold(
          (errorMessage) => emit(AuthenticationBlocFailure(errorMessage)),
          (succesResponse) => emit(VerifyOtpSuccess(succesResponse)),
        );
      } catch (err) {
        emit(AuthenticationBlocFailure("Failed to verify OTP"));
      }
    });
  }
}
