import 'package:omspos/screen/login/model/login_model.dart';
import 'package:omspos/services/api/supabase_helper.dart';

class AuthAPI {
  static Future<AuthModel> signIn({
    required String email,
    required String password,
  }) async {
    final response = await SupabaseProvider.signInWithPassword(
      email: email,
      password: password,
    );
    return AuthModel.fromJson(response);
  }

  static Future<AuthModel> signUp({
    required String email,
    required String password,
    String? name,
    String userType = 'tenant',
  }) async {
    final response = await SupabaseProvider.signUpWithPassword(
      email: email,
      password: password,
      name: name,
      userType: userType,
    );
    return AuthModel.fromJson(response);
  }
}
