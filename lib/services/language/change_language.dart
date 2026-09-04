// change_language.dart
import 'package:flutter/material.dart';
import 'package:omspos/services/language/localization_state.dart';
import 'package:provider/provider.dart';

class ChangeLanguage extends StatelessWidget {
  const ChangeLanguage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizationState = Provider.of<LocalizationState>(context);

    return Tooltip(
      message: localizationState.translate('language'),
      child: TextButton(
        onPressed: localizationState.toggleLanguage,
        child: Text(localizationState.isEnglish ? 'EN' : 'ने'),
      ),
    );
  }
}
