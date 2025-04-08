part of 'authentication_bloc_bloc.dart';

@immutable
sealed class AuthenticationBlocState {}

final class AuthenticationBlocInitial extends AuthenticationBlocState {}

final class AuthenticationBlocLoading extends AuthenticationBlocState {}

final class AuthenticationBlocSuccess extends AuthenticationBlocState {
  final String successMessage;

  AuthenticationBlocSuccess(this.successMessage);
}

final class VerifyOtpSuccess extends AuthenticationBlocState {
  final VerifyOtpResponse response;

  VerifyOtpSuccess(this.response);
}

final class SaveUserDetailsSuccess extends AuthenticationBlocState {}

final class AuthenticationBlocFailure extends AuthenticationBlocState {
  final String errorMessage;

  AuthenticationBlocFailure(this.errorMessage);
}

final class VerifyTokenSuccess extends AuthenticationBlocState {
  final bool response;

  VerifyTokenSuccess(this.response);
}

final class UserDetailsSuccess extends AuthenticationBlocState {
  final User user;

  UserDetailsSuccess({required this.user});


}