import 'package:geolocator/geolocator.dart';
import 'package:omspos/utils/custom_log.dart';

class LocationService {
  static Position? _currentPosition;
  
  // Initialize location services and check permissions
  static Future<void> initialize() async {
    await _checkLocationService();
    await _handleLocationPermission();
    await getCurrentLocation();
  }

  // Check if location services are enabled
  static Future<bool> _checkLocationService() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    CustomLog.actionLog(value: "Location service enabled: $serviceEnabled");
    
    if (!serviceEnabled) {
      // Open location settings if service is disabled
      CustomLog.actionLog(value: "Requesting to enable location services");
      await Geolocator.openLocationSettings();
      return false;
    }
    return true;
  }

  // Handle location permissions
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
      // You might want to show a dialog explaining why you need permissions
      // and direct the user to app settings
      return false;
    }

    CustomLog.actionLog(value: "Location permissions granted");
    return true;
  }

  // Get current location with caching
  static Future<Position?> getCurrentLocation() async {
    try {
      bool hasPermission = await _handleLocationPermission();
      if (!hasPermission) return null;

      // Use cached position if available and not too old (e.g., less than 5 minutes old)
      if (_currentPosition != null && 
          DateTime.now().difference(_currentPosition!.timestamp!) < Duration(minutes: 5)) {
        return _currentPosition;
      }

      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      CustomLog.actionLog(value: "Fetched new location: ${_currentPosition!.toJson()}");
      return _currentPosition;
    } catch (e) {
      CustomLog.errorLog(value: "Error getting location: $e");
      return null;
    }
  }

  // Get latitude
  static Future<String?> getLatitude() async {
    Position? position = await getCurrentLocation();
    return position?.latitude.toString();
  }

  // Get longitude
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