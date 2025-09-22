import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = true;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadTheme();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _saveTheme();
    notifyListeners();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('is_dark_mode') ?? true;
    notifyListeners();
  }

  Future<void> _saveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', _isDarkMode);
  }

  ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7C3AED), // More mystical purple
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor:
            const Color(0xFFF1F5F9), // Slightly more ethereal background
        cardColor: const Color(0xFFFEFEFE), // Pure mystical white
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFEFEFE),
          foregroundColor: Color(0xFF1E293B),
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
      );

  ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7C3AED), // More mystical purple
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor:
            const Color(0xFF0C1220), // Deeper mystical dark
        cardColor: const Color(0xFF1A2332), // Richer dark tone
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A2332),
          foregroundColor: Color(0xFFE2E8F0), // Softer white
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
      );

  ThemeData get currentTheme => _isDarkMode ? darkTheme : lightTheme;
}
