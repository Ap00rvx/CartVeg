import 'package:bloc/bloc.dart';
import 'package:cart_veg/locator.dart';
import 'package:cart_veg/model/verify_otp_model.dart';
import 'package:cart_veg/service/authentication_service.dart';
import 'package:cart_veg/service/current_product_service.dart';
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
        final response =
            await locator.get<AuthenticationService>().sendOTPToEmail(email);
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
        final response =
            await locator.get<AuthenticationService>().verifyOTP(otp, email);
        response.fold(
          (errorMessage) => emit(AuthenticationBlocFailure(errorMessage)),
          (succesResponse) => emit(VerifyOtpSuccess(succesResponse)),
        );
      } catch (err) {
        emit(AuthenticationBlocFailure("Failed to verify OTP"));
      }
    });
    on<SaveUserDetailsEvent>((event, emit) async {
      try {
        final name = event.name;
        final email = event.email;
        final phone = event.phone;
        emit(AuthenticationBlocLoading());
        final response = await locator
            .get<AuthenticationService>()
            .saveUserDetails(name, phone, email);
        response.fold(
          (errorMessage) => emit(AuthenticationBlocFailure(errorMessage)),
          (successMessage) => emit(SaveUserDetailsSuccess()),
        );
      } catch (err) {
        emit(AuthenticationBlocFailure("Failed to save user details"));
      }
    });
    on<VerifyTokenEvent>((event, emit) async {
      try {
        emit(AuthenticationBlocLoading());
        final response =
            await locator.get<AuthenticationService>().isTokenValid();
        if (response) {
          await locator.get<AuthenticationService>().getUserDetails();
          await locator.get<CurrentProductService>().getCurrentProducts();
          emit(VerifyTokenSuccess(true));
        } else {
          emit(VerifyTokenSuccess(false));
        }
      } catch (err) {
        emit(AuthenticationBlocFailure("Failed to verify token"));
      }
    });
  }
}
