import 'package:flutter/material.dart';
import 'package:omspos/config/env_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EnvConfig.load();
  await Supabase.initialize(
    url: EnvConfig.supabaseUrl,
    anonKey: EnvConfig.supabaseAnonKey,
  );
  //Umesh Has switch to dev and commit to the dev branch
  runApp(const MyApp());
}
