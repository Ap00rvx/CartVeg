part of 'authentication_bloc_bloc.dart';

@immutable
sealed class AuthenticationBlocEvent {}

class SendOtpToEmailEvent extends AuthenticationBlocEvent {
  final String email;

  SendOtpToEmailEvent(this.email);
}

class VerifyOtpEvent extends AuthenticationBlocEvent {
  final String otp;
  final String email; 
  VerifyOtpEvent(this.otp, this.email);
}
