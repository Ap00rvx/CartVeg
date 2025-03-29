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

final class AuthenticationBlocFailure extends AuthenticationBlocState {
  final String errorMessage;

  AuthenticationBlocFailure(this.errorMessage);
}
