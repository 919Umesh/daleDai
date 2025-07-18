import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:omspos/services/sharedPreference/preference_keys.dart';
import 'package:omspos/services/sharedPreference/sharedPref_service.dart';
import 'package:omspos/utils/custom_log.dart';
import '../../services/router/router_name.dart';

class SplashState with ChangeNotifier {
  SplashState();

  late final BuildContext _context;
  set getContext(BuildContext context) {
    _context = context;
    _initialize();
  }

  Future<void> _initialize() async {
    await _startTimer();
  }

  Future<void> _startTimer() async {
    await Future.delayed(const Duration(seconds: 3));
    await _navigateUser();
  }

  Future<void> _navigateUser() async {
    try {
      await SharedPrefService.setValue<bool>(PrefKey.loginSuccess, true);
      final isLoggedIn = await SharedPrefService.getValue<bool>(
            PrefKey.loginSuccess,
            defaultValue: false,
          ) ??
          false;
      CustomLog.successLog(value: '------------------IsLogin-----------');
      CustomLog.successLog(value: isLoggedIn.toString());
      _context.go(isLoggedIn ? loginPath : homeScreenPath);
    } catch (e) {
      debugPrint('Error during navigation: $e');
      _context.go(loginPath);
    }
  }
}
