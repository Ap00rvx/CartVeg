import 'package:cart_veg/config/constant/constant.dart';
import 'package:cart_veg/model/search_product_model.dart';
import 'package:dio/dio.dart';

class SearchService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: BASE_URL,
    connectTimeout: Duration(seconds: 15),
    receiveTimeout: Duration(seconds: 15),
  ));

  List<SearchProductModel> _searchProductList = [];
  List<SearchProductModel> _filteredSearchList = [];

  Future<List<SearchProductModel>> fetchSearchProductList() async {
    try {
      final response = await _dio.get('/product/list');
      if (response.statusCode == 200) {
        final List data = response.data['data'];
        if (data.isEmpty) {
          return []; // Return empty list if no data found
        }
        print("Data: $data");
        _searchProductList =
            data.map((e) => SearchProductModel.fromJson(e)).toList();
        _filteredSearchList = List.from(
            _searchProductList); // Initially, filtered list = full list

        return _filteredSearchList;
      } else {
        throw Exception('Failed to load search products');
      }
    } catch (e) {
      print('Error fetching search products: $e');
      throw Exception('Failed to load search products');
    }
  }

  /// Function to filter the search results
  void filterSearchResults(String query) {
    if (query.isEmpty) {
      _filteredSearchList = List.from(_searchProductList);
    } else {
      _filteredSearchList = _searchProductList
          .where((product) =>
              product.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  /// Getter for filtered search results
  List<SearchProductModel> get searchResults => _filteredSearchList;
}
