part of 'store_bloc.dart';

sealed class StoreEvent extends Equatable {
  const StoreEvent();

  @override
  List<Object> get props => [];
}
final class FetchStoreEvent extends StoreEvent {
  final double latitude;
  final double longitude;

  const FetchStoreEvent({
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object> get props => [latitude, longitude];
}
