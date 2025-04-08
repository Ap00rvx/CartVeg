import 'package:cart_veg/config/constant/constant.dart';
import 'package:cart_veg/model/coupon_model.dart';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

class CouponService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: BASE_URL,
    connectTimeout: Duration(seconds: 15),
    receiveTimeout: Duration(seconds: 15),
  ));

  Future<Either<String, List<Coupon>>> getCoupons() async {
    try {
      final response = await _dio.get("coupon");
      if (response.statusCode == 200) {
        final List<Coupon> coupons = (response.data as List)
            .map((json) => Coupon.fromJson(json))
            .toList();
        return right(coupons);
      } else {
        return left("Failed to fetch coupons");
      }
    } catch (e) {
      print("Error in getCoupons: $e");
      return left("Failed to fetch coupons");
    }
  }

  Future<Either<String, String>> applyCoupon(
      String couponCode, String userid, int cartTotal) async {
    final data = {
      "couponCode": couponCode,
      "userId": userid,
      "cartTotal": cartTotal,
    };
    print(data);
    try {
      final response = await _dio.post("coupon/apply", data: data);
      print(response.data);
      if (response.statusCode == 200) {
        return right(response.data["message"]);
      } else {
        return left("Failed to apply coupon");
      }
    } on DioException catch (e) {
      print("Error in applyCoupon: ${e.response}");
      return left("Failed to apply coupon");
    }
  }

  Future<Either<String, String>> removeCoupon(
      String couponCode, String userId) async {
    try {
      final response = await _dio.post("coupon/remove", data: {
        "couponCode": couponCode,
        "userId": userId,
      });
      print(response.data["message"]);
      if (response.statusCode == 200) {
        return right(response.data["message"]);
      } else {
        return left("Failed to remove coupon");
      }
    } catch (e) {
      print("Error in removeCoupon: $e");
      return left("Failed to remove coupon");
    }
  }
}
