import 'package:bloc/bloc.dart';
import 'package:cart_veg/locator.dart';
import 'package:cart_veg/model/product_model.dart';
import 'package:cart_veg/service/category_service.dart';
part 'category_event.dart';
part 'category_state.dart';

class CategoryPageBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryService _categoryService = locator<CategoryService>();

  CategoryPageBloc() : super(CategoryInitial()) {
    on<FetchInitialData>(_onFetchInitialData);
    on<LoadMoreProducts>(_onLoadMoreProducts);
    on<RefreshProducts>(_onRefreshProducts);
  }

  Future<void> _onFetchInitialData(
      FetchInitialData event, Emitter<CategoryState> emit) async {
    try {
      emit(CategoryLoading(
        categories: state.categories,
        products: state.products,
        hasMoreData: state.hasMoreData,
      ));

      final categories = await _categoryService.getCategories();
      final productsResult =
          await _categoryService.getProducts(category: "Vegetable");

      productsResult.match(
        (error) => emit(CategoryError(
          error: error,
          categories: categories,
          products: [],
          hasMoreData: false,
        )),
        (products) => emit(CategoryLoaded(
          categories: categories,
          products: products,
          isLoading: false,
          hasMoreData: _categoryService.hasMoreData,
          selectedCategory: "Vegetable",
        )),
      );
    } catch (e) {
      emit(CategoryError(
        error: e.toString(),
        categories: state.categories,
        products: state.products,
        hasMoreData: state.hasMoreData,
      ));
    }
  }

  Future<void> _onLoadMoreProducts(
      LoadMoreProducts event, Emitter<CategoryState> emit) async {
    try {
      emit(CategoryLoading(
        categories: state.categories,
        products: state.products,
        hasMoreData: state.hasMoreData,
      ));

      final result =
          await _categoryService.loadMoreProducts(category: event.category);

      result.match(
        (error) => emit(CategoryError(
          error: error,
          categories: state.categories,
          products: state.products,
          hasMoreData: _categoryService.hasMoreData,
        )),
        (products) => emit(CategoryLoaded(
          categories: state.categories,
          products: products,
          isLoading: false,
          hasMoreData: _categoryService.hasMoreData,
          selectedCategory: event.category,
        )),
      );
    } catch (e) {
      emit(CategoryError(
        error: e.toString(),
        categories: state.categories,
        products: state.products,
        hasMoreData: state.hasMoreData,
      ));
    }
  }

  Future<void> _onRefreshProducts(
      RefreshProducts event, Emitter<CategoryState> emit) async {
    try {
      emit(CategoryLoading(
        categories: state.categories,
        products: state.products,
        hasMoreData: state.hasMoreData,
      ));

      final result =
          await _categoryService.refreshProducts(category: event.category);

      result.match(
        (error) => emit(CategoryError(
          error: error,
          categories: state.categories,
          products: [],
          hasMoreData: false,
        )),
        (products) => emit(CategoryLoaded(
          categories: state.categories,
          products: products,
          isLoading: false,
          hasMoreData: _categoryService.hasMoreData,
          selectedCategory: event.category,
        )),
      );
    } catch (e) {
      emit(CategoryError(
        error: e.toString(),
        categories: state.categories,
        products: state.products,
        hasMoreData: state.hasMoreData,
      ));
    }
  }
}
