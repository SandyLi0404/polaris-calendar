import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Primary color palette
  static const Color primaryColor = Color(0xFF6C5CE7);
  static const Color accentColor = Color(0xFF00CEFF);
  static const Color secondaryColor = Color(0xFFA29BFE);
  
  // Background colors
  static const Color backgroundColor = Color(0xFF121212);
  static const Color surfaceColor = Color(0xFF1E1E1E);
  static const Color cardColor = Color(0xFF2A2A2A);
  static const Color dividerColor = Color(0xFF424242);
  
  // Text colors
  static const Color textPrimaryColor = Color(0xFFFFFFFF);
  static const Color textSecondaryColor = Color(0xFFB0B0B0);
  static const Color textTertiaryColor = Color(0xFF808080);
  
  // Status colors
  static const Color successColor = Color(0xFF00C853);
  static const Color errorColor = Color(0xFFFF5252);
  static const Color warningColor = Color(0xFFFFD600);
  static const Color infoColor = Color(0xFF2196F3);
  
  // Calendar colors
  static const Color todayColor = Color(0xFF8B5CF6);
  static const Color selectedDayColor = Color(0xFF6C5CE7);
  static const Color holidayColor = Color(0xFFFF6B6B);
  
  // Todo priority colors
  static const Color highPriorityColor = Color(0xFFFF5252);
  static const Color lowPriorityColor = Color(0xFF8BC34A);
  
  // Tag colors array
  static const List<Color> tagColors = [
    Color(0xFFFF5252), // Red
    Color(0xFF8BC34A), // Green
    Color(0xFF448AFF), // Blue
    Color(0xFFFFD600), // Yellow
    Color(0xFFFF6D00), // Orange
    Color(0xFFAA00FF), // Purple
    Color(0xFF00BCD4), // Cyan
    Color(0xFFFF4081), // Pink
  ];
  
  // Font styles
  static TextTheme textTheme = TextTheme(
    displayLarge: GoogleFonts.poppins(
      color: textPrimaryColor,
      fontSize: 32,
      fontWeight: FontWeight.bold,
    ),
    displayMedium: GoogleFonts.poppins(
      color: textPrimaryColor,
      fontSize: 28,
      fontWeight: FontWeight.bold,
    ),
    displaySmall: GoogleFonts.poppins(
      color: textPrimaryColor,
      fontSize: 24,
      fontWeight: FontWeight.bold,
    ),
    headlineLarge: GoogleFonts.poppins(
      color: textPrimaryColor,
      fontSize: 22,
      fontWeight: FontWeight.w600,
    ),
    headlineMedium: GoogleFonts.poppins(
      color: textPrimaryColor,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
    headlineSmall: GoogleFonts.poppins(
      color: textPrimaryColor,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
    titleLarge: GoogleFonts.poppins(
      color: textPrimaryColor,
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
    titleMedium: GoogleFonts.poppins(
      color: textPrimaryColor,
      fontSize: 15,
      fontWeight: FontWeight.w500,
    ),
    titleSmall: GoogleFonts.poppins(
      color: textSecondaryColor,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    bodyLarge: GoogleFonts.poppins(
      color: textPrimaryColor,
      fontSize: 16,
      fontWeight: FontWeight.normal,
    ),
    bodyMedium: GoogleFonts.poppins(
      color: textPrimaryColor,
      fontSize: 14,
      fontWeight: FontWeight.normal,
    ),
    bodySmall: GoogleFonts.poppins(
      color: textSecondaryColor,
      fontSize: 12,
      fontWeight: FontWeight.normal,
    ),
    labelLarge: GoogleFonts.poppins(
      color: textPrimaryColor,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    labelMedium: GoogleFonts.poppins(
      color: textPrimaryColor,
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),
    labelSmall: GoogleFonts.poppins(
      color: textSecondaryColor,
      fontSize: 11,
      fontWeight: FontWeight.w500,
    ),
  );
  
  // Dark theme
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    cardColor: cardColor,
    dividerColor: dividerColor,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: surfaceColor,
      background: backgroundColor,
      error: errorColor,
    ),
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: backgroundColor,
      elevation: 0,
      titleTextStyle: textTheme.titleLarge,
      iconTheme: const IconThemeData(color: textPrimaryColor),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: surfaceColor,
      selectedItemColor: primaryColor,
      unselectedItemColor: textTertiaryColor,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: textPrimaryColor,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: textPrimaryColor,
        elevation: 0,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: textTheme.labelLarge,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor),
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: textTheme.labelLarge,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        textStyle: textTheme.labelLarge,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cardColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorColor),
      ),
      hintStyle: textTheme.bodyMedium?.copyWith(color: textTertiaryColor),
      labelStyle: textTheme.bodyMedium?.copyWith(color: textSecondaryColor),
    ),
    cardTheme: CardTheme(
      color: cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: surfaceColor,
      elevation: 24,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: cardColor,
      contentTextStyle: textTheme.bodyMedium,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: textTheme.bodySmall,
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryColor;
        }
        return dividerColor;
      }),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: cardColor,
      selectedColor: primaryColor,
      labelStyle: textTheme.bodySmall,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );
} 