import 'package:google_sign_in/google_sign_in.dart';
import 'package:omspos/config/env_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignInService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<AuthResponse> googleSignIn() async {
    final webClientId = EnvConfig.webClientId;

    final scopes = ['email', 'profile'];
    final googleSignIn = GoogleSignIn.instance;
    

    await googleSignIn.initialize(
      serverClientId: webClientId,
    );
    final googleUser = await googleSignIn.attemptLightweightAuthentication()
        ?? await googleSignIn.authenticate();
    final authorization = await googleUser.authorizationClient.authorizationForScopes(scopes) ?? await googleUser.authorizationClient.authorizeScopes(scopes);
    final idToken = googleUser.authentication.idToken;
    final accessToken = authorization.accessToken;

    if (idToken == null) {
      throw AuthException('Missing Google ID Token.');
    }

    final response = await _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
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
          final displayName = googleUser.displayName ?? user.email?.split('@').first ?? 'User';
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
        print('Error syncing google user to public.users table: $e');
      }
    }

    return response;
  }

  Future<void> signOut() async {
    final googleSignIn = GoogleSignIn.instance;
    await googleSignIn.disconnect();
    await _client.auth.signOut();
  }
}



// onPressed: () async {
//             setState(() => _loading = true);
//             try {
//               final response = await signInService.googleSignIn();
//               debugPrint('Signed in as: ${response.user?.email}');
//             } catch (e) {
//               debugPrint('Error: $e');
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(content: Text('Sign-in failed: $e')),
//               );
//             } finally {
//               setState(() => _loading = false);
//             }
//           },


//This is the google auth sign in method
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class SignInService {
//   final SupabaseClient _client = Supabase.instance.client;

//   Future<AuthResponse> googleSignIn() async {
//     const webClientId =
//         '65eusercontent.com';

//     final scopes = ['email', 'profile'];
//     final googleSignIn = GoogleSignIn.instance;

//     await googleSignIn.initialize(serverClientId: webClientId);

//     final googleUser = await googleSignIn.attemptLightweightAuthentication() ??
//         await googleSignIn.authenticate();

//     if (googleUser == null) {
//       throw AuthException('Google Sign-In failed.');
//     }

//     // Request authorization for scopes to get access token
//     final authorization = await googleUser.authorizationClient
//             .authorizationForScopes(scopes) ??
//         await googleUser.authorizationClient.authorizeScopes(scopes);

//     final idToken = googleUser.authentication.idToken;
//     final accessToken = authorization.accessToken;

//     if (idToken == null) throw AuthException('Missing Google ID Token.');

//     // Authenticate with Supabase
//     final response = await _client.auth.signInWithIdToken(
//       provider: OAuthProvider.google,
//       idToken: idToken,
//       accessToken: accessToken,
//     );

//     // Once signed in, get user info from Supabase
//     final user = response.user;
//     if (user == null) throw AuthException('User not found after sign-in.');

//     // 🔥 Check if user exists in your app's "users" table
//     final existingUser = await _client
//         .from('users')
//         .select()
//         .eq('id', user.id)
//         .maybeSingle();

//     if (existingUser == null) {
//       // 🚀 Create new user record using info from Google
//       final googleProfile = googleUser;
//       final newUser = await _client.from('users').insert({
//         'id': user.id,
//         'email': googleProfile.email,
//         'name': googleProfile.displayName,
//         'avatar_url': googleProfile.photoUrl,
//         'created_at': DateTime.now().toIso8601String(),
//       }).select().single();

//       print('✅ New user created: $newUser');
//       return response;
//     } else {
//       // ✅ Existing user found — you can return or cache their data
//       print('👤 Existing user: $existingUser');
//       return response;
//     }
//   }

//   Future<void> signOut() async {
//     final googleSignIn = GoogleSignIn.instance;
//     await googleSignIn.disconnect();
//     await _client.auth.signOut();
//   }
// }



