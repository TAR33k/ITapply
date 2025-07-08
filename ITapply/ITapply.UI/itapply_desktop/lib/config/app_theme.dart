import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFFFF7300);
  static const Color primaryDarkColor = Color(0xFFBB5400);
  static const Color secondaryColor = Color(0xFF707070);
  static const Color confirmColor = Color(0xFF2ECC71);
  static const Color accentColor = Color(0xFFE74C3C);
  static const Color lightColor = Color(0xFFF5F7FA);
  static const Color grayColor = Color(0xFFDFE4EA);
  static const Color darkColor = Color(0xFF2C3E50);
  static const Color textColor = Color(0xFF34495E);

  static ThemeData getTheme() {
    final baseTheme = ThemeData.light();

    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: lightColor,
      textTheme: GoogleFonts.poppinsTextTheme(baseTheme.textTheme).apply(
        bodyColor: textColor,
        displayColor: textColor,
      ),
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: lightColor,
        error: accentColor,
        onPrimary: lightColor,
        onSecondary: lightColor,
        onSurface: textColor,
        onError: lightColor,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: textColor,
        elevation: 1,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          color: textColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: grayColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: grayColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2.0),
        ),
        labelStyle: const TextStyle(color: secondaryColor),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStateProperty.all(lightColor),
        headingTextStyle: const TextStyle(fontWeight: FontWeight.w600, color: darkColor),
        dataRowColor: WidgetStateProperty.all(Colors.white),
        dividerThickness: 1,
        columnSpacing: 20,
      ),
    );
  }
}