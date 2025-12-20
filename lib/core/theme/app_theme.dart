import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'catppuccin_mocha.dart';
import 'catppuccin_latte.dart';

/// Theme mode state provider
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.dark) {
    _loadThemeMode();
  }

  static const String _themeKey = 'theme_mode';

  Future<void> _loadThemeMode() async {
    try {
      final box = await Hive.openBox('settings');
      final savedTheme = box.get(_themeKey, defaultValue: 'dark');
      state = savedTheme == 'light' ? ThemeMode.light : ThemeMode.dark;
    } catch (e) {
      state = ThemeMode.dark;
    }
  }

  Future<void> toggleTheme() async {
    final newMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    state = newMode;

    try {
      final box = await Hive.openBox('settings');
      await box.put(_themeKey, newMode == ThemeMode.light ? 'light' : 'dark');
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;

    try {
      final box = await Hive.openBox('settings');
      await box.put(_themeKey, mode == ThemeMode.light ? 'light' : 'dark');
    } catch (e) {
      // Handle error silently
    }
  }
}

/// App theme data
class AppTheme {
  static ThemeData get lightTheme => CatppuccinLatte.theme;
  static ThemeData get darkTheme => CatppuccinMocha.theme;

  // Catppuccin Mocha colors (most commonly used)
  static const Color base = CatppuccinMocha.base;
  static const Color mantle = CatppuccinMocha.mantle;
  static const Color crust = CatppuccinMocha.crust;
  static const Color surface = CatppuccinMocha.surface0;
  static const Color surface0 = CatppuccinMocha.surface0;
  static const Color surface1 = CatppuccinMocha.surface1;
  static const Color surface2 = CatppuccinMocha.surface2;
  static const Color overlay0 = CatppuccinMocha.surface0;
  static const Color overlay1 = CatppuccinMocha.surface1;
  static const Color overlay2 = CatppuccinMocha.surface2;

  static const Color text = CatppuccinMocha.text;
  static const Color subtext0 = CatppuccinMocha.subtext0;
  static const Color subtext1 = CatppuccinMocha.subtext1;

  static const Color rosewater = CatppuccinMocha.rosewater;
  static const Color flamingo = CatppuccinMocha.flamingo;
  static const Color pink = CatppuccinMocha.pink;
  static const Color mauve = CatppuccinMocha.mauve;
  static const Color red = CatppuccinMocha.red;
  static const Color maroon = CatppuccinMocha.maroon;
  static const Color peach = CatppuccinMocha.peach;
  static const Color yellow = CatppuccinMocha.yellow;
  static const Color green = CatppuccinMocha.green;
  static const Color teal = CatppuccinMocha.teal;
  static const Color sky = CatppuccinMocha.sky;
  static const Color sapphire = CatppuccinMocha.sapphire;
  static const Color blue = CatppuccinMocha.blue;
  static const Color lavender = CatppuccinMocha.lavender;
}
