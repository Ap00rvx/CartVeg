part of 'order_bloc.dart';

abstract class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object?> get props => [];
}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrderCreated extends OrderState {
  final CreateOrderResponse response;

  const OrderCreated({required this.response});

  @override
  List<Object?> get props => [response];
}

class OrderError extends OrderState {
  final String errorMessage;

  const OrderError({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}