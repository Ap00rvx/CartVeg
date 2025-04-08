import 'package:cart_veg/locator.dart';
import 'package:cart_veg/model/product_model.dart';

import 'package:cart_veg/service/search_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cart_veg/config/constant/constant.dart';

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

/// EVENTS
abstract class SearchEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Event to Fetch Products from API
class FetchSearchProducts extends SearchEvent {}

/// Event to Search in the List
class SearchQueryChanged extends SearchEvent {
  final String query;

  SearchQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

/// STATES
abstract class SearchState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Initial State
class SearchInitial extends SearchState {}

/// Loading State
class SearchLoading extends SearchState {}

/// Success State with List of Products
class SearchLoaded extends SearchState {
  final List<Product> products;

  SearchLoaded(this.products);

  @override
  List<Object?> get props => [products];
}

/// Error State
class SearchError extends SearchState {
  final String message;

  SearchError(this.message);

  @override
  List<Object?> get props => [message];
}

/// BLOC
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchService searchService;
  final Dio _dio = Dio(BaseOptions(
    baseUrl: BASE_URL,
    connectTimeout: Duration(seconds: 15),
    receiveTimeout: Duration(seconds: 15),
  ));

  List<Product> _searchProductList = [];

  SearchBloc({required this.searchService}) : super(SearchInitial()) {
    on<FetchSearchProducts>(_fetchProducts);
    on<SearchQueryChanged>(_searchProducts);
  }

  /// Fetch Products from API
  Future<void> _fetchProducts(
      FetchSearchProducts event, Emitter<SearchState> emit) async {
    emit(SearchLoading());
    try {
        final products = await locator.get<SearchService>().fetchSearchProductList();
        _searchProductList = products;
        emit(SearchLoaded(_searchProductList));
      
    } catch (e) {
      emit(SearchError("Error fetching products: $e"));
    }
  }

  /// Search Query Filtering
  void _searchProducts(SearchQueryChanged event, Emitter<SearchState> emit) {
    final query = event.query.toLowerCase();
    final filteredList = _searchProductList
        .where((product) => product.name.toLowerCase().contains(query))
        .toList();
    emit(SearchLoaded(filteredList));
  }
}
