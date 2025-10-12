import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:latlong2/latlong.dart';
import 'package:omspos/screen/map/api/map_api.dart';
import 'package:omspos/screen/map/model/location_view_model.dart';
import 'package:omspos/screen/map/model/map_model.dart';
import 'package:omspos/services/location/location_service.dart';
import 'package:omspos/utils/connection_status.dart';
import 'package:omspos/utils/custom_log.dart';

class MapState extends ChangeNotifier {
  MapState();

  BuildContext? _context;
  BuildContext? get context => _context;
  set getContext(BuildContext value) {
    _context = value;
    checkConnection();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _hasInternet = true;
  bool get hasInternet => _hasInternet;

  final MapController _mapController = MapController();
  MapController get mapController => _mapController;

  List<MapModel> _properties = [];
  List<MapModel> get properties => _properties;

  List<LocationView> _locations = [];
  List<LocationView> get locations => _locations;

  LatLng? _currentPosition;
  LatLng? get currentPosition => _currentPosition;

  bool _isLoadingLocation = false;
  bool get isLoadingLocation => _isLoadingLocation;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Check if internet is available, then initialize map data
  Future<void> checkConnection() async {
    bool network = await CheckNetwork.check();
    if (network) {
      await networkSuccess();
    } else {
      await networkFailed();
    }
  }

  Future<void> networkSuccess() async {
    _hasInternet = true;
    _errorMessage = null;
    await initialize();
  }

  Future<void> networkFailed() async {
    _hasInternet = false;
    _errorMessage = 'No Internet Connection';
    notifyListeners();
  }

  /// Initialize location and map data
  Future<void> initialize() async {
    await getCurrentLocation();
    await loadLocations();
  }

  Future<void> getCurrentLocation() async {
    try {
      _isLoadingLocation = true;
      notifyListeners();

      await LocationService.initialize();

      final lat = await LocationService.getLatitude();
      final lng = await LocationService.getLongitude();

      if (lat != null && lng != null) {
        _currentPosition = LatLng(double.parse(lat), double.parse(lng));
        CustomLog.successLog(
            value: "Current position: $_currentPosition (from GPS)");
      } else {
        // Fallback to Kathmandu if location is not available
        _currentPosition = const LatLng(27.7172, 85.3240);
        Fluttertoast.showToast(
            msg: "Location unavailable. Using default location (Kathmandu).");
      }
    } catch (e) {
      CustomLog.errorLog(value: 'Location error: $e');
      _currentPosition = const LatLng(27.7172, 85.3240);
      Fluttertoast.showToast(
          msg: "Unable to access location. Check permissions or GPS.");
    } finally {
      _isLoadingLocation = false;
      notifyListeners();
    }
  }

  /// Load nearby or saved map locations from API
  Future<void> loadLocations() async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      _locations = await MapLocationApi.getLocations();
      _errorMessage = null;
      CustomLog.successLog(value: 'Loaded ${_locations.length} map locations');
    } catch (e) {
      _errorMessage = e.toString();
      _locations = [];
      CustomLog.errorLog(value: 'Error loading map locations: $_errorMessage');
      Fluttertoast.showToast(msg: "Failed to load locations: $_errorMessage");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Helper: Center map to current position if available
  void moveToCurrentLocation() {
    if (_currentPosition != null) {
      _mapController.move(_currentPosition!, 14.0);
    } else {
      Fluttertoast.showToast(
          msg: "Current location not available to move the map.");
    }
  }
}
