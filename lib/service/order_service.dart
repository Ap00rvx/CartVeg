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
    List<Map<String, dynamic>> products,
    int shippingAmount, {
    String? couponId,
    String? couponCode,
    int? couponDiscount,
  }) async {
    final userId = locator.get<AuthenticationService>().user!.id;
    

    try {
      // Base data for the request
      final data = {
        "userId": userId,
        "phone": phone,
        "products": products,
        "shippingAmount": shippingAmount,
        "isCashOnDelivery": isCashOnDelivery,
        "deliveryAddress": deliveryAddress,
      };

      // Conditionally add appliedCoupon only if any coupon field is provided
      if (couponId != null || couponCode != null || couponDiscount != null) {
        data["appliedCoupon"] = {
          "couponId": couponId,
          "code": couponCode,
          "discountAmount": couponDiscount, // Match backend field name
        };
      }

      print(
          "Request data: $data"); // For debugging; replace with proper logging in production

      final response = await _dio.post("order/create", data: data);

      if (response.statusCode == 201) {
        final json = response.data;
        return right(CreateOrderResponse.fromJson(json));
      } else {
        return left(
            "Failed to create order: Unexpected status code ${response.statusCode}");
      }
    } catch (err) {
      print("Error in handleCreateOrder: $err");
      return left("Failed to create order: ${err.toString()}");
    }
  }

// Helper function to calculate totalAmount (assuming frontend handles this)
  int calculateTotalAmount(List<Map<String, dynamic>> products,
      int shippingAmount, int? couponDiscount) {
    final subtotal = products.fold<int>(
      0,
      (sum, item) =>
          sum +
          (item["quantity"] as int) *
              (item["price"]
                  as int), // Adjust based on actual product structure
    );
    final discount = couponDiscount ?? 0;
    return subtotal + shippingAmount - discount;
  }
}
