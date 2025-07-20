import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nearby_pg/features/search/provider/search_provider.dart';
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

// Shared imports
import 'shared/providers/app_provider.dart';
import 'shared/widgets/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Open necessary Hive boxes
  await Hive.openBox(AppConstants.userPreferencesBox);
  await Hive.openBox(AppConstants.cacheBox);

  // Initialize app services
  await AppInitializer.initialize();

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
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const NearbyPGApp());
}

class NearbyPGApp extends StatelessWidget {
  const NearbyPGApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Core providers
        ChangeNotifierProvider(create: (_) => AppProvider()),

        // Feature providers
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ],
      child: Consumer<AppProvider>(
        builder: (context, appProvider, _) {
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

            // Builder for global configurations
            builder: (context, child) {
              return MediaQuery(
                // Ensure text scaling doesn't break layouts
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(MediaQuery.of(
                    context,
                  ).textScaleFactor.clamp(0.8, 1.2)),
                ),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}

/// App initialization and dependency injection
class AppInitializer {
  static Future<void> initialize() async {
    // Initialize core services
    await _initializeServices();

    // Load user preferences
    await _loadUserPreferences();

    // Setup error handling
    _setupErrorHandling();
  }

  static Future<void> _initializeServices() async {
    // Initialize API service
    await ApiService().initialize();

    // Initialize location service
    await LocationService().initialize();

    // Initialize cache service
    await CacheService().initialize();

    debugPrint('All core services initialized');
  }

  static Future<void> _loadUserPreferences() async {
    try {
      final cacheService = CacheService();
      final userProfile = await cacheService.getCachedUserProfile();
      if (userProfile != null) {
        debugPrint('User profile loaded from cache');
      }
    } catch (e) {
      debugPrint('Error loading user preferences: $e');
    }
  }

  static void _setupErrorHandling() {
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      debugPrint('Flutter error: ${details.exception}');
      // TODO: Log errors to crash analytics
    };
  }
}

/// Global app configuration and utilities
class AppConfig {
  static const String version = '1.0.0';
  static const String buildNumber = '1';

  // Environment configurations
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');
  static const bool isDebug = !isProduction;

  // API configurations
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://api.nearbypg.com/v1',
  );

  static const String googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: '',
  );

  // Feature flags
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;
  static const bool enableLocationTracking = true;
}

/// Performance monitoring and optimization utilities
class PerformanceUtils {
  static void logPerformance(String operation, Duration duration) {
    if (AppConfig.isDebug) {
      debugPrint('Performance: $operation took ${duration.inMilliseconds}ms');
    }
  }

  static Future<T> measurePerformance<T>(
    String operation,
    Future<T> Function() action,
  ) async {
    final stopwatch = Stopwatch()..start();
    try {
      final result = await action();
      return result;
    } finally {
      stopwatch.stop();
      logPerformance(operation, stopwatch.elapsed);
    }
  }
}

/// Memory management utilities
class MemoryUtils {
  static void clearImageCache() {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }

  static void optimizeMemoryUsage() {
    // Force garbage collection
    // Note: This is generally not recommended in production
    if (AppConfig.isDebug) {
      // Perform memory optimization tasks
    }
  }
}
