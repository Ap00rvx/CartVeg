import 'package:cart_veg/config/constant/constant.dart';
import 'package:cart_veg/model/user_order_model.dart';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

class UserOrderService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: BASE_URL,
    connectTimeout: Duration(seconds: 15),
    receiveTimeout: Duration(seconds: 15),
  ));

  Future<Either<String, List<UserOrder>>> getUserOrders(String userId) async {
    try {
      final response = await _dio.get("order/userOrders?userId=$userId");
      if (response.statusCode == 200) {
        final json = response.data["data"];
        return right((json as List).map((e) => UserOrder.fromJson(e)).toList());
      } else {
        return left("Failed to load user orders");
      }
    } catch (e) {
      print(e);
      return left("Failed to load user orders");
    }
  }
}
