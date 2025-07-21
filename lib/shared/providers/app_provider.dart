// lib/shared/providers/app_provider.dart
import 'package:flutter/material.dart';
import 'package:nearby_pg/core/services/cache_service.dart';

/// Global app state provider
class AppProvider extends ChangeNotifier {
  // Initialization state
  bool _isInitialized = false;
  bool _isInitializing = false;

  // Theme settings
  ThemeMode _themeMode = ThemeMode.system;

  // App settings
  bool _isFirstLaunch = true;
  bool _isLoggedIn = false;
  bool _isOnboardingComplete = false;
  bool _isFirstTime = true;

  // Navigation state
  bool _shouldShowSplash = true;
  String _lastRoute = '/';

  // Locale settings
  Locale _locale = const Locale('en', 'US');

  // Service instances
  CacheService? _cacheService;

  // Loading states
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isInitializing => _isInitializing;
  ThemeMode get themeMode => _themeMode;
  bool get isFirstLaunch => _isFirstLaunch;
  bool get isLoggedIn => _isLoggedIn;
  bool get isOnboardingComplete => _isOnboardingComplete;
  bool get isFirstTime => _isFirstTime;
  bool get shouldShowSplash => _shouldShowSplash;
  String get lastRoute => _lastRoute;
  Locale get locale => _locale;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Constructor
  AppProvider();

  /// Initialize app provider with dependency injection
  Future<void> initialize({CacheService? cacheService}) async {
    if (_isInitialized || _isInitializing) return;

    _isInitializing = true;
    _setLoading(true);
    _clearError();
    notifyListeners();

    try {
      // Initialize cache service
      _cacheService = cacheService ?? CacheService();
      await _ensureCacheServiceInitialized();

      // Load all settings
      await _loadSettings();

      // Determine initial navigation state
      _determineInitialNavigationState();

      _isInitialized = true;
      _setLoading(false);

      debugPrint('✅ AppProvider initialized successfully');
    } catch (e, stackTrace) {
      _setError('Failed to initialize app: $e');
      debugPrint('❌ AppProvider initialization failed: $e');
      debugPrint('Stack trace: $stackTrace');
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  /// Ensure the cache service is initialized
  Future<void> _ensureCacheServiceInitialized() async {
    if (_cacheService == null) {
      throw Exception('CacheService not provided');
    }

    try {
      await _cacheService!.initialize();
      debugPrint('✅ CacheService initialized');
    } catch (e) {
      debugPrint('❌ Error initializing cache service: $e');
      rethrow;
    }
  }

  /// Load settings from cache
  Future<void> _loadSettings() async {
    if (_cacheService == null) return;

    try {
      await Future.wait([
        _loadThemeSettings(),
        _loadAppState(),
        _loadLocaleSettings(),
        _loadAuthState(),
        _loadNavigationState(),
      ]);

      debugPrint('✅ All settings loaded successfully');
    } catch (e) {
      debugPrint('❌ Error loading settings: $e');
      rethrow;
    }
  }

  /// Load theme settings
  Future<void> _loadThemeSettings() async {
    try {
      final themeSetting = await _cacheService!.getUserPreference<String>(
        'theme_mode',
      );
      if (themeSetting != null) {
        _setThemeMode(themeSetting);
      }
      debugPrint('✅ Theme settings loaded: $_themeMode');
    } catch (e) {
      debugPrint('⚠️ Error loading theme settings, using default: $e');
    }
  }

  /// Load app state
  Future<void> _loadAppState() async {
    try {
      _isFirstLaunch = await _cacheService!.getUserPreference<bool>(
            'is_first_launch',
          ) ??
          true;

      _isOnboardingComplete = await _cacheService!.getUserPreference<bool>(
            'is_onboarding_complete',
          ) ??
          false;

      _isFirstTime = await _cacheService!.getUserPreference<bool>(
            'is_first_time',
          ) ??
          true;

      debugPrint(
          '✅ App state loaded - FirstLaunch: $_isFirstLaunch, OnboardingComplete: $_isOnboardingComplete');
    } catch (e) {
      debugPrint('⚠️ Error loading app state, using defaults: $e');
      _isFirstLaunch = true;
      _isOnboardingComplete = false;
      _isFirstTime = true;
    }
  }

  /// Load locale settings
  Future<void> _loadLocaleSettings() async {
    try {
      final languageCode = await _cacheService!.getUserPreference<String>(
        'language_code',
      );
      final countryCode = await _cacheService!.getUserPreference<String>(
        'country_code',
      );

      if (languageCode != null) {
        _locale = Locale(languageCode, countryCode);
      }
      debugPrint('✅ Locale settings loaded: $_locale');
    } catch (e) {
      debugPrint('⚠️ Error loading locale settings, using default: $e');
    }
  }

  /// Load authentication state
  Future<void> _loadAuthState() async {
    try {
      final authToken = await _cacheService!.getAuthToken();
      _isLoggedIn = authToken != null && authToken.isNotEmpty;
      debugPrint('✅ Auth state loaded - LoggedIn: $_isLoggedIn');
    } catch (e) {
      debugPrint('⚠️ Error loading auth state, assuming logged out: $e');
      _isLoggedIn = false;
    }
  }

  /// Load navigation state
  Future<void> _loadNavigationState() async {
    try {
      _lastRoute = await _cacheService!.getUserPreference<String>(
            'last_route',
          ) ??
          '/';

      // Check if we should show splash (first time users or after updates)
      final appVersion = await _cacheService!.getUserPreference<String>(
        'app_version',
      );
      const currentVersion = '1.0.0'; // You can get this from package_info

      _shouldShowSplash = _isFirstLaunch || appVersion != currentVersion;

      debugPrint(
          '✅ Navigation state loaded - LastRoute: $_lastRoute, ShowSplash: $_shouldShowSplash');
    } catch (e) {
      debugPrint('⚠️ Error loading navigation state, using defaults: $e');
      _lastRoute = '/';
      _shouldShowSplash = true;
    }
  }

  /// Determine initial navigation state based on app state
  void _determineInitialNavigationState() {
    // Logic to determine where the user should be taken after initialization
    if (_isFirstLaunch) {
      _shouldShowSplash = true;
    } else if (!_isOnboardingComplete) {
      _lastRoute = '/onboarding';
    } else if (!_isLoggedIn) {
      _lastRoute = '/login';
    } else {
      _lastRoute = '/';
    }

    debugPrint(
        '🎯 Initial navigation determined - Route: $_lastRoute, ShowSplash: $_shouldShowSplash');
  }

  /// Set theme mode (light/dark/system)
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

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

    try {
      await _cacheService?.saveUserPreference<String>(
        'theme_mode',
        themeSetting,
      );
      debugPrint('✅ Theme mode saved: $themeSetting');
    } catch (e) {
      debugPrint('❌ Error saving theme mode: $e');
    }

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
    if (_locale == newLocale) return;

    _locale = newLocale;

    try {
      await Future.wait([
        _cacheService!.saveUserPreference<String>(
          'language_code',
          newLocale.languageCode,
        ),
        _cacheService!.saveUserPreference<String>(
          'country_code',
          newLocale.countryCode ?? '',
        ),
      ]);
      debugPrint('✅ Locale saved: $newLocale');
    } catch (e) {
      debugPrint('❌ Error saving locale: $e');
    }

    notifyListeners();
  }

  /// Mark first launch as complete
  Future<void> completeFirstLaunch() async {
    if (!_isFirstLaunch) return;

    _isFirstLaunch = false;

    try {
      await _cacheService?.saveUserPreference<bool>('is_first_launch', false);
      debugPrint('✅ First launch completed');
    } catch (e) {
      debugPrint('❌ Error saving first launch status: $e');
    }

    notifyListeners();
  }

  /// Mark onboarding as complete
  Future<void> completeOnboarding() async {
    if (_isOnboardingComplete) return;

    _isOnboardingComplete = true;

    try {
      await _cacheService?.saveUserPreference<bool>(
        'is_onboarding_complete',
        true,
      );
      debugPrint('✅ Onboarding completed');
    } catch (e) {
      debugPrint('❌ Error saving onboarding status: $e');
    }

    notifyListeners();
  }

  /// Set first time flag
  Future<void> setFirstTime(bool value) async {
    if (_isFirstTime == value) return;

    _isFirstTime = value;

    try {
      await _cacheService?.saveUserPreference<bool>('is_first_time', value);
      debugPrint('✅ First time flag set to: $value');
    } catch (e) {
      debugPrint('❌ Error saving first time flag: $e');
    }

    notifyListeners();
  }

  /// Handle user login
  Future<void> setLoggedIn(bool value, {String? token, String? userId}) async {
    if (_isLoggedIn == value) return;

    _isLoggedIn = value;

    try {
      if (value && token != null) {
        await _cacheService?.saveAuthToken(token);

        if (userId != null) {
          await _cacheService?.saveUserId(userId);
        }
        debugPrint('✅ User logged in');
      } else if (!value) {
        await _cacheService?.clearUserData();
        debugPrint('✅ User logged out');
      }
    } catch (e) {
      debugPrint('❌ Error handling login state: $e');
    }

    notifyListeners();
  }

  /// Log out user
  Future<void> logout() async {
    await setLoggedIn(false);
  }

  /// Update last route for navigation persistence
  Future<void> updateLastRoute(String route) async {
    if (_lastRoute == route) return;

    _lastRoute = route;

    try {
      await _cacheService?.saveUserPreference<String>('last_route', route);
      debugPrint('✅ Last route updated: $route');
    } catch (e) {
      debugPrint('❌ Error saving last route: $e');
    }

    notifyListeners();
  }

  /// Mark splash as shown
  void completeSplash() {
    if (!_shouldShowSplash) return;

    _shouldShowSplash = false;
    notifyListeners();
    debugPrint('✅ Splash completed');
  }

  /// Save app version
  Future<void> saveAppVersion(String version) async {
    try {
      await _cacheService?.saveUserPreference<String>('app_version', version);
      debugPrint('✅ App version saved: $version');
    } catch (e) {
      debugPrint('❌ Error saving app version: $e');
    }
  }

  /// Reset app to initial state (for testing or hard reset)
  Future<void> resetApp() async {
    try {
      await _cacheService?.clearAllData();

      // Reset all state
      _isFirstLaunch = true;
      _isLoggedIn = false;
      _isOnboardingComplete = false;
      _isFirstTime = true;
      _shouldShowSplash = true;
      _lastRoute = '/';
      _themeMode = ThemeMode.system;
      _locale = const Locale('en', 'US');

      debugPrint('✅ App reset completed');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error resetting app: $e');
      _setError('Failed to reset app: $e');
    }
  }

  /// Set loading state
  void _setLoading(bool loading) {
    if (_isLoading == loading) return;
    _isLoading = loading;
  }

  /// Set error message
  void _setError(String error) {
    _errorMessage = error;
  }

  /// Clear error message
  void _clearError() {
    _errorMessage = null;
  }

  /// Clear any errors
  void clearError() {
    _clearError();
    notifyListeners();
  }

  /// Refresh/reload app state
  Future<void> refresh() async {
    if (!_isInitialized) {
      await initialize(cacheService: _cacheService);
      return;
    }

    _setLoading(true);
    _clearError();
    notifyListeners();

    try {
      await _loadSettings();
      _setLoading(false);
      debugPrint('✅ App state refreshed');
    } catch (e) {
      _setError('Failed to refresh app state: $e');
      _setLoading(false);
      debugPrint('❌ Error refreshing app state: $e');
    }

    notifyListeners();
  }

  @override
  void dispose() {
    debugPrint('🔄 AppProvider disposed');
    super.dispose();
  }
}
