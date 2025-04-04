import 'package:bloc/bloc.dart';
import 'package:cart_veg/model/user_order_model.dart';
import 'package:cart_veg/service/user_order_serice.dart';
import 'package:equatable/equatable.dart';

part 'user_order_event.dart';
part 'user_order_state.dart';

class UserOrderBloc extends Bloc<UserOrderEvent, UserOrderState> {
  UserOrderBloc() : super(UserOrderInitial()) {
    final UserOrderService userOrderService = UserOrderService();
   on<FetchUserOrders>((event, emit) async {
  emit(UserOrderLoading());
  try {
    final response = await userOrderService.getUserOrders(event.userId);
    response.fold(
      (error) => emit(UserOrderFailure(error)),
      (orders) => emit(UserOrderSuccess(orders)),
    );
  } catch (error) {
    emit(UserOrderFailure(error.toString()));
  }
});
  }
}
