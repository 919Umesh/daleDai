import 'package:omspos/services/sharedPreference/preference_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefService {
  static Future<void> setValue<T>(PrefKey key, T value) async {
    final prefs = await SharedPreferences.getInstance();
    final keyStr = key.name;

    if (value is String) {
      await prefs.setString(keyStr, value);
    } else if (value is int) {
      await prefs.setInt(keyStr, value);
    } else if (value is bool) {
      await prefs.setBool(keyStr, value);
    } else if (value is double) {
      await prefs.setDouble(keyStr, value);
    } else {
      throw UnsupportedError('Unsupported type: ${value.runtimeType}');
    }
  }

  static Future<T?> getValue<T>(PrefKey key, {T? defaultValue}) async {
    final prefs = await SharedPreferences.getInstance();
    final keyStr = key.name;

    if (T == String) {
      return (prefs.getString(keyStr) ?? defaultValue) as T?;
    } else if (T == int) {
      return (prefs.getInt(keyStr) ?? defaultValue) as T?;
    } else if (T == bool) {
      return (prefs.getBool(keyStr) ?? defaultValue) as T?;
    } else if (T == double) {
      return (prefs.getDouble(keyStr) ?? defaultValue) as T?;
    } else {
      throw UnsupportedError('Unsupported type: $T');
    }
  }

  static Future<void> remove(PrefKey key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key.name);
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

// Set data:
// await SharedPrefService.setValue<String>(PrefKey.userName, "Umesh");
// await SharedPrefService.setValue<bool>(PrefKey.loginSuccess, true);

// Get data:
// String? username = await SharedPrefService.getValue<String>(PrefKey.userName, defaultValue: "-");
// bool isLoggedIn = await SharedPrefService.getValue<bool>(PrefKey.loginSuccess, defaultValue: false);

// Remove a key:
// await SharedPrefService.remove(PrefKey.userName);


//  Clear all:
//  await SharedPrefService.clearAll();
