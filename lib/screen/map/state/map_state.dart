import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:omspos/screen/home/model/property_model.dart';
import 'package:omspos/screen/map/api/map_api.dart';
import 'package:omspos/services/location/location_service.dart';
import 'package:omspos/utils/custom_log.dart'; // Assuming you have this

class MapState extends ChangeNotifier {
  BuildContext? _context;
  BuildContext? get context => _context;

  set getContext(BuildContext value) {
    _context = value;
    initialize();
  }

  final MapController _mapController = MapController();
  MapController get mapController => _mapController;

  List<PropertyModel> _properties = [];
  List<PropertyModel> get properties => _properties;

  List<Marker> _markers = [];
  List<Marker> get markers => _markers;

  LatLng? _currentPosition;
  LatLng? get currentPosition => _currentPosition;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingLocation = false;
  bool get isLoadingLocation => _isLoadingLocation;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;


  Future<void> initialize() async {
    await _getCurrentLocation();
    await loadProperties();
  }


  Future<void> loadProperties() async {
    if (_isLoading) return;
    _isLoading = true;
    _errorMessage = null; // Clear previous errors
    notifyListeners();

    try {
      _properties = await MapLocationApi.getAllProperties();
      
      // Generate markers for the loaded properties
      _generateMarkers();
      
      CustomLog.successLog(value: 'Loaded ${_properties.length} properties for map');
    } catch (e) {
      _errorMessage = e.toString();
      _properties = [];
      _markers = []; // Clear markers on error
      CustomLog.errorLog(value: 'Properties load error: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _generateMarkers() {
    _markers = _properties.map((property) {
      return Marker(
        point: LatLng(property.latitude, property.longitude),
        width: 44,
        height: 44,
        child: GestureDetector(
          onTap: () {
            // Handle marker tap, e.g., show bottom sheet or navigate
            if (_context != null) {
              _showPropertyDetails(property, _context!);
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: property.isActive ? Colors.green : Colors.orange,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                ),
              ],
            ),
            child: Icon(
              _getPropertyIcon(property.propertyType),
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      );
    }).toList();
  }

  // Helper to determine marker icon based on property type
  IconData _getPropertyIcon(String propertyType) {
    switch (propertyType.toLowerCase()) {
      case 'house':
        return Icons.house;
      case 'apartment':
        return Icons.apartment;
      case 'condo':
        return Icons.domain;
      default:
        return Icons.location_city; // Default icon
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
      
      // Assuming LocationService.getLatitude() and getLongitude() are implemented
      final lat = await LocationService.getLatitude();
      final lng = await LocationService.getLongitude();
      
      if (lat != null && lng != null) {
        _currentPosition = LatLng(double.parse(lat), double.parse(lng));
        // Optionally center map immediately
        // _mapController.move(_currentPosition!, 14.0); 
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

  Future<void> refreshMap() async {
    await loadProperties(); // Reload properties and markers
    // Optionally re-center or adjust zoom if needed after refresh
    if (_currentPosition != null) {
       _mapController.move(_currentPosition!, _mapController.camera.zoom); // Keep current zoom
    }
  }

  // Placeholder for showing property details
  void _showPropertyDetails(PropertyModel property, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Tapped on: ${property.title}")),
    );
    // You can implement a bottom sheet or navigation to property details here
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}
