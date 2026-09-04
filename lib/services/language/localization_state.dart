import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:omspos/services/sharedPreference/preference_keys.dart';
import 'package:omspos/services/sharedPreference/sharedPref_service.dart';

class LocalizationState extends ChangeNotifier {
  Locale _currentLocale = const Locale('en', 'US');
  Map<String, String> _localizedStrings = {};

  LocalizationState() {
    _initialize();
  }

  Future<void> _initialize() async {
    final savedLanguage = await SharedPrefService.getValue<String>(
      PrefKey.languageCode,
      defaultValue: 'en',
    );
    _currentLocale = savedLanguage == 'ne'
        ? const Locale('ne', 'NP')
        : const Locale('en', 'US');
    await loadLocalizedStrings();
  }

  Locale get currentLocale => _currentLocale;
  Map<String, String> get localizedStrings => _localizedStrings;
  bool get isEnglish => _currentLocale.languageCode == 'en';
  bool get isNepali => _currentLocale.languageCode == 'ne';

  // Load localization files
  Future<void> loadLocalizedStrings() async {
    String langCode = _currentLocale.languageCode;
    String jsonString =
        await rootBundle.loadString('assets/locales/$langCode.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    _localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });

    notifyListeners();
  }

  // Switch between English and Nepali
  Future<void> toggleLanguage() async {
    if (_currentLocale.languageCode == 'en') {
      await setLocale(const Locale('ne', 'NP'));
    } else {
      await setLocale(const Locale('en', 'US'));
    }
  }

  // Set specific locale
  Future<void> setLocale(Locale locale) async {
    _currentLocale = locale;
    await SharedPrefService.setValue<String>(
      PrefKey.languageCode,
      locale.languageCode,
    );
    await loadLocalizedStrings();
  }

  // Get translated string
  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }
}
