import 'package:cart_veg/config/constant/constant.dart';
import 'package:cart_veg/locator.dart';
import 'package:cart_veg/model/create_order_model.dart';
import 'package:cart_veg/service/authentication_service.dart';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

class OrderService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: BASE_URL,
    connectTimeout: Duration(seconds: 15),
    receiveTimeout: Duration(seconds: 15),
  ));

  Future<Either<String, CreateOrderResponse>> handleCreateOrder(
      String phone,
      Map<String, dynamic> deliveryAddress,
      bool isCashOnDelivery,
      List<Map<String, dynamic>> products) async {
    final userId = locator.get<AuthenticationService>().user!.id;
    try {
      final data = {
        "userId": userId,
        "phone": phone,
        "products": products,
        "isCashOnDelivery": isCashOnDelivery,
        "deliveryAddress": deliveryAddress
      };
      print(data);
      final response = await _dio.post("order/create", data: data);

      if (response.statusCode == 201) {
        final json = response.data;
        return right(CreateOrderResponse.fromJson(json));
      } else {
        return const Left("Failed to Create order");
      }
    } catch (err) {
      if (err is DioException) {
        print(err.response);
        return Left(err.message.toString());
      }
      return Left(err.toString());
    }
  }
}
