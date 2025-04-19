import 'package:cart_veg/locator.dart';
import 'package:cart_veg/service/location_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


part 'location_event.dart';
part 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final LocationService _locationService = locator.get<LocationService>(); 

  LocationBloc() : super(const LocationInitial()) {
    on<FetchLocation>(_onFetchLocation);
  }

  
  

  Future<void> _onFetchLocation(
    FetchLocation event,
    Emitter<LocationState> emit,
  ) async {
    emit(const LocationLoading());
    try {
      Map<String, double> latLong = await _locationService.getCurrentLatLong();
      print('Latitude: ${latLong['latitude']}, Longitude: ${latLong['longitude']}');
      emit(LocationLoaded(
        latitude: latLong['latitude']!,
        longitude: latLong['longitude']!,
      ));
    } catch (e) {
      emit(LocationError(message: e.toString()));
    }
  }
}