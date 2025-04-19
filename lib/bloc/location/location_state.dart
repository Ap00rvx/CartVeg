part of 'location_bloc.dart';

abstract class LocationState {
  const LocationState();
}

class LocationInitial extends LocationState {
  const LocationInitial();
}

class LocationServiceDisabled extends LocationState {
  const LocationServiceDisabled();
}

class LocationPermissionDenied extends LocationState {
  const LocationPermissionDenied();
}

class LocationLoading extends LocationState {
  const LocationLoading();
}

class LocationLoaded extends LocationState {
  final double latitude;
  final double longitude;

  const LocationLoaded({required this.latitude, required this.longitude});
}

class LocationError extends LocationState {
  final String message;

  const LocationError({required this.message});
}