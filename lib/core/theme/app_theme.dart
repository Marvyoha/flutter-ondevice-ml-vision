import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';

class AppTheme {
  static ThemeData light = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.deepIndigo,
      brightness: Brightness.light,
    ),
    textTheme: GoogleFonts.spaceGroteskTextTheme(),
    scaffoldBackgroundColor: AppColors.cleanWhite,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.cleanWhite,
      foregroundColor: AppColors.deepIndigo,
    ),
    cardTheme: CardThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );

  static ThemeData dark = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.deepIndigo,
      brightness: Brightness.dark,
    ),
    textTheme: GoogleFonts.spaceGroteskTextTheme(),
    scaffoldBackgroundColor: const Color(0xFF0F111A),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0F111A),
      foregroundColor: AppColors.cleanWhite,
    ),
    cardTheme: CardThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}
