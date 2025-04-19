import 'package:cart_veg/config/constant/constant.dart';
import 'package:cart_veg/locator.dart';
import 'package:cart_veg/model/categories_model.dart';
import 'package:cart_veg/model/product_model.dart';
import 'package:cart_veg/service/common_service.dart';
import 'package:cart_veg/service/location_service.dart';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

class CategoryService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: BASE_URL,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
  ));

  final List<Product> _products = [];
  final List<String> _categories = [];

  int currentPage = 1;
  int totalPages = 1;
  bool isLoading = false;
  bool hasMoreData = true;

  List<Product> get products => _products;
  List<String> get categories => _categories;

  void clearProducts() {
    _products.clear();
    currentPage = 1;
    hasMoreData = true;
  }

  bool get canLoadMore => hasMoreData && !isLoading;

  Future<List<Category>> getCategories() async {
    try {
      final categories = await locator.get<CommonService>().getCategories();
      return categories.fold(
        (error) {
          print("Error fetching categories: $error");
          throw Exception("Failed to load categories");
        },
        (categoryList) {
          _categories
              .addAll(categoryList.categories.map((e) => e.name).toList());
          return categoryList.categories;
        },
      );
    } catch (e) {
      print("Error fetching categories: $e");
      throw Exception("Failed to load categories");
    }
  }

  Future<Either<String, List<Product>>> getProducts(
      {String category = "Vegetable"}) async {
    clearProducts();
    return loadMoreProducts(category: category);
  }

  Future<Either<String, List<Product>>> loadMoreProducts(
      {String category = "Vegetable"}) async {
    if (isLoading || !hasMoreData) {
      return right(_products);
    }
    final location = await locator.get<LocationService>().getCurrentLatLong();

    try {
      isLoading = true;

      final response = await _dio.get(
        "product/",
        queryParameters: {
          'page': currentPage,
          'limit': 10,
          'sort': 'price',
          'order': 'asc',
          'category': category,
          'latitude': location["latitude"],
          'longitude': location["longitude"],
        },
      );

      print("Response ------> : ${response.data}");

      if (response.statusCode == 200) {
        final paginationData = response.data["data"]["pagination"];
        totalPages = paginationData["totalPages"];
        int fetchedPage = paginationData["currentPage"];
        print("heloe ->>"+response.data["data"]["products"].toString());
        final newProducts = (response.data["data"]["products"] as List)
            .map((product) => Product.fromJson(product))
            .toList();
        // print("New Products: $newProducts");

        if (newProducts.isNotEmpty) {
          _products.addAll(newProducts);
          currentPage = fetchedPage + 1;
        }

        hasMoreData = currentPage <= totalPages;

        isLoading = false;
        return right(_products);
      } else {
        isLoading = false;
        return left("Failed to load products");
      }
    } catch (e) {
      isLoading = false;
      print("Error fetching products: $e");
      return left("Failed to load products");
    }
  }

  Future<Either<String, List<Product>>> refreshProducts(
      {String category = "Vegetable"}) async {
    clearProducts();
    return getProducts(category: category);
  }
}
