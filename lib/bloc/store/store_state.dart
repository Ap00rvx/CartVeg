part of 'store_bloc.dart';

sealed class StoreState extends Equatable {
  const StoreState();
  
  @override
  List<Object> get props => [];
}

final class StoreInitial extends StoreState {}
final class StoreLoaded extends StoreState {
  final NearestStoreResponse nearestStoreResponse;
  const StoreLoaded({required this.nearestStoreResponse});
  
  @override
  List<Object> get props => [nearestStoreResponse];
}
final class StoreLoading extends StoreState {}
final class StoreError extends StoreState {
  final String message;
  const StoreError({required this.message});
  
  @override
  List<Object> get props => [message];
}