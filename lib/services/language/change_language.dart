// change_language.dart
import 'package:flutter/material.dart';
import 'package:omspos/services/language/localization_state.dart';
import 'package:provider/provider.dart';

class ChangeLanguage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final localizationState = Provider.of<LocalizationState>(context);
    
    return IconButton(
      icon: Icon(Icons.language),
      onPressed: () {
        localizationState.toggleLanguage();
      },
      tooltip: localizationState.translate('language'),
    );
  }
}