// lib/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // Cyberpunk Color Palette
  static const Color primaryCyan = Color(0xFF00E5FF);
  static const Color accentCyan = Color(0xFF00BCD4);
  static const Color darkBg = Color(0xFF0A0A0A);
  static const Color cardBg = Color(0xFF1A1A1A);
  
  // Status Colors
  static const Color successGreen = Color(0xFF00FF41);
  static const Color warningOrange = Color(0xFFFF9800);
  static const Color errorRed = Color(0xFFFF1744);
  
  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textCyan = Color(0xFF00E5FF);

  // Legacy colors (for compatibility)
  static const Color primaryColor = accentCyan;
  static const Color secondaryColor = primaryCyan;
  static const Color backgroundColor = darkBg;
  static const Color surfaceColor = cardBg;
  static const Color errorColor = errorRed;
  static const Color onPrimary = textPrimary;
  static const Color onSecondary = darkBg;
  static const Color onBackground = textPrimary;
  static const Color onSurface = textPrimary;
  static const Color onError = textPrimary;

  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      colorScheme: const ColorScheme.dark(
        primary: primaryCyan,
        secondary: accentCyan,
        surface: cardBg,
        error: errorRed,
        onPrimary: textPrimary,
        onSecondary: darkBg,
        onSurface: textPrimary,
        onError: textPrimary,
      ),
      scaffoldBackgroundColor: darkBg,
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: primaryCyan,
            width: 1.5,
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        clipBehavior: Clip.antiAlias,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: cardBg,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: primaryCyan,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
        iconTheme: IconThemeData(color: primaryCyan),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryCyan,
        foregroundColor: darkBg,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryCyan,
          foregroundColor: darkBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: primaryCyan,
          letterSpacing: 1.2,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: primaryCyan,
          letterSpacing: 1.2,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: primaryCyan,
          letterSpacing: 0.8,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: textSecondary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryCyan, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryCyan, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryCyan, width: 2),
        ),
        labelStyle: const TextStyle(color: primaryCyan),
        hintStyle: const TextStyle(color: textSecondary),
      ),
    );
  }
}