// lib/shared/providers/app_provider.dart
import 'package:flutter/material.dart';
import '../../core/services/cache_service.dart';
import '../../core/constants/app_constants.dart';

/// Global app state provider
class AppProvider extends ChangeNotifier {
  // Theme settings
  ThemeMode _themeMode = ThemeMode.system;

  // App settings
  bool _isFirstLaunch = true;
  bool _isLoggedIn = false;
  bool _isOnboardingComplete = false;

  // Locale settings
  Locale _locale = const Locale('en', 'US');

  // Service instances
  final CacheService _cacheService = CacheService();

  bool _isFirstTime = true;

  // Getters
  ThemeMode get themeMode => _themeMode;
  bool get isFirstLaunch => _isFirstLaunch;
  bool get isLoggedIn => _isLoggedIn;
  bool get isOnboardingComplete => _isOnboardingComplete;
  Locale get locale => _locale;

  /// Initialize app provider
  Future<void> initialize() async {
    await _loadSettings();
  }

  /// Load settings from cache
  Future<void> _loadSettings() async {
    try {
      // Load theme settings
      final themeSetting = await _cacheService.getUserPreference<String>(
        'theme_mode',
      );
      if (themeSetting != null) {
        _setThemeMode(themeSetting);
      }

      // Load app state
      _isFirstLaunch =
          await _cacheService.getUserPreference<bool>('is_first_launch') ??
              true;
      _isOnboardingComplete = await _cacheService.getUserPreference<bool>(
            'is_onboarding_complete',
          ) ??
          false;

      // Load locale settings
      final languageCode = await _cacheService.getUserPreference<String>(
        'language_code',
      );
      final countryCode = await _cacheService.getUserPreference<String>(
        'country_code',
      );

      if (languageCode != null) {
        _locale = Locale(languageCode, countryCode);
      }

      // Check login status
      final authToken = await _cacheService.getAuthToken();
      _isLoggedIn = authToken != null && authToken.isNotEmpty;

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }

  /// Set theme mode (light/dark/system)
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;

    String themeSetting;
    switch (mode) {
      case ThemeMode.light:
        themeSetting = 'light';
        break;
      case ThemeMode.dark:
        themeSetting = 'dark';
        break;
      case ThemeMode.system:
      default:
        themeSetting = 'system';
        break;
    }

    await _cacheService.saveUserPreference<String>('theme_mode', themeSetting);
    notifyListeners();
  }

  /// Parse theme mode from string
  void _setThemeMode(String themeSetting) {
    switch (themeSetting) {
      case 'light':
        _themeMode = ThemeMode.light;
        break;
      case 'dark':
        _themeMode = ThemeMode.dark;
        break;
      case 'system':
      default:
        _themeMode = ThemeMode.system;
        break;
    }
  }

  /// Set app locale
  Future<void> setLocale(Locale newLocale) async {
    _locale = newLocale;

    await _cacheService.saveUserPreference<String>(
      'language_code',
      newLocale.languageCode,
    );
    await _cacheService.saveUserPreference<String>(
      'country_code',
      newLocale.countryCode ?? '',
    );

    notifyListeners();
  }

  /// Mark first launch as complete
  Future<void> completeFirstLaunch() async {
    _isFirstLaunch = false;
    await _cacheService.saveUserPreference<bool>('is_first_launch', false);
    notifyListeners();
  }

  /// Mark onboarding as complete
  Future<void> completeOnboarding() async {
    _isOnboardingComplete = true;
    await _cacheService.saveUserPreference<bool>(
      'is_onboarding_complete',
      true,
    );
    notifyListeners();
  }

  /// Handle user login
  Future<void> setLoggedIn(bool value, {String? token, String? userId}) async {
    _isLoggedIn = value;

    if (value && token != null) {
      await _cacheService.saveAuthToken(token);

      if (userId != null) {
        await _cacheService.saveUserId(userId);
      }
    } else if (!value) {
      await _cacheService.clearUserData();
    }

    notifyListeners();
  }

  /// Log out user
  Future<void> logout() async {
    await setLoggedIn(false);
  }

  void setFirstTime(bool bool) {
    _isFirstTime = bool;
    notifyListeners();
  }
}
