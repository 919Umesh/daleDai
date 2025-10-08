import 'package:geolocator/geolocator.dart';
import 'package:omspos/utils/custom_log.dart';

class LocationService {
  static Position? _currentPosition;

  static Future<void> initialize() async {
    await _checkLocationService();
    await _handleLocationPermission();
    await getCurrentLocation();
  }

  static Future<bool> _checkLocationService() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    CustomLog.actionLog(value: "Location service enabled: $serviceEnabled");

    if (!serviceEnabled) {
      CustomLog.actionLog(value: "Requesting to enable location services");
      return false;
    }
    return true;
  }

  static Future<bool> _handleLocationPermission() async {
    bool serviceEnabled = await _checkLocationService();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    CustomLog.actionLog(value: "Current permission status: $permission");

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        CustomLog.actionLog(value: "Location permissions are denied");
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      CustomLog.actionLog(value: "Location permissions are permanently denied");
      return false;
    }

    CustomLog.actionLog(value: "Location permissions granted");
    return true;
  }

  static Future<Position?> getCurrentLocation() async {
    try {
      bool hasPermission = await _handleLocationPermission();
      if (!hasPermission) return null;

      if (_currentPosition != null &&
          DateTime.now().difference(_currentPosition!.timestamp!) <
              Duration(minutes: 5)) {
        return _currentPosition;
      }

      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      CustomLog.actionLog(
          value: "Fetched new location: ${_currentPosition!.toJson()}");
      return _currentPosition;
    } catch (e) {
      CustomLog.errorLog(value: "Error getting location: $e");
      return null;
    }
  }

  // Get current latitude
  static Future<String?> getLatitude() async {
    Position? position = await getCurrentLocation();
    return position?.latitude.toString();
  }

  // Get current longitude
  static Future<String?> getLongitude() async {
    Position? position = await getCurrentLocation();
    return position?.longitude.toString();
  }

  // Get last known position (might be null)
  static Future<Position?> getLastKnownPosition() async {
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (e) {
      CustomLog.errorLog(value: "Error getting last known position: $e");
      return null;
    }
  }
}


// // To get current location anywhere in your app:
// Position? position = await LocationService.getCurrentLocation();
// if (position != null) {
//   print('Latitude: ${position.latitude}');
//   print('Longitude: ${position.longitude}');
// } else {
//   // Handle case where location isn't available
// }

// // Or use the convenience methods:
// String? lat = await LocationService.getLatitude();
// String? lng = await LocationService.getLongitude();


// bool hasPermission = await LocationService._handleLocationPermission();
// if (!hasPermission) {
//   // Show explanation or redirect to settings
// }