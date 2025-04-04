part of 'user_order_bloc.dart';

sealed class UserOrderEvent extends Equatable {
  const UserOrderEvent();

  @override
  List<Object> get props => [];
}

final class FetchUserOrders extends UserOrderEvent {
  final String userId;

  const FetchUserOrders(this.userId);

  @override
  List<Object> get props => [userId];
}