import 'package:cart_veg/config/constant/constant.dart';
import 'package:cart_veg/locator.dart';
import 'package:cart_veg/model/store_response_model.dart';
import 'package:cart_veg/service/location_service.dart';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

class StoreService {
   final Dio _dio = Dio(BaseOptions(
    baseUrl: BASE_URL,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
  ));

  Future<Either<String, NearestStoreResponse>> getNearestStore() async {
    final latitude = locator.get<LocationService>().latitude; 
    final longitude = locator.get<LocationService>().longitude; 
    try {
      final response = await _dio.get("product/store",queryParameters: {
        "latitude": latitude,
        "longitude": longitude,
      });
      if (response.statusCode == 200) {
        return Right(NearestStoreResponse.fromJson(response.data));
      } else {
        return Left("Failed to load nearest store: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching nearest store: $e");
      return Left("Failed to load nearest store");
    }
  }
}