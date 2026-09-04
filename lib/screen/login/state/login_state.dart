import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:omspos/screen/login/api/login_api.dart';
import 'package:omspos/services/api/supabase_helper.dart';
import 'package:omspos/services/router/router_name.dart';
import 'package:omspos/services/sharedPreference/preference_keys.dart';
import 'package:omspos/services/sharedPreference/sharedPref_service.dart';
import 'package:omspos/utils/custom_log.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  String _accountType = 'tenant';
  final TextEditingController _nameController = TextEditingController();

  bool get isSignUpMode => _isSignUpMode;
  String get accountType => _accountType;
  TextEditingController get nameController => _nameController;

  void toggleAuthMode() {
    _isSignUpMode = !_isSignUpMode;
    notifyListeners();
  }

  void setAccountType(String value) {
    if (value != 'tenant' && value != 'landlord') return;
    _accountType = value;
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
        );
        CustomLog.errorLog(value: 'Google login error: $_errorMessage');
      } else {
        // Assume successful login returns userId and email
        final userId = response['userId'];
        var resolvedRole = response['userType']?.toString() ?? 'tenant';
        if (response['isNewUser'] == true) {
          final selectedRole = await _chooseGoogleAccountRole();
          if (selectedRole == null) {
            await Supabase.instance.client.auth.signOut();
            _errorMessage = 'Choose an account type to finish registration.';
            return;
          }
          await Supabase.instance.client
              .from('users')
              .update({'user_type': selectedRole}).eq('user_id', userId);
          resolvedRole = selectedRole;
        }
        await SharedPrefService.setValue<String>(
            PrefKey.accountRole, resolvedRole);
        await SharedPrefService.setValue<String>(PrefKey.userId, userId);
        await SharedPrefService.setValue<bool>(PrefKey.isLogin, true);
        Fluttertoast.showToast(
          msg: 'Login successful',
          toastLength: Toast.LENGTH_SHORT,
        );
        if (_context.mounted) {
          _context.go(indexScreenPath);
        }
      }
    } catch (e) {
      _errorMessage = 'Unexpected error during Google sign-in';
      Fluttertoast.showToast(
        msg: _errorMessage!,
        toastLength: Toast.LENGTH_LONG,
      );
      CustomLog.errorLog(value: 'Google login exception: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> _chooseGoogleAccountRole() {
    return showDialog<String>(
      context: _context,
      barrierDismissible: false,
      builder: (dialogContext) => PopScope(
        canPop: false,
        child: AlertDialog(
          icon: const Icon(Icons.account_circle_outlined, size: 42),
          title: const Text('Create your profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Choose how you want to use DaleDai. This role is kept for your account.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              _RoleChoice(
                icon: Icons.search,
                title: 'Looking for rent',
                subtitle: 'Find rooms and manage your bookings',
                onTap: () => Navigator.pop(dialogContext, 'tenant'),
              ),
              const SizedBox(height: 10),
              _RoleChoice(
                icon: Icons.real_estate_agent_outlined,
                title: 'Property owner',
                subtitle: 'List properties, units, tenants, and rent',
                onTap: () => Navigator.pop(dialogContext, 'landlord'),
              ),
            ],
          ),
        ),
      ),
    );
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
        );
        CustomLog.errorLog(value: 'Login error: $_errorMessage');
      } else {
        Fluttertoast.showToast(
          msg: 'Login successful',
          toastLength: Toast.LENGTH_SHORT,
        );
        CustomLog.successLog(value: 'Login successful for ${authModel.email}');
        CustomLog.successLog(
            value: '-----------------UserId-------------------');
        CustomLog.successLog(value: authModel.userId);
        await SharedPrefService.setValue<String>(
            PrefKey.userId, authModel.userId);
        await SharedPrefService.setValue<bool>(PrefKey.isLogin, true);
        if (_context.mounted) {
          _context.go(indexScreenPath);
        }
      }
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
      Fluttertoast.showToast(
        msg: _errorMessage!,
        toastLength: Toast.LENGTH_LONG,
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
      final authModel = await AuthAPI.signUp(
        email: email,
        password: password,
        name: name,
        userType: _accountType,
      );
      if (authModel.error) {
        _errorMessage = authModel.message ?? 'Sign up failed';
        Fluttertoast.showToast(
          msg: _errorMessage!,
          toastLength: Toast.LENGTH_LONG,
        );
        CustomLog.errorLog(value: 'Sign up error: $_errorMessage');
      } else {
        Fluttertoast.showToast(
          msg: 'Sign up successful! Logging in...',
          toastLength: Toast.LENGTH_SHORT,
        );
        await SharedPrefService.setValue<String>(
            PrefKey.userId, authModel.userId);
        await SharedPrefService.setValue<bool>(PrefKey.isLogin, true);
        await SharedPrefService.setValue<String>(
            PrefKey.accountRole, _accountType);
        if (_context.mounted) {
          _context.go(indexScreenPath);
        }
      }
    } catch (e) {
      _errorMessage = 'An unexpected error occurred during sign up';
      Fluttertoast.showToast(
        msg: _errorMessage!,
        toastLength: Toast.LENGTH_LONG,
      );
      CustomLog.errorLog(value: 'Sign up exception: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendPasswordReset() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      Fluttertoast.showToast(msg: 'Enter your email address first');
      return;
    }

    _isLoading = true;
    notifyListeners();
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(email);
      Fluttertoast.showToast(
        msg: 'Password reset instructions were sent to $email',
        toastLength: Toast.LENGTH_LONG,
      );
    } on AuthException catch (e) {
      Fluttertoast.showToast(msg: e.message, toastLength: Toast.LENGTH_LONG);
    } catch (e) {
      CustomLog.errorLog(value: 'Password reset error: $e');
      Fluttertoast.showToast(
        msg: 'Could not send password reset email',
        toastLength: Toast.LENGTH_LONG,
      );
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

class _RoleChoice extends StatelessWidget {
  const _RoleChoice({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          onTap: onTap,
          leading: CircleAvatar(child: Icon(icon)),
          title:
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.arrow_forward),
        ),
      );
}
