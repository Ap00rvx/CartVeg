part of 'product_ids_bloc.dart';

sealed class ProductIdsState extends Equatable {
  const ProductIdsState();

  @override
  List<Object> get props => [];
}

final class ProductIdsInitial extends ProductIdsState {}

final class ProductIdsLoading extends ProductIdsState {}

final class ProductIdsLoaded extends ProductIdsState {
  final List<dynamic> productIds;
  const ProductIdsLoaded({required this.productIds});

  @override
  List<Object> get props => [productIds];
}

final class ProductIdsError extends ProductIdsState {
  final String errorMessage;
  const ProductIdsError({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}
