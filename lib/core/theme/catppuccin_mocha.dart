import 'package:flutter/material.dart';

/// Catppuccin Mocha (Dark Mode) Color Palette
class CatppuccinMocha {
  // Base colors
  static const Color rosewater = Color(0xFFF5E0DC);
  static const Color flamingo = Color(0xFFF2CDCD);
  static const Color pink = Color(0xFFF5C2E7);
  static const Color mauve = Color(0xFFCBA6F7);
  static const Color red = Color(0xFFF38BA8);
  static const Color maroon = Color(0xFFEBA0AC);
  static const Color peach = Color(0xFFFAB387);
  static const Color yellow = Color(0xFFF9E2AF);
  static const Color green = Color(0xFFA6E3A1);
  static const Color teal = Color(0xFF94E2D5);
  static const Color sky = Color(0xFF89DCEB);
  static const Color sapphire = Color(0xFF74C7EC);
  static const Color blue = Color(0xFF89B4FA);
  static const Color lavender = Color(0xFFB4BEFE);

  // Surface colors
  static const Color base = Color(0xFF1E1E2E);
  static const Color mantle = Color(0xFF181825);
  static const Color crust = Color(0xFF11111B);

  // Text colors
  static const Color text = Color(0xFFCDD6F4);
  static const Color subtext1 = Color(0xFFBAC2DE);
  static const Color subtext0 = Color(0xFFA6ADC8);

  // Overlay colors
  static const Color surface0 = Color(0xFF313244);
  static const Color surface1 = Color(0xFF45475A);
  static const Color surface2 = Color(0xFF585B70);

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: mauve,
        onPrimary: base,
        secondary: blue,
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
        color: surface0,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: mauve,
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
          foregroundColor: mauve,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface0,
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
          borderSide: const BorderSide(color: mauve, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: red),
        ),
        labelStyle: const TextStyle(color: subtext0),
        hintStyle: const TextStyle(color: subtext0),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface0,
        selectedColor: mauve,
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
