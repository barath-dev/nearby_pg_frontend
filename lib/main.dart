// lib/main.dart
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

// Shared imports
import 'shared/providers/app_provider.dart';
import 'shared/widgets/splash_screen.dart';
import 'shared/widgets/main_navigation_wrapper.dart';

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

/// App initializer for services
class AppInitializer {
  static final CacheService _cacheService = CacheService();
  static final LocationService _locationService = LocationService();
  static final ApiService _apiService = ApiService();

  /// Initialize all app services
  static Future<void> initialize() async {
    try {
      // Initialize core services
      await _cacheService.initialize();
      await _locationService.initialize();

      debugPrint('✅ App services initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing app services: $e');
      // Log the error to a service
    }
  }

  /// Get services for use in the app
  static CacheService get cacheService => _cacheService;
  static LocationService get locationService => _locationService;
  static ApiService get apiService => _apiService;
}

/// Global exception handler
void handleGlobalError(Object error, StackTrace? stack) {
  debugPrint('❌ Global error caught: $error');
  if (stack != null) {
    debugPrint('Stack trace: $stack');
  }

  // TODO: Send to crash analytics in production
}

class NearbyPGApp extends StatelessWidget {
  const NearbyPGApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Core app provider
        ChangeNotifierProvider(create: (_) => AppProvider()),

        // Feature providers
        ChangeNotifierProvider(create: (_) => HomeProvider()),
      ],
      child: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,

            // Theme configuration
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.light, // Fixed to light for now
            // Navigation
            navigatorKey: NavigationService.navigatorKey,
            initialRoute: AppConstants.splashRoute,
            routes: {
              AppConstants.splashRoute: (context) => const SplashScreen(),
              AppConstants.homeRoute:
                  (context) => const MainNavigationWrapper(),
              // Add more routes as needed
            },

            // Localization
            locale: const Locale('en', 'US'),
            supportedLocales: const [Locale('en', 'US')],

            // Performance optimizations
            builder: (context, child) {
              return MediaQuery(
                // Ensure text scaling doesn't break layouts
                data: MediaQuery.of(context).copyWith(
                  textScaleFactor: MediaQuery.of(
                    context,
                  ).textScaleFactor.clamp(0.8, 1.3),
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
