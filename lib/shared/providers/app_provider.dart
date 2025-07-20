import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _isFirstTime = true;

  ThemeMode get themeMode => _themeMode;
  bool get isFirstTime => _isFirstTime;

  AppProvider() {
    _loadPreferences();
  }

  void _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode = ThemeMode.values[prefs.getInt('theme_mode') ?? 0];
    _isFirstTime = prefs.getBool('first_time') ?? true;
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', mode.index);
    notifyListeners();
  }

  void setFirstTime(bool value) async {
    _isFirstTime = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_time', value);
    notifyListeners();
  }
}
