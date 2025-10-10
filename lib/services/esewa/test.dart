// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class SignInService {
//   final SupabaseClient _client = Supabase.instance.client;

//   Future<AuthResponse> googleSignIn() async {
//     const webClientId = 'ntent.com';

//     final scopes = ['email', 'profile'];
//     final googleSignIn = GoogleSignIn.instance;

//     await googleSignIn.initialize(
//       serverClientId: webClientId,
//     );
//     final googleUser = await googleSignIn.attemptLightweightAuthentication()
//         ?? await googleSignIn.authenticate();
//     final authorization = await googleUser.authorizationClient.authorizationForScopes(scopes) ?? await googleUser.authorizationClient.authorizeScopes(scopes);
//     final idToken = googleUser.authentication.idToken;
//     final accessToken = authorization.accessToken;

//     if (idToken == null) {
//       throw AuthException('Missing Google ID Token.');
//     }

//     final response = await _client.auth.signInWithIdToken(
//       provider: OAuthProvider.google,
//       idToken: idToken,
//       accessToken: accessToken,
//     );

//     return response;
//   }

//   Future<void> signOut() async {
//     final googleSignIn = GoogleSignIn.instance;
//     await googleSignIn.disconnect();
//     await _client.auth.signOut();
//   }
// }



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
