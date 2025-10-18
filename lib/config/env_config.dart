import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String get supabaseUrl => dotenv.get('SUPABASE_URL');
  static String get supabaseAnonKey => dotenv.get('SUPABASE_ANON_KEY');
  static String get webClientId => dotenv.get('WEB_CLIENT_ID');

  static Future<void> load() async {
    await dotenv.load();
  }
}
