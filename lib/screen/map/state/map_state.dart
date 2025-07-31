import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:omspos/screen/home/model/property_model.dart';
import 'package:omspos/screen/map/api/map_api.dart';
import 'package:omspos/screen/map/model/map_model.dart';
import 'package:omspos/services/location/location_service.dart';
import 'package:omspos/utils/custom_log.dart';

class MapState extends ChangeNotifier {
  BuildContext? _context;
  final MapController _mapController = MapController();
  List<MapModel> _properties = [];
  LatLng? _currentPosition;
  bool _isLoading = false;
  bool _isLoadingLocation = false;
  String? _errorMessage;

  BuildContext? get context => _context;
  MapController get mapController => _mapController;
  List<MapModel> get properties => _properties;
  LatLng? get currentPosition => _currentPosition;
  bool get isLoading => _isLoading;
  bool get isLoadingLocation => _isLoadingLocation;
  String? get errorMessage => _errorMessage;

  set getContext(BuildContext value) {
    _context = value;
    initialize();
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
