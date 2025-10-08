import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:omspos/screen/properties/api/properties_api.dart';
import 'package:omspos/screen/properties/model/properties_model.dart';
import 'package:omspos/utils/connection_status.dart';
import 'package:omspos/utils/custom_log.dart';

class PropertiesState extends ChangeNotifier {
  PropertiesState();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _hasInternet = true;
  bool get hasInternet => _hasInternet;

  List<PropertiesModel> _properties = [];
  List<PropertiesModel> get properties => _properties;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _currentAreaId;
  String? get currentAreaId => _currentAreaId;

  Future<void> fetchProperties({String? areaId}) async {
    await checkConnection(areaId: areaId);
  }

  Future<void> checkConnection({String? areaId}) async {
    bool network = await CheckNetwork.check();
    if (network) {
      await networkSuccess(areaId: areaId);
    } else {
      await netWorkFailed();
    }
  }

  Future<void> networkSuccess({String? areaId}) async {
    CustomLog.successLog(value: '--------------HRFHFGHFGH-----------------');
    if (areaId != null && areaId.isNotEmpty) {
      await loadPropertiesByArea(areaId);
    } else {
      await loadAllProperties();
    }
  }

  Future<void> netWorkFailed() async {
    _hasInternet = false;
    _errorMessage = 'No Internet Connection';
    notifyListeners();
  }

  Future<void> loadAllProperties({bool refresh = false}) async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      _properties = await PropertiesApi.getAllProperties(isRefresh: refresh);
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

  Future<void> loadPropertiesByArea(String areaId,
      {bool refresh = false}) async {
    debugPrint('-----------AreaId-------------');
    if (_isLoading) return;
    _isLoading = true;
    _currentAreaId = areaId;
    notifyListeners();

    try {
      _properties =
          await PropertiesApi.getPropertiesByArea(areaId, isRefresh: refresh);
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

  Future<void> retry() async {
    if (_currentAreaId != null) {
      await fetchProperties(areaId: _currentAreaId);
    } else {
      await fetchProperties();
    }
  }
}
