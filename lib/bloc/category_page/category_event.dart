part of 'category_bloc.dart';
abstract class CategoryEvent {}

class FetchInitialData extends CategoryEvent {}

class LoadMoreProducts extends CategoryEvent {
  final String category;
  LoadMoreProducts(this.category);
}

class RefreshProducts extends CategoryEvent {
  final String category;
  RefreshProducts(this.category);
}