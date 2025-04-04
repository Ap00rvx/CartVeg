part of 'order_bloc.dart';

sealed class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object> get props => [];
}

final class OrderInitial extends OrderState {}

final class OrderLoading extends OrderState {}

final class OrderCreated extends OrderState {
  final CreateOrderResponse response;

  const OrderCreated({required this.response});
}

final class OrderError extends OrderState {
  final String errorMessage;

  const OrderError({required this.errorMessage});
}
