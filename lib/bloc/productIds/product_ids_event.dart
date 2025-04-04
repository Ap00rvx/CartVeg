part of 'product_ids_bloc.dart';

sealed class ProductIdsEvent extends Equatable {
  const ProductIdsEvent();

  @override
  List<Object> get props => [];
}


final class ProductIdsFetchEvent extends ProductIdsEvent {}