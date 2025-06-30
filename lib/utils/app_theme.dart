import 'package:flutter/material.dart';

class AppTheme {
  // Main color palette
  static const Color primaryGreen = Color(0xFF1E8449); // Richer green for AgroTech feel
  static const Color lightGreen = Color(0xFF58D68D);
  static const Color darkGreen = Color(0xFF145A32);
  static const Color accentGreen = Color(0xFF82E0AA);
  static const Color backgroundColor = Color(0xFFF8F9F9); // Lighter background for modern feel
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color errorColor = Color(0xFFE74C3C); // More vibrant red
  static const Color warningColor = Color(0xFFF39C12);
  
  // Additional modern UI colors
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF7F8C8D);
  static const Color dividerColor = Color(0xFFECF0F1);
  static const Color shadowColor = Color(0x1A000000);

  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: Colors.green,
      primaryColor: primaryGreen,
      scaffoldBackgroundColor: backgroundColor,
      cardColor: cardColor,
      shadowColor: shadowColor,
      colorScheme: ColorScheme.light(
        primary: primaryGreen,
        secondary: accentGreen,
        error: errorColor,
        background: backgroundColor,
        surface: cardColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 64,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: cardColor,
        selectedItemColor: primaryGreen,
        unselectedItemColor: textSecondary,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 2,
        shadowColor: shadowColor,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontSize: 24, 
          fontWeight: FontWeight.bold, 
          color: textPrimary
        ),
        titleLarge: TextStyle(
          fontSize: 20, 
          fontWeight: FontWeight.bold, 
          color: textPrimary
        ),
        titleMedium: TextStyle(
          fontSize: 18, 
          fontWeight: FontWeight.w600, 
          color: textPrimary
        ),
        bodyLarge: TextStyle(
          fontSize: 16, 
          color: textPrimary
        ),
        bodyMedium: TextStyle(
          fontSize: 14, 
          color: textPrimary
        ),
        labelLarge: TextStyle(
          fontSize: 14, 
          fontWeight: FontWeight.w600, 
          color: textPrimary
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: 24,
      ),
      iconTheme: const IconThemeData(
        color: primaryGreen,
        size: 24,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: backgroundColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
      ),
    );
  }
}
