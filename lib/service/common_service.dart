import 'package:cart_veg/config/constant/constant.dart';
import 'package:cart_veg/model/categories_model.dart';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

class CommonService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: BASE_URL,
    connectTimeout: Duration(seconds: 15),
    receiveTimeout: Duration(seconds: 15),
  ));
  CategoriesResponse? _categoriesResponse;
  Future<Either<String, CategoriesResponse>> getCategories() async {
    if (_categoriesResponse != null) {
      print("Returning cached categories response");
      print(_categoriesResponse!.toJson());
      return right(_categoriesResponse!);
    }
    try {
      final response = await _dio.get("category/");
      if (response.statusCode == 200) {
        final json = response.data;
        _categoriesResponse = CategoriesResponse.fromJson(json);
        return right(_categoriesResponse!);
      } else {
        return left("Failed to fetch categories");
      }
    } catch (e) {
      print("Error in getCategories: $e");
      return left("Failed to fetch categories");
    }
  }

  CategoriesResponse? get categoriesResponse => _categoriesResponse;
}
