part of 'user_order_bloc.dart';

sealed class UserOrderState extends Equatable {
  const UserOrderState();

  @override
  List<Object> get props => [];
}

final class UserOrderInitial extends UserOrderState {}

final class UserOrderLoading extends UserOrderState {}

final class UserOrderSuccess extends UserOrderState {
  final List<UserOrder> orders;

  const UserOrderSuccess(this.orders);

  @override
  List<Object> get props => [orders];
}

final class UserOrderFailure extends UserOrderState {
  final String errorMessage;

  const UserOrderFailure(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}