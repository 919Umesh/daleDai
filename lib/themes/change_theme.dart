// theme_toggle.dart
import 'package:flutter/material.dart';
import 'package:omspos/themes/theme_state.dart';
import 'package:provider/provider.dart';

class ThemeToggle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeState = Provider.of<ThemeState>(context);
    
    return Switch(
      value: themeState.isDarkTheme,
      onChanged: (value) {
        themeState.toggleTheme();
      },
      activeColor: ThemeState.highLightColor,
      activeTrackColor: ThemeState.highLightColor.withOpacity(0.5),
    );
  }
}