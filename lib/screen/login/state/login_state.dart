import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:omspos/screen/login/api/login_api.dart';
import 'package:omspos/screen/login/model/login_model.dart';
import 'package:omspos/services/router/router_name.dart';
import 'package:omspos/utils/custom_log.dart';

class LoginState extends ChangeNotifier {
  LoginState();

  late BuildContext _context;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  set getContext(BuildContext value) {
    _context = value;
    _initialize();
  }

  _initialize() {
    CustomLog.successLog(value: '------------LoginState--------------');
    CustomLog.successLog(value: 'Login State has been initialized');
  }

  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final authModel = await AuthAPI.signIn(email: email, password: password);

      if (authModel.error) {
        _errorMessage = authModel.message ?? 'Login failed';
        Fluttertoast.showToast(
          msg: _errorMessage!,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        );
        CustomLog.errorLog(value: 'Login error: $_errorMessage');
      } else {
        Fluttertoast.showToast(
          msg: 'Login successful',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
        CustomLog.successLog(value: 'Login successful for ${authModel.email}');
        _context.go(homeScreenPath); // Using GoRouter navigation
      }
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
      Fluttertoast.showToast(
        msg: _errorMessage!,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
      CustomLog.errorLog(value: 'Login exception: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
