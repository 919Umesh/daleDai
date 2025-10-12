import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:omspos/screen/profile/api/profile_api.dart';
import 'package:omspos/screen/profile/model/user_model.dart';
import 'package:omspos/services/router/router_name.dart';
import 'package:omspos/services/sharedPreference/preference_keys.dart';
import 'package:omspos/services/sharedPreference/sharedPref_service.dart';
import 'package:omspos/utils/connection_status.dart';
import 'package:omspos/utils/custom_log.dart';

class ProfileState extends ChangeNotifier {
  ProfileState();

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

  UserModel? _user;
  UserModel? get user => _user;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> checkConnection() async {
    final hasNetwork = await CheckNetwork.check();
    if (hasNetwork) {
      await _onNetworkSuccess();
    } else {
      _onNetworkFailure();
    }
  }

  Future<void> _onNetworkSuccess() async {
    _hasInternet = true;
    _errorMessage = null;
    await initialize();
  }

  void _onNetworkFailure() {
    _hasInternet = false;
    _errorMessage = 'No Internet Connection';
    notifyListeners();
  }

  Future<void> initialize() async {
    _resetState();
    await loadUserProfile();
  }

  void _resetState() {
    _isLoading = false;
    _errorMessage = null;
    _user = null;
    notifyListeners();
  }

  Future<void> loadUserProfile({bool isRefresh = false}) async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      final userId = await SharedPrefService.getValue<String>(
        PrefKey.userId,
        defaultValue: "-",
      );

      if (userId == "-" || userId!.isEmpty) {
        throw Exception('User not authenticated');
      }

      _user = await UserAPI.getUserById(userId, isRefresh);
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

  Future<void> logout() async {
    try {
      await SharedPrefService.clearAll();

      if (_context != null && _context!.mounted) {
        GoRouter.of(_context!).go(loginPath);
      }

      CustomLog.successLog(value: 'User logged out successfully');
    } catch (e) {
      CustomLog.errorLog(value: 'Logout error: $e');
      _errorMessage = 'Failed to logout. Please try again.';
      notifyListeners();
    }
  }

  Future<void> refreshProfile() async {
    await loadUserProfile(isRefresh: true);
  }
}
