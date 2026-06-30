import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const primary = Color(0xFF6C63FF);
  static const primaryDark = Color(0xFF4A43CC);
  static const accent = Color(0xFF00D4AA);
  static const bgDark = Color(0xFF0D0E1A);
  static const bgCard = Color(0xFF1A1B2E);
  static const success = Color(0xFF4CAF82);
  static const error = Color(0xFFE57373);
  static const textPrimary = Color(0xFFF5F5FF);
  static const textSecondary = Color(0xFF9E9EB8);
  static const textHint = Color(0xFF5E5E7A);
  static const bgSurface = Color(0xFF252640);
  static const border = Color(0xFF2E2F4A);
}

class AppTheme {
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.bgDark,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.accent,
          surface: AppColors.bgCard,
          error: AppColors.error,
          onPrimary: Colors.white,
          onSurface: AppColors.textPrimary,
        ),
        textTheme: GoogleFonts.interTextTheme(
          const TextTheme(
            displayLarge: TextStyle(color: AppColors.textPrimary, fontSize: 32, fontWeight: FontWeight.w700),
            titleLarge: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600),
            bodyLarge: TextStyle(color: AppColors.textPrimary, fontSize: 16),
            bodyMedium: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ),
      );
}
