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
}
