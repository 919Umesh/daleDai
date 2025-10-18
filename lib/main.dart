import 'package:flutter/material.dart';
import 'package:omspos/config/env_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: EnvConfig.supabaseUrl,
    anonKey: EnvConfig.supabaseAnonKey,
  );
  runApp(const MyApp());
}
