import 'package:cart_veg/config/constant/constant.dart';
import 'package:cart_veg/locator.dart';
import 'package:cart_veg/service/location_service.dart';
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

      if(currentProducts.isNotEmpty) {
        return right(currentProducts);
      }
      final location = await locator.get<LocationService>().getCurrentLatLong();
      
      final response = await _dio.get('product/list',queryParameters: {
        "latitude": location["latitude"],
        "longitude": location["longitude"],
      });

      final list = response.data["data"]["products"] as List;
      currentProducts = list.where((product) {
        return product["availability"] == true; 
      }).toList().map((e) => e["_id"]).toList();
      return currentProducts.isNotEmpty
          ? right(currentProducts)
          : left("No products found");
    } catch (err) {
      print("Error in getCurrentProducts: $err");
      return left("Failed to get current products");
    }
  }
}
