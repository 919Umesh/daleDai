import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:omspos/screen/home/api/home_api.dart';
import 'package:omspos/screen/home/model/home_model.dart';
import 'package:omspos/screen/home/model/property_model.dart';
import 'package:omspos/services/location/location_service.dart';
import 'package:omspos/utils/custom_log.dart';

class HomeState extends ChangeNotifier {
  HomeState();

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

  LatLng? _currentPosition;

  bool _isLoadingLocation = true;

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
  }
}
