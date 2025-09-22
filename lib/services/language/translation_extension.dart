import 'package:flutter/material.dart';
import 'package:omspos/services/language/localization_state.dart';
import 'package:provider/provider.dart';

extension TranslationExtension on BuildContext {
  String translate(String key) {
    final localizationState = Provider.of<LocalizationState>(this, listen: true);
    return localizationState.translate(key);
  }
}