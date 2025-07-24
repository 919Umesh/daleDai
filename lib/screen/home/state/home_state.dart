import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:omspos/screen/home/api/home_api.dart';
import 'package:omspos/screen/home/model/home_model.dart';
import 'package:omspos/screen/home/model/property_model.dart';
import 'package:omspos/services/location/location_service.dart';
import 'package:omspos/utils/custom_log.dart';

class HomeState extends ChangeNotifier {
  HomeState() {
    _getCurrentLocation();
  }

  BuildContext? _context;
  BuildContext? get context => _context;

  set getContext(BuildContext value) {
    _context = value;
    initialize();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<AreaModel> _areas = [];
  List<AreaModel> get areas => _areas;

  List<PropertyModel> _properties = [];
  List<PropertyModel> get properties => _properties;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Map and location related variables
  final MapController _mapController = MapController();
  MapController get mapController => _mapController;

  LatLng? _currentPosition;
  LatLng? get currentPosition => _currentPosition;

  bool _isLoadingLocation = true;
  bool get isLoadingLocation => _isLoadingLocation;

  Future<void> initialize() async {
    await clean();
    await loadAllAreas();
    await loadProperties();
  }

  Future<void> clean() async {
    _isLoading = false;
    _errorMessage = null;
    _areas = [];
    _properties = [];
    notifyListeners();
  }

  Future<void> _getCurrentLocation() async {
    try {
      _isLoadingLocation = true;
      notifyListeners();

      final lat = await LocationService.getLatitude();
      final lng = await LocationService.getLongitude();

      if (lat != null && lng != null) {
        _currentPosition = LatLng(double.parse(lat), double.parse(lng));
        // Center map on current location
        _mapController.move(_currentPosition!, 14.0);
      } else {
        // Default to Kathmandu if location not available
        _currentPosition = const LatLng(27.7172, 85.3240);
      }
    } catch (e) {
      CustomLog.errorLog(value: 'Location error: $e');
      // Fallback to default location
      _currentPosition = const LatLng(27.7172, 85.3240);
    } finally {
      _isLoadingLocation = false;
      notifyListeners();
    }
  }

  Future<void> loadAllAreas() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      _areas = await HomeApi.getAllAreas();
      _errorMessage = null;
      CustomLog.successLog(value: 'Loaded ${_areas.length} areas');
    } catch (e) {
      _errorMessage = e.toString();
      _areas = [];
      CustomLog.errorLog(value: 'Areas load error: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadProperties() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      _properties = await HomeApi.getAllProperties();
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

  Future<void> refreshAreas() async {
    await loadAllAreas();
  }

  Future<void> refreshProperties() async {
    await loadProperties();
    await _getCurrentLocation();
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
}
