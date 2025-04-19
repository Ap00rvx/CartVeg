part of 'location_bloc.dart';

abstract class LocationEvent {
  const LocationEvent();
}


class FetchLocation extends LocationEvent {
  const FetchLocation();
}