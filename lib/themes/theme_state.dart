// theme_state.dart
import 'package:flutter/material.dart';

class ThemeState extends ChangeNotifier {
  bool _isDarkTheme = true;

  bool get isDarkTheme => _isDarkTheme;

  void toggleTheme() {
    _isDarkTheme = !_isDarkTheme;
    notifyListeners();
  }

  ThemeData get currentTheme => _isDarkTheme ? darkTheme : lightTheme;

  // Your colors
  static const Color highLightColor = Color(0xFF29950B);
  static const Color backgroundColor = Color(0xFF1A1512);
  static const Color gradientColor = Color(0xFF253A19);
  static const Color cardColor = Color(0xFF242424);

  // Light Theme
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: highLightColor,
    scaffoldBackgroundColor: Colors.grey[50],
    cardColor: Colors.white,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: Colors.black87),
      bodyMedium: TextStyle(color: Colors.black54),
    ),
    colorScheme: ColorScheme.light(
      primary: highLightColor,
      secondary: highLightColor,
      background: Colors.grey[50]!,
    ),
  );

  // Dark Theme
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: highLightColor,
    scaffoldBackgroundColor: backgroundColor,
    cardColor: cardColor,
    appBarTheme: AppBarTheme(
      backgroundColor: cardColor,
      elevation: 0,
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
    ),
    colorScheme: ColorScheme.dark(
      primary: highLightColor,
      secondary: highLightColor,
      background: backgroundColor,
      surface: cardColor,
    ),
  );
}
