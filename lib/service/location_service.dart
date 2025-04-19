import 'package:location/location.dart' as location;
import 'package:permission_handler/permission_handler.dart' as perm;

class LocationService {
  final location.Location _location = location.Location();

  double latitude = 0.0;
  double longitude = 0; 

  /// Checks location services, requests permissions, and gets the current latitude and longitude.
  /// Returns a map with 'latitude' and 'longitude' keys if successful.
  /// Throws [LocationServiceException] if services are disabled, permissions are denied, or fetching fails.
  Future<Map<String, double>> getCurrentLatLong() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          throw LocationServiceException('Location services are disabled.');
        }
      }

      // Check current permission status using permission_handler
      perm.PermissionStatus status =
          await perm.Permission.locationWhenInUse.status;
      if (status.isPermanentlyDenied) {
        // Open app settings if permission is permanently denied
        await perm.openAppSettings();
        throw LocationServiceException(
            'Location permission is permanently denied. Please enable in settings.');
      }

      // Request permission using location plugin
      location.PermissionStatus permission = await _location.hasPermission();
      if (permission == location.PermissionStatus.denied) {
        permission = await _location.requestPermission();
        if (permission != location.PermissionStatus.granted) {
          throw LocationServiceException('Location permission not granted.');
        }
      }

      // Get current position
      location.LocationData locationData = await _location.getLocation();
      if (locationData.latitude == null || locationData.longitude == null) {
        throw LocationServiceException(
            'Failed to retrieve valid location data.');
      }

      latitude = locationData.latitude!; 
      longitude = locationData.longitude! ; 

      return {
        'latitude':latitude,
        'longitude':longitude,
      };
    } catch (e) {
      throw LocationServiceException(
          'Failed to get latitude and longitude: $e');
    }
  }
}

/// Custom exception for location service errors.
class LocationServiceException implements Exception {
  final String message;

  LocationServiceException(this.message);

  @override
  String toString() => 'LocationServiceException: $message';
}
