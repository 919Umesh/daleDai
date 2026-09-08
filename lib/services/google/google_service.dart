import 'package:google_sign_in/google_sign_in.dart';
import 'package:omspos/config/env_config.dart';
import 'package:omspos/utils/custom_log.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignInService {
  final SupabaseClient _client = Supabase.instance.client;
  static Future<void>? _googleInitialization;

  Future<void> _initializeGoogleSignIn(String webClientId) {
    if (webClientId.isEmpty) {
      throw const AuthException('Google WEB_CLIENT_ID is not configured.');
    }

    // google_sign_in requires its singleton to be initialized exactly once.
    return _googleInitialization ??=
        GoogleSignIn.instance.initialize(serverClientId: webClientId);
  }

  Future<GoogleSignInAccount> _authenticate() async {
    final googleSignIn = GoogleSignIn.instance;

    try {
      // This method is called from the login button, so start an explicit
      // authentication flow instead of trying to restore a cached account.
      return await googleSignIn.authenticate();
    } on GoogleSignInException catch (error) {
      final isAccountReauthFailure =
          error.code == GoogleSignInExceptionCode.canceled &&
              (error.description ?? '').toLowerCase().contains(
                    'account reauth failed',
                  );

      if (!isAccountReauthFailure) rethrow;

      // Credential Manager can retain a stale account selection. Clear the
      // local Google session (without revoking access) and retry once.
      await googleSignIn.signOut();
      return googleSignIn.authenticate();
    }
  }

  Future<AuthResponse> googleSignIn() async {
    final webClientId = EnvConfig.webClientId;

    await _initializeGoogleSignIn(webClientId);
    final googleUser = await _authenticate();
    final idToken = googleUser.authentication.idToken;

    if (idToken == null) {
      throw const AuthException('Google did not return an ID token.');
    }

    // Supabase authenticates the user from the Google ID token. Requesting a
    // separate Google API access token here adds another consent flow and can
    // fail even though authentication itself succeeded.
    final response = await _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
    );

    final user = response.user;
    if (user != null) {
      try {
        final existingUser = await _client
            .from('users')
            .select()
            .eq('user_id', user.id)
            .maybeSingle();

        if (existingUser == null) {
          final displayName =
              googleUser.displayName ?? user.email?.split('@').first ?? 'User';
          await _client.from('users').insert({
            'user_id': user.id,
            'email': user.email ?? googleUser.email,
            'name': displayName,
            'profile_image': googleUser.photoUrl,
            'user_type': 'tenant',
            'is_verified': true,
          });
        }
      } catch (e) {
        // Log error inserting user record, but allow auth response to pass
        CustomLog.errorLog(
          value: 'Error syncing google user to public.users table: $e',
        );
      }
    }

    return response;
  }

  Future<void> signOut() async {
    final googleSignIn = GoogleSignIn.instance;
    await _initializeGoogleSignIn(EnvConfig.webClientId);
    // signOut clears the local session. disconnect would also revoke the
    // user's authorization and force an unnecessary reauthorization later.
    try {
      await googleSignIn.signOut();
    } finally {
      await _client.auth.signOut();
    }
  }
}
