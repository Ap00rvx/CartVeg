// product_bloc.dart
import 'package:cart_veg/locator.dart';
import 'package:cart_veg/pages/home/home_page.dart';
import 'package:cart_veg/service/home_page_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cart_veg/model/product_model.dart';

// Events
abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object> get props => [];
}

class LoadProducts extends ProductEvent {
  final String category;

  const LoadProducts({this.category = ""});

  @override
  List<Object> get props => [category];
}

class LoadMoreProducts extends ProductEvent {
  final String category;

  const LoadMoreProducts({this.category = ""});

  @override
  List<Object> get props => [category];
}

class RefreshProducts extends ProductEvent {
  final String category;

  const RefreshProducts({this.category = ""});

  @override
  List<Object> get props => [category];
}

// States
abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object> get props => [];
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductsLoaded extends ProductState {
  final List<Product> products;
  final bool hasMore;
  final bool isLoadingMore;
  final String category;

  const ProductsLoaded({
    required this.products,
    required this.hasMore,
    this.isLoadingMore = false,
    this.category = "",
  });

  ProductsLoaded copyWith({
    List<Product>? products,
    bool? hasMore,
    bool? isLoadingMore,
    String? category,
  }) {
    return ProductsLoaded(
      products: products ?? this.products,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      category: category ?? this.category,
    );
  }

  @override
  List<Object> get props => [products, hasMore, isLoadingMore, category];
}

class ProductError extends ProductState {
  final String message;

  const ProductError(this.message);

  @override
  List<Object> get props => [message];
}

// BLoC
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final HomePageService homePageService;

  ProductBloc({required this.homePageService}) : super(ProductInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<LoadMoreProducts>(_onLoadMoreProducts);
    on<RefreshProducts>(_onRefreshProducts);
  }

  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());

    try {
      final result =
          await homePageService.getProducts(category: event.category);

      result.fold(
        (error) => emit(ProductError(error)),
        (products) => emit(ProductsLoaded(
          products: products,
          hasMore: homePageService.hasMoreData,
          category: event.category,
        )),
      );
    } catch (e) {
      emit(ProductError('Failed to load products: ${e.toString()}'));
    }
  }

  Future<void> _onLoadMoreProducts(
    LoadMoreProducts event,
    Emitter<ProductState> emit,
  ) async {
    final currentState = state;

    if (currentState is ProductsLoaded) {
      if (!currentState.hasMore || currentState.isLoadingMore) {
        return;
      }

      emit(currentState.copyWith(isLoadingMore: true));

      try {
        final result =
            await homePageService.loadMoreProducts(category: event.category);

        result.fold(
          (error) => emit(ProductError(error)),
          (products) => emit(ProductsLoaded(
            products: products,
            hasMore: homePageService.hasMoreData,
            isLoadingMore: false,
            category: event.category,
          )),
        );
      } catch (e) {
        emit(ProductError('Failed to load more products: ${e.toString()}'));
      }
    }
  }

  Future<void> _onRefreshProducts(
    RefreshProducts event,
    Emitter<ProductState> emit,
  ) async {
    try {
      final result =
          await homePageService.refreshProducts(category: event.category);

      result.fold(
        (error) => emit(ProductError(error)),
        (products) => emit(ProductsLoaded(
          products: products,
          hasMore: homePageService.hasMoreData,
          category: event.category,
        )),
      );
    } catch (e) {
      emit(ProductError('Failed to refresh products: ${e.toString()}'));
    }
  }
}
