import 'dart:core';

import 'package:bloc/bloc.dart';
import 'package:cart_veg/model/create_order_model.dart';
import 'package:cart_veg/service/order_service.dart';
import 'package:equatable/equatable.dart';

part 'order_event.dart';
part 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  OrderBloc() : super(OrderInitial()) {
    final OrderService orderService = OrderService();
    on<CreateOrderEvent>((event, emit) async {
      final String phone = event.phone;
      final deliveryAddress = event.deliveryAddress;
      final bool isCashOnDelivery = event.isCashOnDelivery;
      final products = event.products;
      emit(OrderLoading());
      try {
        final response = await orderService.handleCreateOrder(
            phone, deliveryAddress, isCashOnDelivery, products);
        response.fold(
          (error) {
            emit(OrderError(errorMessage: error));
          },
          (data) {
            emit(OrderCreated(response: data));
          },
        );
      } catch (e) {
        emit(OrderError(errorMessage: e.toString()));
      }
    });
  }
}
