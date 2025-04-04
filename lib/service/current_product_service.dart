import 'package:cart_veg/config/constant/constant.dart';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

class CurrentProductService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: BASE_URL,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
  ));

  List<dynamic> currentProducts = [];

  Future<Either<String, List<dynamic>>> getCurrentProducts() async {
    try {
     
      final response = await _dio.get('product/ids');

      final list = response.data as List;
      currentProducts = list;
      return currentProducts.isNotEmpty
          ? right(currentProducts)
          : left("No products found");
    } catch (err) {
      print("Error in getCurrentProducts: $err");
      return left("Failed to get current products");
    }
  }
}
