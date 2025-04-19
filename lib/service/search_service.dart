import 'dart:ffi';

import 'package:cart_veg/config/constant/constant.dart';
import 'package:cart_veg/locator.dart';
import 'package:cart_veg/model/product_model.dart';
import 'package:cart_veg/service/location_service.dart';

import 'package:dio/dio.dart';

class SearchService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: BASE_URL,
    connectTimeout: Duration(seconds: 15),
    receiveTimeout: Duration(seconds: 15),
  ));

  List<Product> _searchProductList = [];
  List<Product> _filteredSearchList = [];

  Future<List<Product>> fetchSearchProductList() async {
    try {
      final location = await locator.get<LocationService>().getCurrentLatLong();
      final queryParameters = {
        "latitude": location["latitude"],
        "longitude": location["longitude"],
      };
      final response =
          await _dio.get('/product/list', queryParameters: queryParameters);
      if (response.statusCode == 200) {
        final List data = response.data['data']["products"];
        if (data.isEmpty) {
          return []; // Return empty list if no data found
        }
        print("Data: $data");
        _searchProductList = data
            .map((e) => Product(
                productId: e["_id"],
                quantity: e["quantity"] ?? 0,
                availability: e["availability"] ?? false,
                threshold: e["threshold"] ?? 0,
                details: Details(
                  name: e["name"],
                  description: e["description"],
                  price: e["price"] is int ? e["price"] : int.parse(e["price"] ?? "0"),
                  image: e["image"],
                  category: e["category"],
                  actualPrice: e["actualPrice"] is int ? e["actualPrice"] : int.parse(e["actualPrice"] ?? "0"),
                  shelfLife: e["shelfLife"],
                  origin: e["origin"],
                  // availability: e["availability"],
                  unit: e["unit"],
                  // rating: e["rating"].toDouble(),
                )))
            .toList();
        _filteredSearchList = List.from(
            _searchProductList); // Initially, filtered list = full list

        return _filteredSearchList;
      } else {
        throw Exception('Failed to load search products');
      }
    } catch (e) {
      print('Error fetching search products: ${e.toString()}');
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
              product.details.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  /// Getter for filtered search results
  List<Product> get searchResults => _filteredSearchList;
}
