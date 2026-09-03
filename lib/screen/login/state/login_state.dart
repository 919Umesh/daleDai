import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:omspos/screen/login/api/login_api.dart';
import 'package:omspos/services/api/supabase_helper.dart';
import 'package:omspos/services/router/router_name.dart';
import 'package:omspos/services/sharedPreference/preference_keys.dart';
import 'package:omspos/services/sharedPreference/sharedPref_service.dart';
import 'package:omspos/utils/custom_log.dart';

class LoginState extends ChangeNotifier {
  LoginState();

  late BuildContext _context;
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get obscurePassword => _obscurePassword;
  TextEditingController get emailController => _emailController;
  TextEditingController get passwordController => _passwordController;
  GlobalKey<FormState> get formKey => _formKey;

  set getContext(BuildContext value) {
    _context = value;
    _initialize();
  }

  void _initialize() {
    CustomLog.successLog(value: '------------LoginState--------------');
    CustomLog.successLog(value: 'Login State has been initialized');
    _emailController.clear();
    _passwordController.clear();
  }

  bool _isSignUpMode = false;
  final TextEditingController _nameController = TextEditingController();

  bool get isSignUpMode => _isSignUpMode;
  TextEditingController get nameController => _nameController;

  void toggleAuthMode() {
    _isSignUpMode = !_isSignUpMode;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  /// Sign in using Google OAuth and navigate on success
  Future<void> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final response = await SupabaseProvider.signWithGoogle();
      if (response['error'] == true) {
        _errorMessage = response['message'] ?? 'Google sign-in failed';
        Fluttertoast.showToast(
          msg: _errorMessage!,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        );
        CustomLog.errorLog(value: 'Google login error: $_errorMessage');
      } else {
        // Assume successful login returns userId and email
        final userId = response['userId'];
        final email = response['email'];
        await SharedPrefService.setValue<String>(PrefKey.userId, userId);
        await SharedPrefService.setValue<bool>(PrefKey.isLogin, true);
        Fluttertoast.showToast(
          msg: 'Login successful',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
        _context.go(indexScreenPath);
      }
    } catch (e) {
      _errorMessage = 'Unexpected error during Google sign-in';
      Fluttertoast.showToast(
        msg: _errorMessage!,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
      CustomLog.errorLog(value: 'Google login exception: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
        CustomLog.successLog(
            value: '-----------------UserId-------------------');
        CustomLog.successLog(value: authModel.userId);
        await SharedPrefService.setValue<String>(
            PrefKey.userId, authModel.userId);
        await SharedPrefService.setValue<bool>(PrefKey.isLogin, true);
        _context.go(indexScreenPath);
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

  Future<void> signUp(String email, String password, String name) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final authModel = await AuthAPI.signUp(email: email, password: password, name: name);
      if (authModel.error) {
        _errorMessage = authModel.message ?? 'Sign up failed';
        Fluttertoast.showToast(
          msg: _errorMessage!,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        );
        CustomLog.errorLog(value: 'Sign up error: $_errorMessage');
      } else {
        Fluttertoast.showToast(
          msg: 'Sign up successful! Logging in...',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
        await SharedPrefService.setValue<String>(PrefKey.userId, authModel.userId);
        await SharedPrefService.setValue<bool>(PrefKey.isLogin, true);
        _context.go(indexScreenPath);
      }
    } catch (e) {
      _errorMessage = 'An unexpected error occurred during sign up';
      Fluttertoast.showToast(
        msg: _errorMessage!,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
      CustomLog.errorLog(value: 'Sign up exception: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }
}
