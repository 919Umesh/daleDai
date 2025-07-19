import 'package:flutter/foundation.dart';
import 'package:omspos/screen/home/model/property_model.dart';
import 'package:omspos/screen/properties/api/properties_api.dart';
import 'package:omspos/utils/custom_log.dart';

class PropertiesState extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<PropertyModel> _properties = [];
  List<PropertyModel> get properties => _properties;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _currentAreaId;
  String? get currentAreaId => _currentAreaId;

  Future<void> loadAllProperties() async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      _properties = await PropertiesApi.getAllProperties();
      _errorMessage = null;
      _currentAreaId = null;
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
  Future<void> loadPropertiesByArea(String areaId) async {
    if (_isLoading) return;

    _isLoading = true;
    _currentAreaId = areaId;
    notifyListeners();

    try {
      _properties = await PropertiesApi.getPropertiesByArea(areaId);
      _errorMessage = null;
      CustomLog.successLog(
          value: 'Loaded ${_properties.length} properties for area $areaId');
    } catch (e) {
      _errorMessage = e.toString();
      _properties = [];
      CustomLog.errorLog(value: 'Area properties load error: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshProperties() async {
    if (_currentAreaId != null) {
      await loadPropertiesByArea(_currentAreaId!);
    } else {
      await loadAllProperties();
    }
  }
}
