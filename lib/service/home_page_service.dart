import 'package:cart_veg/config/constant/constant.dart';
import 'package:cart_veg/locator.dart';
import 'package:cart_veg/model/product_model.dart';
import 'package:cart_veg/service/location_service.dart';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

class HomePageService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: BASE_URL,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
  ));

  final List<Product> _products = [];
  final List<String> _categories = [];

  // Pagination state
  int currentPage = 1;
  int totalPages = 1;
  bool isLoading = false;
  bool hasMoreData = true;

  // Get the current product list
  List<Product> get products => _products;

  // Clear products when changing filters or refreshing
  void clearProducts() {
    _products.clear();
    currentPage = 1;
    hasMoreData = true;
  }

  // Check if more data can be loaded
  bool get canLoadMore => hasMoreData && !isLoading;

  Future<List<String>> getCategories() async {
    try {
      if (_categories.isNotEmpty) {
        return _categories;
      }

      final response = await _dio.get("common/categories");
      if (response.statusCode == 200) {
        _categories
            .addAll(List<String>.from(response.data["categories"] ?? []));
        return _categories;
      } else {
        throw Exception("Failed to load categories: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching categories: $e");
      throw Exception("Failed to load categories");
    }
  }

  // Initial load of products
  Future<Either<String, List<Product>>> getProducts(
      {String category = ""}) async {
    clearProducts();
    return loadMoreProducts(category: category);
  }

  // Function to load more products with pagination
  Future<Either<String, List<Product>>> loadMoreProducts(
      {String category = ""}) async {
    if (isLoading || !hasMoreData) {
      print(
          "Skipping loadMoreProducts: isLoading=$isLoading, hasMoreData=$hasMoreData");
      return right(_products);
    }

    try {
      isLoading = true;
      print("Fetching products for page $currentPage, category: $category");

      // Get location with fallback
      Map<String, double> location;
      try {
        final lat = locator.get<LocationService>().latitude;
        final long = locator.get<LocationService>().longitude;
        location = {"latitude": lat, "longitude": long};
      } catch (e) {
        print("Location error: $e");
        location = {"latitude": 0.0, "longitude": 0.0}; // Fallback
      }
      print("Location: $location");

      final response = await _dio
          .get(
            "product/?page=$currentPage&category=$category&latitude=${location["latitude"]}&longitude=${location["longitude"]}&limit=100",
          )
          .timeout(Duration(seconds: 15));
      print(
          "API Response: Status=${response.statusCode}, Data=${response.data}");

      if (response.statusCode == 200) {
        if (response.data is! Map<String, dynamic> ||
            response.data["data"] == null) {
          print("Invalid API response format: ${response.data}");
          return left("Invalid API response format");
        }

        final paginationData =
            response.data["data"]["pagination"] as Map<String, dynamic>?;
        final productList = response.data["data"]["products"] as List<dynamic>?;

        if (paginationData == null || productList == null) {
          print("Missing pagination or products data");
          return left("Missing pagination or products data");
        }

        totalPages = paginationData["totalPages"] as int? ?? 1;
        final fetchedPage =
            paginationData["currentPage"] as int? ?? currentPage;
        print(
            "Pagination: totalPages=$totalPages, fetchedPage=$fetchedPage, products=${productList.length}");

        final newProducts =
            productList.map((product) => Product.fromJson(product)).toList();
        if (newProducts.isNotEmpty) {
          _products.addAll(newProducts);
          currentPage = fetchedPage + 1;
        } else {
          print("No new products fetched");
        }

        hasMoreData = currentPage <= totalPages && newProducts.isNotEmpty;
        print(
            "Updated state: currentPage=$currentPage, hasMoreData=$hasMoreData");
        return right(_products);
      } else {
        print("API error: Status=${response.statusCode}");
        return left("Failed to load products: ${response.statusCode}");
      }
    } on LocationServiceException catch (e) {
      print("LocationServiceException: ${e.message}");
      return left(e.message);
    } on DioException catch (e) {
      print("DioException: ${e.message}, Response: ${e.response?.data}");
      return left("Network error: ${e.message}");
    } catch (e) {
      print("Unexpected error: $e");
      return left("Failed to load products: $e");
    } finally {
      isLoading = false;
      print("loadMoreProducts complete, isLoading=$isLoading");
    }
  }

  // Refresh products (resets to first page)
  Future<Either<String, List<Product>>> refreshProducts(
      {String category = ""}) async {
    clearProducts();
    return loadMoreProducts(category: category);
  }
}
