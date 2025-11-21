import 'package:flutter/material.dart';

/// Catppuccin Latte (Light Mode) Color Palette
class CatppuccinLatte {
  // Base colors
  static const Color rosewater = Color(0xFFDC8A78);
  static const Color flamingo = Color(0xFFDD7878);
  static const Color pink = Color(0xFFEA76CB);
  static const Color mauve = Color(0xFF8839EF);
  static const Color red = Color(0xFFD20F39);
  static const Color maroon = Color(0xFFE64553);
  static const Color peach = Color(0xFFFE640B);
  static const Color yellow = Color(0xFFDF8E1D);
  static const Color green = Color(0xFF40A02B);
  static const Color teal = Color(0xFF179299);
  static const Color sky = Color(0xFF04A5E5);
  static const Color sapphire = Color(0xFF209FB5);
  static const Color blue = Color(0xFF1E66F5);
  static const Color lavender = Color(0xFF7287FD);

  // Surface colors
  static const Color base = Color(0xFFEFF1F5);
  static const Color mantle = Color(0xFFE6E9EF);
  static const Color crust = Color(0xFFDCE0E8);

  // Text colors
  static const Color text = Color(0xFF4C4F69);
  static const Color subtext1 = Color(0xFF5C5F77);
  static const Color subtext0 = Color(0xFF6C6F85);

  // Overlay colors
  static const Color surface0 = Color(0xFFCCD0DA);
  static const Color surface1 = Color(0xFFBCC0CC);
  static const Color surface2 = Color(0xFFACB0BE);

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: blue,
        onPrimary: base,
        secondary: mauve,
        onSecondary: base,
        error: red,
        onError: base,
        surface: base,
        onSurface: text,
        surfaceContainerHighest: surface0,
        surfaceContainerHigh: surface1,
        surfaceContainer: surface2,
        outline: surface2,
      ),
      scaffoldBackgroundColor: base,
      appBarTheme: const AppBarTheme(
        backgroundColor: mantle,
        foregroundColor: text,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: mantle,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: blue,
          foregroundColor: base,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: blue,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: mantle,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: surface2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: surface2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: blue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: red),
        ),
        labelStyle: const TextStyle(color: subtext0),
        hintStyle: const TextStyle(color: subtext0),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: mantle,
        selectedColor: blue,
        labelStyle: const TextStyle(color: text),
        secondaryLabelStyle: const TextStyle(color: base),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: surface2,
        thickness: 1,
      ),
      iconTheme: const IconThemeData(
        color: text,
      ),
      textTheme: const TextTheme(
        displayLarge:
            TextStyle(color: text, fontSize: 32, fontWeight: FontWeight.bold),
        displayMedium:
            TextStyle(color: text, fontSize: 28, fontWeight: FontWeight.bold),
        displaySmall:
            TextStyle(color: text, fontSize: 24, fontWeight: FontWeight.bold),
        headlineLarge:
            TextStyle(color: text, fontSize: 22, fontWeight: FontWeight.w600),
        headlineMedium:
            TextStyle(color: text, fontSize: 20, fontWeight: FontWeight.w600),
        headlineSmall:
            TextStyle(color: text, fontSize: 18, fontWeight: FontWeight.w600),
        titleLarge:
            TextStyle(color: text, fontSize: 16, fontWeight: FontWeight.w600),
        titleMedium:
            TextStyle(color: text, fontSize: 14, fontWeight: FontWeight.w600),
        titleSmall:
            TextStyle(color: text, fontSize: 12, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: text, fontSize: 16),
        bodyMedium: TextStyle(color: text, fontSize: 14),
        bodySmall: TextStyle(color: subtext1, fontSize: 12),
        labelLarge:
            TextStyle(color: text, fontSize: 14, fontWeight: FontWeight.w500),
        labelMedium: TextStyle(color: subtext1, fontSize: 12),
        labelSmall: TextStyle(color: subtext0, fontSize: 10),
      ),
    );
  }
}
