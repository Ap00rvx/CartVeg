part of 'category_bloc.dart';





abstract class CategoryState {
  final List<String> categories;
  final List<Product> products;
  final bool isLoading;
  final bool hasMoreData;

  CategoryState({
    required this.categories,
    required this.products,
    required this.isLoading,
    required this.hasMoreData,
  });
}

class CategoryInitial extends CategoryState {
  CategoryInitial()
      : super(
          categories: [],
          products: [],
          isLoading: false,
          hasMoreData: true,
        );
}

class CategoryLoading extends CategoryState {
  CategoryLoading({
    required super.categories,
    required super.products,
    required super.hasMoreData,
  }) : super(isLoading: true);
}

class CategoryLoaded extends CategoryState {
  final String selectedCategory;

  CategoryLoaded({
    required super.categories,
    required super.products,
    required super.isLoading,
    required super.hasMoreData,
    required this.selectedCategory,
  });
}

class CategoryError extends CategoryState {
  final String error;
  
  CategoryError({
    required this.error,
    required super.categories,
    required super.products,
    required super.hasMoreData,
  }) : super(isLoading: false);
}