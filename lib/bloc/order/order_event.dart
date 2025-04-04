part of 'order_bloc.dart';

sealed class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object> get props => [];
}

class CreateOrderEvent extends OrderEvent {
  final String phone;
  final Map<String, dynamic> deliveryAddress;
  final bool isCashOnDelivery;
  final List<Map<String, dynamic>> products;
  const CreateOrderEvent(
      {required this.deliveryAddress,
      required this.phone,
      required this.isCashOnDelivery,
      required this.products});
}
