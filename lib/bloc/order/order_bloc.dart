import 'package:bloc/bloc.dart';
import 'package:cart_veg/model/create_order_model.dart';
 // Adjusted to match your import
import 'package:cart_veg/service/order_service.dart';
import 'package:equatable/equatable.dart';

part 'order_event.dart';
part 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderService orderService; // Made it a final field for better practice

  OrderBloc() : orderService = OrderService(), super(OrderInitial()) {
    on<CreateOrderEvent>((event, emit) async {
      emit(OrderLoading());
      try {
        final response = await orderService.handleCreateOrder(
          event.phone,
          event.deliveryAddress,
          event.isCashOnDelivery,
          event.products,
          event.shippingAmount,
          couponId: event.couponId, // Pass optional coupon fields
          couponCode: event.couponCode,
          couponDiscount: event.couponDiscount,
        );
        response.fold(
          (error) => emit(OrderError(errorMessage: error)),
          (data) => emit(OrderCreated(response: data)),
        );
      } catch (e) {
        emit(OrderError(errorMessage: e.toString()));
      }
    });
  }
}