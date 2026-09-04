// theme_state.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:omspos/services/sharedPreference/preference_keys.dart';
import 'package:omspos/services/sharedPreference/sharedPref_service.dart';

class ThemeState extends ChangeNotifier {
  bool _isDarkTheme = true;
  bool get isDarkTheme => _isDarkTheme;

  ThemeState() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    _isDarkTheme = await SharedPrefService.getValue<bool>(
          PrefKey.isDarkTheme,
          defaultValue: true,
        ) ??
        true;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkTheme = !_isDarkTheme;
    notifyListeners();
    await SharedPrefService.setValue<bool>(PrefKey.isDarkTheme, _isDarkTheme);
  }

  ThemeData get currentTheme => _isDarkTheme ? darkTheme : lightTheme;

  static const Color highLightColor = primaryGreen; // For use in toggle widgets

  static const Color primaryGreen = Color(0xFF29950B);
  static const Color primaryLight = Color(0xFF4CAF50);
  static const Color bgDark = Color(0xFF1A1512);
  static const Color surfaceDark = Color(0xFF242424);
  static const Color surfaceDark2 = Color(0xFF2E2E2E);

  // ─── Dark Theme ───────────────────────────────────────────
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryGreen,
    scaffoldBackgroundColor: bgDark,
    cardColor: surfaceDark,
    fontFamily: GoogleFonts.poppins().fontFamily,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryGreen,
      brightness: Brightness.dark,
      surface: surfaceDark,
      error: const Color(0xFFCF6679),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: surfaceDark,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: surfaceDark,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceDark2,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryGreen, width: 1.5),
      ),
      hintStyle: const TextStyle(color: Colors.white38),
      labelStyle: const TextStyle(color: Colors.white60),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: surfaceDark,
      surfaceTintColor: Colors.transparent,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: surfaceDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: primaryGreen.withValues(alpha: 0.15),
      labelStyle: const TextStyle(color: primaryGreen, fontSize: 12),
      side: const BorderSide(color: Colors.transparent),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: primaryGreen,
      unselectedLabelColor: Colors.white54,
      indicatorColor: primaryGreen,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle:
          GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
      unselectedLabelStyle: GoogleFonts.poppins(fontSize: 14),
    ),
    textTheme: TextTheme(
      headlineLarge: GoogleFonts.poppins(
          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 28),
      headlineMedium: GoogleFonts.poppins(
          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
      titleLarge: GoogleFonts.poppins(
          color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18),
      titleMedium: GoogleFonts.poppins(
          color: Colors.white, fontWeight: FontWeight.w500, fontSize: 16),
      bodyLarge: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
      bodyMedium: GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
      bodySmall: GoogleFonts.poppins(color: Colors.white54, fontSize: 12),
    ),
    dividerColor: Colors.white12,
    iconTheme: const IconThemeData(color: Colors.white70),
  );

  // ─── Light Theme ──────────────────────────────────────────
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryGreen,
    scaffoldBackgroundColor: const Color(0xFFF5F7FA),
    cardColor: Colors.white,
    fontFamily: GoogleFonts.poppins().fontFamily,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryGreen,
      brightness: Brightness.light,
      surface: Colors.white,
      error: Colors.red.shade700,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      elevation: 0,
      centerTitle: false,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF0F0F0),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryGreen, width: 1.5),
      ),
      hintStyle: const TextStyle(color: Colors.black38),
      labelStyle: const TextStyle(color: Colors.black54),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.black87,
        side: const BorderSide(color: Colors.black12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: primaryGreen.withValues(alpha: 0.1),
      labelStyle: const TextStyle(color: primaryGreen, fontSize: 12),
      side: const BorderSide(color: Colors.transparent),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: primaryGreen,
      unselectedLabelColor: Colors.black45,
      indicatorColor: primaryGreen,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle:
          GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
      unselectedLabelStyle: GoogleFonts.poppins(fontSize: 14),
    ),
    textTheme: TextTheme(
      headlineLarge: GoogleFonts.poppins(
          color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 28),
      headlineMedium: GoogleFonts.poppins(
          color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 22),
      titleLarge: GoogleFonts.poppins(
          color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 18),
      titleMedium: GoogleFonts.poppins(
          color: Colors.black87, fontWeight: FontWeight.w500, fontSize: 16),
      bodyLarge: GoogleFonts.poppins(color: Colors.black87, fontSize: 14),
      bodyMedium: GoogleFonts.poppins(color: Colors.black54, fontSize: 13),
      bodySmall: GoogleFonts.poppins(color: Colors.black45, fontSize: 12),
    ),
    dividerColor: Colors.black12,
    iconTheme: const IconThemeData(color: Colors.black54),
  );
}
