import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryGold = Color(0xFFFFB800); // More vibrant gold
  static const Color backgroundBlack = Color(0xFF0F0F0F);
  static const Color cardGrey = Color(0xFF1A1A1A);
  static const Color accentGreen = Color(0xFF1ABC9C);
  static const Color accentRed = Color(0xFFE74C3C);
  static const Color textLight = Colors.white;
  static const Color textGrey = Color(0xFF888888);

  static ThemeData darkGoldTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: backgroundBlack,
    primaryColor: primaryGold,
    colorScheme: const ColorScheme.dark(
      primary: primaryGold,
      secondary: primaryGold,
      surface: cardGrey,
    ),
    textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).copyWith(
      displayLarge: const TextStyle(color: textLight, fontWeight: FontWeight.bold),
      bodyLarge: const TextStyle(color: textLight),
      bodyMedium: const TextStyle(color: textGrey),
    ),
    cardTheme: CardThemeData(
      color: cardGrey,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0, // Flat design with borders
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white, // In screenshot, login fields are white background?
      // Wait, looking at the screenshot, the login fields have white backgrounds.
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      labelStyle: const TextStyle(color: primaryGold),
      prefixIconColor: Colors.grey,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGold,
        foregroundColor: Colors.black,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)), // Fully rounded button
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
      ),
    ),
  );
}
