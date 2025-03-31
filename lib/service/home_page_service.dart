import 'package:cart_veg/config/constant/constant.dart';
import 'package:cart_veg/model/product_model.dart';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

class HomePageService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: BASE_URL,
    connectTimeout: Duration(seconds: 15),
    receiveTimeout: Duration(seconds: 15),
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
        _categories.addAll(List<String>.from(response.data["categories"]));
        return _categories;
      } else {
        throw Exception("Failed to load categories");
      }
    } catch (e) {
      print("Error fetching categories: $e");
      throw Exception("Failed to load categories");
    }
  }

  // Initial load of products
  Future<Either<String, List<Product>>> getProducts({String category = ""}) async {
    // Reset pagination state for new queries
    clearProducts();
    return loadMoreProducts(category: category);
  }
  
  // Function to load more products with pagination
  Future<Either<String, List<Product>>> loadMoreProducts({String category = ""}) async {
  if (isLoading || !hasMoreData) {
    return right(_products);
  }

  try {
    isLoading = true;

    final response = await _dio.get("product/?page=$currentPage&category=$category");

    if (response.statusCode == 200) {
      final paginationData = response.data["data"]["pagination"];
      totalPages = paginationData["totalPages"];
      int fetchedPage = paginationData["currentPage"]; // Use the API response for accuracy

      // Parse products
      final newProducts = (response.data["data"]["products"] as List)
          .map((product) => Product.fromJson(product))
          .toList();

      if (newProducts.isNotEmpty) {
        _products.addAll(newProducts);
        currentPage = fetchedPage + 1; // Only increment if products were fetched
      }

      // Check if there are more pages left
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
  // Refresh products (resets to first page)
  Future<Either<String, List<Product>>> refreshProducts({String category = ""}) async {
    clearProducts();
    return getProducts(category: category);
  }
}