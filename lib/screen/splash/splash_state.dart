import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:omspos/services/location/location_service.dart';
import 'package:omspos/services/sharedPreference/preference_keys.dart';
import 'package:omspos/services/sharedPreference/sharedPref_service.dart';
import '../../services/router/router_name.dart';

class SplashState with ChangeNotifier {
  SplashState();

  late final BuildContext _context;
  Timer? _timer;
  bool _isDisposed = false;
  set getContext(BuildContext context) {
    _context = context;
    _initialize();
  }

  Future<void> _initialize() async {
    await _startTimer();
  }

  Future<void> _startTimer() async {
    _timer = Timer(const Duration(seconds: 2), () async {
      if (_isDisposed) return;
      await LocationService.initialize();
      await _navigateUser();
    });
  }

  Future<void> _navigateUser() async {
    try {
      if (_isDisposed) return;

      final isLoggedIn = await SharedPrefService.getValue<bool>(
            PrefKey.isLogin,
            defaultValue: false,
          ) ??
          false;

      if (!_isDisposed) {
        _context.go(isLoggedIn ? indexScreenPath : loginPath);
      }
    } catch (e) {
      debugPrint('Error during navigation: $e');
      if (!_isDisposed) {
        _context.go(loginPath);
      }
    }
  }

  void dispose() {
    _isDisposed = true;
    _timer?.cancel();
    _timer = null;
  }
}
