import 'package:flutter/material.dart';

class KashColors {
  static const background = Color(0xFF000000);
  static const surface = Color(0xFF141414);
  static const surfaceElevated = Color(0xFF1C1C1E);
  static const border = Color(0xFF2C2C2E);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFA1A1A6);
  static const accentGreen = Color(0xFF34C759);
  static const accentAmber = Color(0xFFFFB340);
  static const accentRed = Color(0xFFFF453A);
  static const accentBlue = Color(0xFF64D2FF);
  static const fab = Color(0xFF0A84FF);

  static Color gaugeForProgress(double ratio) {
    if (ratio < 0.75) return accentGreen;
    if (ratio <= 0.90) return accentAmber;
    return accentRed;
  }
}

ThemeData buildKashTheme() {
  const scheme = ColorScheme.dark(
    primary: KashColors.fab,
    secondary: KashColors.accentGreen,
    surface: KashColors.surface,
    error: KashColors.accentRed,
    onPrimary: Colors.white,
    onSecondary: Colors.black,
    onSurface: KashColors.textPrimary,
    onError: Colors.white,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme,
    scaffoldBackgroundColor: KashColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: KashColors.background,
      foregroundColor: KashColors.textPrimary,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: KashColors.surfaceElevated,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: KashColors.surfaceElevated,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    dividerColor: KashColors.border,
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: KashColors.surface,
      indicatorColor: KashColors.fab.withValues(alpha: 0.2),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 12,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          color: selected ? KashColors.fab : KashColors.textSecondary,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? KashColors.fab : KashColors.textSecondary,
        );
      }),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: KashColors.fab,
      foregroundColor: Colors.white,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontWeight: FontWeight.w700,
        color: KashColors.textPrimary,
      ),
      titleLarge: TextStyle(
        fontWeight: FontWeight.w600,
        color: KashColors.textPrimary,
      ),
      titleMedium: TextStyle(
        fontWeight: FontWeight.w600,
        color: KashColors.textPrimary,
      ),
      bodyLarge: TextStyle(color: KashColors.textPrimary),
      bodyMedium: TextStyle(color: KashColors.textPrimary),
      bodySmall: TextStyle(color: KashColors.textSecondary),
      labelLarge: TextStyle(
        fontWeight: FontWeight.w600,
        color: KashColors.textPrimary,
      ),
    ),
  );
}
