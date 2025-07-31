import 'package:flutter/widgets.dart';
import 'package:omspos/screen/profile/api/profile_api.dart';
import 'package:omspos/screen/profile/model/user_model.dart';
import 'package:omspos/services/sharedPreference/preference_keys.dart';
import 'package:omspos/services/sharedPreference/sharedPref_service.dart';
import 'package:omspos/utils/custom_log.dart';

class ProfileState extends ChangeNotifier {
  ProfileState();

  BuildContext? _context;
  BuildContext? get context => _context;

  set getContext(BuildContext value) {
    _context = value;
    initialize();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  UserModel? _user;
  UserModel? get user => _user;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> initialize() async {
    await clean();
    await loadUserProfile();
  }

  Future<void> clean() async {
    _isLoading = false;
    _errorMessage = null;
    _user = null;
    notifyListeners();
  }

  Future<void> loadUserProfile() async {
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

      _user = await UserAPI.getUserById(userId.toString());
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

  Future<void> refreshProfile() async {
    await loadUserProfile();
  }

  Future<void> logout() async {
    try {
      await SharedPrefService.clearAll();
      if (_context != null && _context!.mounted) {
        Navigator.of(_context!).pushNamedAndRemoveUntil(
          '/loginPath',
          (Route<dynamic> route) => false,
        );
      }

      CustomLog.successLog(value: 'User logged out successfully');
    } catch (e) {
      CustomLog.errorLog(value: 'Logout error: $e');
      _errorMessage = 'Failed to logout. Please try again.';
      notifyListeners();
    }
  }
}
