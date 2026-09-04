// theme_toggle.dart
import 'package:flutter/material.dart';
import 'package:omspos/themes/theme_state.dart';
import 'package:provider/provider.dart';

class ThemeToggle extends StatelessWidget {
  const ThemeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final themeState = Provider.of<ThemeState>(context);

    return Switch(
      value: themeState.isDarkTheme,
      onChanged: (value) {
        themeState.toggleTheme();
      },
      activeThumbColor: ThemeState.highLightColor,
      activeTrackColor: ThemeState.highLightColor.withValues(alpha: 0.5),
    );
  }
}
