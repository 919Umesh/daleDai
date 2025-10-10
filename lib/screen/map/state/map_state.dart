import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:omspos/screen/map/api/map_api.dart';
import 'package:omspos/screen/map/model/location_view_model.dart';
import 'package:omspos/screen/map/model/map_model.dart';
import 'package:omspos/services/location/location_service.dart';
import 'package:omspos/utils/custom_log.dart';

class MapState extends ChangeNotifier {
  MapState();

  BuildContext? _context;
  BuildContext? get context => _context;
  set getContext(BuildContext value) {
    _context = value;
    networkSuccess();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _hasInternet = true;
  bool get hanInternet => _hasInternet;

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

  Future<void> networkSuccess() async {
    _isLoading = true;
    notifyListeners();
    CustomLog.successLog(value: '--------------Internet-----------------');
    await initialize();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> netWorkFailed() async {
    _hasInternet = false;
    _errorMessage = 'No Internet Connection';
    notifyListeners();
  }

  Future<void> initialize() async {
    await _getCurrentLocation();
    await loadProperties();
  }

  Future<void> loadProperties() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      _properties = await MapLocationApi.getAllProperties();
      _errorMessage = null;
      CustomLog.successLog(value: 'Loaded ${_properties.length} properties');
    } catch (e) {
      _errorMessage = e.toString();
      _properties = [];
      CustomLog.errorLog(value: 'Properties load error: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadLocations() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      _locations = await MapLocationApi.getLocations();
      _errorMessage = null;
      CustomLog.successLog(value: 'Loaded ${_locations.length} properties');
    } catch (e) {
      _errorMessage = e.toString();
      _locations = [];
      CustomLog.errorLog(value: 'Properties load error: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> centerMapOnUserLocation() async {
    if (_currentPosition != null) {
      _mapController.move(_currentPosition!, 14.0);
    } else {
      await _getCurrentLocation();
      if (_currentPosition != null) {
        _mapController.move(_currentPosition!, 14.0);
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      _isLoadingLocation = true;
      notifyListeners();

      final lat = await LocationService.getLatitude();
      final lng = await LocationService.getLongitude();

      if (lat != null && lng != null) {
        _currentPosition = LatLng(double.parse(lat), double.parse(lng));
        _mapController.move(_currentPosition!, 14.0);
      } else {
        _currentPosition =
            const LatLng(27.7172, 85.3240); // Default to Kathmandu
      }
    } catch (e) {
      CustomLog.errorLog(value: 'Location error: $e');
      _currentPosition = const LatLng(27.7172, 85.3240);
    } finally {
      _isLoadingLocation = false;
      notifyListeners();
    }
  }

  Future<void> refreshProperties() async {
    await loadProperties();
  }
}
