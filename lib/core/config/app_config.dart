import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';

/// Centralized app configuration and environment management
class AppConfig {
  static late PackageInfo _packageInfo;
  static late DeviceInfoPlugin _deviceInfo;
  static Map<String, dynamic>? _deviceData;

  // Private constructor
  AppConfig._();

  /// Initialize app configuration
  static Future<void> initialize() async {
    _packageInfo = await PackageInfo.fromPlatform();
    _deviceInfo = DeviceInfoPlugin();
    await _loadDeviceInfo();
  }

  /// Load device information
  static Future<void> _loadDeviceInfo() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        _deviceData = {
          'platform': 'Android',
          'model': androidInfo.model,
          'version': androidInfo.version.release,
          'sdkInt': androidInfo.version.sdkInt,
          'manufacturer': androidInfo.manufacturer,
          'brand': androidInfo.brand,
        };
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        _deviceData = {
          'platform': 'iOS',
          'model': iosInfo.model,
          'version': iosInfo.systemVersion,
          'name': iosInfo.name,
          'systemName': iosInfo.systemName,
        };
      }
    } catch (e) {
      _deviceData = {'platform': 'Unknown', 'error': e.toString()};
    }
  }

  // App Information
  static String get appName => _packageInfo.appName;
  static String get packageName => _packageInfo.packageName;
  static String get version => _packageInfo.version;
  static String get buildNumber => _packageInfo.buildNumber;
  static String get appDisplayName => 'NEARBY PG';
  static String get appTagline => 'Find Your Perfect PG';

  // Environment Configuration
  static const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );

  static bool get isProduction => environment == 'production';
  static bool get isDevelopment => environment == 'development';
  static bool get isStaging => environment == 'staging';
  static bool get isDebug => kDebugMode;
  static bool get isRelease => kReleaseMode;

  // API Configuration
  static String get baseUrl {
    switch (environment) {
      case 'production':
        return 'https://api.nearbypg.com/v1';
      case 'staging':
        return 'https://staging-api.nearbypg.com/v1';
      default:
        return 'https://dev-api.nearbypg.com/v1';
    }
  }

  static const String apiVersion = 'v1';
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Database Configuration
  static const String databaseName = 'nearby_pg.db';
  static const int databaseVersion = 1;

  // Cache Configuration
  static const Duration shortCacheExpiry = Duration(minutes: 15);
  static const Duration mediumCacheExpiry = Duration(hours: 2);
  static const Duration longCacheExpiry = Duration(hours: 24);
  static const Duration veryLongCacheExpiry = Duration(days: 7);
  static const int maxCacheSize = 100; // MB
  static const int maxCacheItems = 1000;

  // Feature Flags
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;
  static const bool enablePerformanceMonitoring = true;
  static const bool enableLocationTracking = true;
  static const bool enablePushNotifications = true;
  static const bool enableBiometricAuth = true;
  static const bool enableOfflineMode = true;
  static const bool enableDarkMode = true;
  static const bool enableDeepLinking = true;
  static bool get isFirebaseEnabled => !isDevelopment;

  // UI Configuration
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration shortAnimationDuration = Duration(milliseconds: 150);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
  static const Duration splashDuration = Duration(seconds: 2);
  static const Duration debounceDelay = Duration(milliseconds: 300);

  // Search Configuration
  static const int maxRecentSearches = 10;
  static const int searchSuggestionLimit = 8;
  static const int defaultPageSize = 20;
  static const int maxPageSize = 50;

  // Location Configuration
  static const double defaultLatitude = 28.6139; // New Delhi
  static const double defaultLongitude = 77.2090;
  static const double maxSearchRadius = 50.0; // km
  static const double defaultSearchRadius = 10.0; // km
  static const Duration locationTimeout = Duration(seconds: 15);

  // Image Configuration
  static const int imageCompressionQuality = 85;
  static const int maxImageSizeKB = 2048;
  static const int thumbnailSize = 200;
  static const int mediumImageSize = 600;
  static const int largeImageSize = 1200;
  static const List<String> allowedImageFormats = [
    'jpg',
    'jpeg',
    'png',
    'webp'
  ];

  // Validation Configuration
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int otpLength = 6;
  static const int phoneNumberLength = 10;
  static const Duration otpResendDelay = Duration(seconds: 30);
  static const Duration otpExpiry = Duration(minutes: 5);
  static const int maxLoginAttempts = 5;

  // Business Logic Configuration
  static const double minBudgetRange = 1000.0;
  static const double maxBudgetRange = 50000.0;
  static const double budgetStep = 500.0;
  static const int maxAdvanceBookingDays = 90;
  static const int minAdvanceBookingDays = 1;
  static const Duration bookingTimeoutDuration = Duration(minutes: 15);
  static const double minRating = 1.0;
  static const double maxRating = 5.0;
  static const int maxReviewLength = 500;
  static const int minReviewLength = 10;

  // Currency and Localization
  static const String currency = '₹';
  static const String currencyCode = 'INR';
  static const String defaultLocale = 'en_IN';
  static const List<Locale> supportedLocales = [
    Locale('en', 'IN'),
    Locale('hi', 'IN'),
  ];

  // Contact Information
  static const String supportEmail = 'support@nearbypg.com';
  static const String supportPhone = '+91-1234567890';
  static const String companyAddress = 'Bangalore, Karnataka, India';
  static const String website = 'https://nearbypg.com';

  // Social Media
  static const String facebookUrl = 'https://facebook.com/nearbypg';
  static const String twitterUrl = 'https://twitter.com/nearbypg';
  static const String instagramUrl = 'https://instagram.com/nearbypg';
  static const String linkedinUrl = 'https://linkedin.com/company/nearbypg';

  // App Store Links
  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.nearbypg.app';
  static const String appStoreUrl =
      'https://apps.apple.com/app/nearby-pg/id123456789';

  // Storage Keys
  static const String userTokenKey = 'user_token';
  static const String userIdKey = 'user_id';
  static const String userProfileKey = 'user_profile';
  static const String themeModeKey = 'theme_mode';
  static const String languageKey = 'language';
  static const String firstTimeKey = 'first_time';
  static const String locationPermissionKey = 'location_permission';
  static const String notificationPermissionKey = 'notification_permission';
  static const String biometricAuthKey = 'biometric_auth';
  static const String lastLocationKey = 'last_location';
  static const String searchFiltersKey = 'search_filters';
  static const String wishlistKey = 'wishlist';
  static const String recentSearchesKey = 'recent_searches';

  // Hive Box Names
  static const String userPreferencesBox = 'user_preferences';
  static const String cacheBox = 'cache';
  static const String pgDataBox = 'pg_data';
  static const String searchHistoryBox = 'search_history';
  static const String bookingCacheBox = 'booking_cache';
  static const String imagesCacheBox = 'images_cache';

  // Error Messages
  static const String errorGeneric = 'Something went wrong. Please try again.';
  static const String errorNetwork =
      'Please check your internet connection and try again.';
  static const String errorTimeout = 'Request timed out. Please try again.';
  static const String errorUnauthorized = 'Please login to continue.';
  static const String errorNotFound = 'The requested resource was not found.';
  static const String errorServerError =
      'Server error. Please try again later.';
  static const String errorInvalidInput =
      'Please check your input and try again.';
  static const String errorLocationPermission =
      'Location permission is required to find nearby PGs.';
  static const String errorLocationUnavailable =
      'Unable to get your location. Please enable GPS.';
  static const String errorNoInternet = 'No internet connection available.';
  static const String errorCacheCorrupted =
      'Cache data is corrupted. Refreshing...';

  // Success Messages
  static const String successLogin = 'Successfully logged in!';
  static const String successLogout = 'Successfully logged out!';
  static const String successProfileUpdate = 'Profile updated successfully!';
  static const String successBooking = 'Booking confirmed successfully!';
  static const String successWishlistAdd = 'Added to wishlist!';
  static const String successWishlistRemove = 'Removed from wishlist!';
  static const String successReviewSubmit = 'Review submitted successfully!';

  // Device Information
  static Map<String, dynamic>? get deviceInfo => _deviceData;
  static String get platform => Platform.operatingSystem;
  static bool get isAndroid => Platform.isAndroid;
  static bool get isIOS => Platform.isIOS;

  // Responsive Design Breakpoints
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;
  static const double desktopBreakpoint = 1200.0;
  static const double maxContentWidth = 1400.0;

  // Performance Configuration
  static const int maxConcurrentApiCalls = 3;
  static const Duration cacheCleanupInterval = Duration(hours: 6);
  static const int maxImageCacheSize = 50; // MB
  static const int maxNetworkCacheSize = 100; // MB

  // Security Configuration
  static const Duration sessionTimeout = Duration(hours: 24);
  static const Duration refreshTokenExpiry = Duration(days: 30);
  static const int maxFileUploadSizeMB = 10;
  static const List<String> allowedFileTypes = [
    'image/jpeg',
    'image/png',
    'image/webp'
  ];

  // Analytics Events
  static const String eventAppOpen = 'app_open';
  static const String eventLogin = 'login';
  static const String eventSignup = 'signup';
  static const String eventSearch = 'search';
  static const String eventPgView = 'pg_view';
  static const String eventBookingStart = 'booking_start';
  static const String eventBookingComplete = 'booking_complete';
  static const String eventWishlistAdd = 'wishlist_add';
  static const String eventFilterApply = 'filter_apply';
  static const String eventContactPg = 'contact_pg';
  static const String eventSharePg = 'share_pg';
  static const String eventError = 'error_occurred';
  static const String eventPerformance = 'performance_metric';

  /// Get app configuration as map for debugging
  static Map<String, dynamic> toMap() {
    return {
      'appName': appName,
      'version': version,
      'buildNumber': buildNumber,
      'environment': environment,
      'baseUrl': baseUrl,
      'isProduction': isProduction,
      'isDevelopment': isDevelopment,
      'isDebug': isDebug,
      'deviceInfo': deviceInfo,
      'features': {
        'analytics': enableAnalytics,
        'crashReporting': enableCrashReporting,
        'locationTracking': enableLocationTracking,
        'pushNotifications': enablePushNotifications,
        'biometricAuth': enableBiometricAuth,
        'offlineMode': enableOfflineMode,
        'darkMode': enableDarkMode,
      },
    };
  }

  /// Validate configuration
  static bool validateConfiguration() {
    try {
      // Validate required configurations
      assert(appName.isNotEmpty, 'App name cannot be empty');
      assert(baseUrl.isNotEmpty, 'Base URL cannot be empty');
      assert(apiTimeout.inSeconds > 0, 'API timeout must be positive');
      assert(defaultPageSize > 0, 'Default page size must be positive');
      assert(maxPageSize > defaultPageSize,
          'Max page size must be greater than default');

      return true;
    } catch (e) {
      return false;
    }
  }
}

/// App configuration extensions
extension AppConfigExtensions on AppConfig {
  /// Get environment-specific configuration
  static Map<String, dynamic> getEnvironmentConfig() {
    return {
      'baseUrl': AppConfig.baseUrl,
      'apiTimeout': AppConfig.apiTimeout.inSeconds,
      'cacheExpiry': AppConfig.mediumCacheExpiry.inHours,
      'features': {
        'analytics': AppConfig.enableAnalytics,
        'crashReporting': AppConfig.enableCrashReporting,
      },
    };
  }

  /// Check if feature is enabled
  static bool isFeatureEnabled(String feature) {
    switch (feature.toLowerCase()) {
      case 'analytics':
        return AppConfig.enableAnalytics;
      case 'crash_reporting':
        return AppConfig.enableCrashReporting;
      case 'location_tracking':
        return AppConfig.enableLocationTracking;
      case 'push_notifications':
        return AppConfig.enablePushNotifications;
      case 'biometric_auth':
        return AppConfig.enableBiometricAuth;
      case 'offline_mode':
        return AppConfig.enableOfflineMode;
      case 'dark_mode':
        return AppConfig.enableDarkMode;
      default:
        return false;
    }
  }
}
