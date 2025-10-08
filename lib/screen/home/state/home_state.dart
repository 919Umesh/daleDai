import 'package:flutter/widgets.dart';
import 'package:omspos/screen/home/api/home_api.dart';
import 'package:omspos/screen/home/model/home_model.dart';
import 'package:omspos/screen/home/model/property_model.dart';
import 'package:omspos/screen/profile/api/profile_api.dart';
import 'package:omspos/screen/profile/model/user_model.dart';
import 'package:omspos/services/sharedPreference/preference_keys.dart';
import 'package:omspos/services/sharedPreference/sharedPref_service.dart';
import 'package:omspos/utils/connection_status.dart';
import 'package:omspos/utils/custom_log.dart';

class HomeState extends ChangeNotifier {
  HomeState();

  BuildContext? _context;
  BuildContext? get context => _context;
  set getContext(BuildContext value) {
    _context = value;
    checkConnection();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _hasInternet = true;
  bool get hanInternet => _hasInternet;

  List<AreaModel> _areas = [];
  List<AreaModel> get areas => _areas;

  UserModel? _user;
  UserModel? get user => _user;

  List<PropertyModel> _properties = [];
  List<PropertyModel> get properties => _properties;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> checkConnection() async {
    bool network = await CheckNetwork.check();
    if (network) {
      await networkSuccess();
    } else {
      await netWorkFailed();
    }
  }

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
    await clean();
    await loadProfile();
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

  Future<void> loadAllAreas({bool? isRefresh}) async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      _areas = await HomeApi.getAllAreas(isRefresh ?? false);
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

  Future<void> loadProfile({bool? isRefresh}) async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      final userId = await SharedPrefService.getValue<String>(
        PrefKey.userId,
        defaultValue: "-",
      );

      if (userId == "-") {
        throw Exception('User not authenticated');
      }
      _user = await UserAPI.getUserById(userId.toString(), isRefresh ?? false);
      _errorMessage = null;
      CustomLog.successLog(value: 'Profile loaded for user: ${_user?.email}');
    } catch (e) {
      _errorMessage = e.toString();
      CustomLog.errorLog(value: 'Profile load error: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadProperties({bool? isRefresh}) async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      _properties = await HomeApi.getAllProperties(isRefresh ?? false);
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

  Future<void> retry() async {
    await checkConnection();
  }

  Future<void> refreshAreas() async {
    await loadAllAreas(isRefresh: true);
  }

  Future<void> refreshProperties() async {
    await loadProperties(isRefresh: true);
  }

  Future<void> refreshProfile() async {
    await loadProfile(isRefresh: true);
  }
}
