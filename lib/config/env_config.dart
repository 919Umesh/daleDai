import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String get supabaseUrl =>
      dotenv.env['SUPABASE_URL'] ??
      const String.fromEnvironment('SUPABASE_URL', defaultValue: '');

  static String get supabaseAnonKey =>
      dotenv.env['SUPABASE_ANON_KEY'] ??
      const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

  static String get webClientId =>
      dotenv.env['WEB_CLIENT_ID'] ??
      const String.fromEnvironment('WEB_CLIENT_ID', defaultValue: '');

  static String get onesignalAppId =>
      dotenv.env['ONESIGNAL_APP_ID'] ??
      const String.fromEnvironment('ONESIGNAL_APP_ID', defaultValue: '');

  static String get onesignalApiKey =>
      dotenv.env['ONESIGNAL_API_KEY'] ??
      const String.fromEnvironment('ONESIGNAL_API_KEY', defaultValue: '');

  static Future<void> load() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (e) {
      debugPrint('Info: .env file not loaded from assets ($e). Using dart-define or defaults.');
    }
  }
}
