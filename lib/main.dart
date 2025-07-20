import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Core imports
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/services/navigation_service.dart';
import 'core/services/api_service.dart';
import 'core/services/location_service.dart';
import 'core/services/cache_service.dart';

// Feature imports
import 'features/home/providers/home_provider.dart';
import 'features/profile/providers/profile_provider.dart';
import 'features/search/provider/search_provider.dart';

// Shared imports
import 'shared/providers/app_provider.dart';
import 'shared/widgets/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure system UI
  await _configureSystemUI();

  // Initialize Hive for local storage
  await _initializeHive();

  // Initialize app services
  await AppInitializer.initialize();

  runApp(const NearbyPGApp());
}

/// Configure system UI overlay and orientations
Future<void> _configureSystemUI() async {
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
}

/// Initialize Hive database
Future<void> _initializeHive() async {
  await Hive.initFlutter();

  // Open necessary Hive boxes with error handling
  try {
    await Future.wait([
      Hive.openBox(AppConstants.userPreferencesBox),
      Hive.openBox(AppConstants.cacheBox),
      Hive.openBox('pg_data_cache'),
      Hive.openBox(AppConstants.searchHistoryBox),
      Hive.openBox(AppConstants.bookingCacheBox),
    ]);
    debugPrint('✅ Hive databases initialized successfully');
  } catch (e) {
    debugPrint('❌ Error initializing Hive: $e');
  }
}

class NearbyPGApp extends StatelessWidget {
  const NearbyPGApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Core app provider
        ChangeNotifierProvider(create: (_) => AppProvider()),

        // Feature providers with proper initialization order
        ChangeNotifierProvider(create: (_) => HomeProvider(), lazy: true),
        ChangeNotifierProvider(create: (_) => SearchProvider(), lazy: true),
        ChangeNotifierProvider(create: (_) => ProfileProvider(), lazy: true),
      ],
      child: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,

            // Theme configuration
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: appProvider.themeMode,

            // Navigation
            navigatorKey: NavigationService.navigatorKey,
            onGenerateRoute: NavigationService.generateRoute,
            initialRoute: AppConstants.splashRoute,

            // Localization
            locale: const Locale('en', 'US'),
            supportedLocales: const [Locale('en', 'US'), Locale('hi', 'IN')],

            // Performance optimizations
            builder: (context, child) {
              return MediaQuery(
                // Ensure text scaling doesn't break layouts
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(
                    MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.3),
                  ),
                ),
                child: child!,
              );
            },

            // Global error handling
            onUnknownRoute: (settings) {
              return MaterialPageRoute(
                builder:
                    (_) => Scaffold(
                      appBar: AppBar(title: const Text('Page Not Found')),
                      body: const Center(
                        child: Text('The requested page could not be found.'),
                      ),
                    ),
              );
            },
          );
        },
      ),
    );
  }
}

/// Enhanced app initialization and dependency injection
class AppInitializer {
  static Future<void> initialize() async {
    final stopwatch = Stopwatch()..start();

    try {
      // Initialize core services in parallel where possible
      await Future.wait([_initializeServices(), _loadUserPreferences()]);

      // Setup error handling
      _setupErrorHandling();

      stopwatch.stop();
      debugPrint(
        '✅ App initialization completed in ${stopwatch.elapsedMilliseconds}ms',
      );
    } catch (e) {
      debugPrint('❌ App initialization failed: $e');
      rethrow;
    }
  }

  static Future<void> _initializeServices() async {
    try {
      // Initialize services in dependency order
      await ApiService().initialize();
      await LocationService().initialize();
      await CacheService().initialize();

      debugPrint('✅ Core services initialized');
    } catch (e) {
      debugPrint('❌ Service initialization error: $e');
      // Continue with app launch even if some services fail
    }
  }

  static Future<void> _loadUserPreferences() async {
    try {
      final cacheService = CacheService();
      final userProfile = await cacheService.getCachedUserProfile();

      if (userProfile != null) {
        debugPrint('✅ User profile loaded from cache');
      }
    } catch (e) {
      debugPrint('⚠️ Error loading user preferences: $e');
    }
  }

  static void _setupErrorHandling() {
    // Flutter error handling
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      _logError('Flutter Error', details.exception, details.stack);
    };

    // Platform error handling
    PlatformDispatcher.instance.onError = (error, stack) {
      _logError('Platform Error', error, stack);
      return true;
    };
  }

  static void _logError(String type, Object error, StackTrace? stack) {
    debugPrint('❌ $type: $error');
    if (stack != null) {
      debugPrint('Stack trace: $stack');
    }

    // TODO: Send to crash analytics in production
    if (AppConfig.isProduction) {
      // FirebaseCrashlytics.instance.recordError(error, stack);
    }
  }
}

/// Enhanced app configuration
class AppConfig {
  static const String version = '1.0.0';
  static const String buildNumber = '1';

  // Environment configurations
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');
  static const bool isDebug = !isProduction;
  static const bool isStaging = bool.fromEnvironment(
    'STAGING',
    defaultValue: false,
  );

  // API configurations with environment support
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://api.nearbypg.com/v1',
  );

  static const String googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: '',
  );

  // Feature flags with environment support
  static const bool enableAnalytics = bool.fromEnvironment(
    'ENABLE_ANALYTICS',
    defaultValue: true,
  );

  static const bool enableCrashReporting = bool.fromEnvironment(
    'ENABLE_CRASH_REPORTING',
    defaultValue: true,
  );

  static const bool enableLocationTracking = bool.fromEnvironment(
    'ENABLE_LOCATION_TRACKING',
    defaultValue: true,
  );

  // Performance configurations
  static const int maxImageCacheSize = 100; // Number of images
  static const int maxImageCacheSizeMB = 50; // Size in MB
  static const Duration networkTimeout = Duration(seconds: 30);

  /// Get environment display name
  static String get environmentName {
    if (isProduction) return 'Production';
    if (isStaging) return 'Staging';
    return 'Development';
  }

  /// Check if debug features should be enabled
  static bool get enableDebugFeatures => isDebug || isStaging;
}

/// Enhanced performance monitoring
class PerformanceUtils {
  static final Map<String, Stopwatch> _activeOperations = {};

  /// Start performance measurement
  static void startMeasurement(String operation) {
    _activeOperations[operation] = Stopwatch()..start();
  }

  /// End performance measurement and log result
  static void endMeasurement(String operation) {
    final stopwatch = _activeOperations.remove(operation);
    if (stopwatch != null) {
      stopwatch.stop();
      _logPerformance(operation, stopwatch.elapsed);
    }
  }

  /// Log performance with appropriate level
  static void _logPerformance(String operation, Duration duration) {
    final ms = duration.inMilliseconds;

    if (AppConfig.enableDebugFeatures) {
      String emoji = '⚡'; // Fast
      if (ms > 1000) {
        emoji = '🐌'; // Slow
      } else if (ms > 500) {
        emoji = '⏰'; // Medium
      }

      debugPrint('$emoji Performance: $operation took ${ms}ms');
    }

    // Alert for slow operations in development
    if (AppConfig.isDebug && ms > 2000) {
      debugPrint('⚠️ Slow operation detected: $operation (${ms}ms)');
    }
  }

  /// Measure async operation performance
  static Future<T> measureAsync<T>(
    String operation,
    Future<T> Function() action,
  ) async {
    startMeasurement(operation);
    try {
      final result = await action();
      return result;
    } finally {
      endMeasurement(operation);
    }
  }

  /// Measure sync operation performance
  static T measureSync<T>(String operation, T Function() action) {
    startMeasurement(operation);
    try {
      final result = action();
      return result;
    } finally {
      endMeasurement(operation);
    }
  }
}

/// Enhanced memory management
class MemoryUtils {
  /// Clear image cache to free memory
  static void clearImageCache() {
    try {
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
      debugPrint('✅ Image cache cleared');
    } catch (e) {
      debugPrint('❌ Error clearing image cache: $e');
    }
  }

  /// Optimize memory usage with size limits
  static void optimizeImageCache() {
    try {
      final imageCache = PaintingBinding.instance.imageCache;
      imageCache.maximumSize = AppConfig.maxImageCacheSize;
      imageCache.maximumSizeBytes = AppConfig.maxImageCacheSizeMB * 1024 * 1024;
      debugPrint('✅ Image cache optimized');
    } catch (e) {
      debugPrint('❌ Error optimizing image cache: $e');
    }
  }

  /// Get current memory usage stats
  static Map<String, dynamic> getMemoryStats() {
    final imageCache = PaintingBinding.instance.imageCache;
    return {
      'currentSize': imageCache.currentSize,
      'currentSizeBytes': imageCache.currentSizeBytes,
      'maximumSize': imageCache.maximumSize,
      'maximumSizeBytes': imageCache.maximumSizeBytes,
      'liveImageCount': imageCache.liveImageCount,
    };
  }

  /// Perform memory cleanup
  static void performCleanup() {
    if (AppConfig.enableDebugFeatures) {
      debugPrint('🧹 Performing memory cleanup...');
      final statsBefore = getMemoryStats();

      clearImageCache();

      final statsAfter = getMemoryStats();
      debugPrint(
        'Memory cleanup: ${statsBefore['currentSize']} -> ${statsAfter['currentSize']} images',
      );
    }
  }
}
