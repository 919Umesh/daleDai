import 'package:flutter/material.dart';
import 'package:omspos/services/location/location_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://xuodtwztsrbqtfiisxrq.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh1b2R0d3p0c3JicXRmaWlzeHJxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTI3NjM4MzQsImV4cCI6MjA2ODMzOTgzNH0.6LgBKcqa_fzM0czazc5eo6Zkj6FX_H_AftJvIy5i_y8',
  );
  await LocationService.initialize();
  runApp(const MyApp());
}
