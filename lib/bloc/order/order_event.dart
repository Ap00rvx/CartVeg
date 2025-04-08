part of 'order_bloc.dart';

sealed class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object?> get props => []; // Changed to List<Object?> to allow null values
}

class CreateOrderEvent extends OrderEvent {
  final String phone;
  final Map<String, dynamic> deliveryAddress;
  final bool isCashOnDelivery;
  final List<Map<String, dynamic>> products;
  final int shippingAmount;
  final String? couponId; // Optional coupon fields
  final String? couponCode;
  final int? couponDiscount;

  const CreateOrderEvent({
    required this.phone,
    required this.deliveryAddress,
    required this.isCashOnDelivery,
    required this.products,
    required this.shippingAmount,
    this.couponId, // Optional
    this.couponCode, // Optional
    this.couponDiscount, // Optional
  });

  @override
  List<Object?> get props => [
        phone,
        deliveryAddress,
        isCashOnDelivery,
        products,
        shippingAmount,
        couponId,
        couponCode,
        couponDiscount,
      ];
}