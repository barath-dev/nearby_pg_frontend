import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:water_drop_nav_bar/water_drop_nav_bar.dart';
import 'package:nearby_pg/features/auth/screens/login_screen.dart';
import 'package:nearby_pg/features/auth/screens/signup_screen.dart';
import 'package:nearby_pg/features/offers/screens/offers_screen.dart';

// Import shared widgets
import '../../shared/widgets/splash_screen.dart';

// Import your screens
import '../../features/home/screens/home_screen.dart';
import '../../features/search/screens/search_screen.dart';
import '../../features/profile/screens/profile_screen.dart';

// Import constants and theme
import '../constants/app_constants.dart';
import '../theme/app_theme.dart';

/// Service for handling navigation and routing in the app
class NavigationService {
  // App scaffolds
  final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');
  final GlobalKey<NavigatorState> _shellNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'shell');

  // Current route path
  String _currentPath = '/';

  // Bottom navigation state
  int _currentIndex = 0;

  /// Get the current path
  String get currentPath => _currentPath;

  /// Get the current bottom navigation index
  int get currentIndex => _currentIndex;

  /// Create and configure the router
  late final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    debugLogDiagnostics: true,

    // Define routes
    routes: [
      // Splash Screen Route
      GoRoute(
        path: '/splash',
        name: 'splash',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const SplashScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),

      // Shell route for bottom navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          // Extract the current index from the location
          _updateBottomNavIndex(state.uri.toString());

          return MainNavigationWrapper(
            currentIndex: _currentIndex,
            child: child,
            onTabTapped: (index) => _onBottomNavTap(index, context),
          );
        },
        routes: [
          // Home tab
          GoRoute(
            path: '/',
            name: AppConstants.homeRoute,
            pageBuilder: (context, state) => CustomTransitionPage<void>(
              key: state.pageKey,
              child: const HomeScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),

          // Search tab
          GoRoute(
            path: '/search',
            name: AppConstants.searchRoute,
            pageBuilder: (context, state) => CustomTransitionPage<void>(
              key: state.pageKey,
              child: const SearchScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),

          // Offers tab
          GoRoute(
            path: '/offers',
            name: AppConstants.offersRoute,
            pageBuilder: (context, state) => CustomTransitionPage<void>(
              key: state.pageKey,
              child: const OffersScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),

          // Profile tab
          GoRoute(
            path: '/profile',
            name: AppConstants.profileRoute,
            pageBuilder: (context, state) => CustomTransitionPage<void>(
              key: state.pageKey,
              child: const ProfileScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
        ],
      ),

      // Routes outside the bottom navigation
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/pg/:id',
        name: AppConstants.pgDetailRoute,
        pageBuilder: (context, state) {
          final pgId = state.pathParameters['id']!;
          return CustomTransitionPage<void>(
            key: state.pageKey,
            child: PGDetailScreen(pgId: pgId),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              );
            },
          );
        },
      ),

      // Booking route
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/booking/:pgId',
        name: 'booking',
        pageBuilder: (context, state) {
          final pgId = state.pathParameters['pgId']!;
          return CustomTransitionPage<void>(
            key: state.pageKey,
            child: BookingScreen(pgId: pgId),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              );
            },
          );
        },
      ),

      // Settings route
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/settings',
        name: 'settings',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const SettingsScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            );
          },
        ),
      ),

      // Wishlist route
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/wishlist',
        name: 'wishlist',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const WishlistScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            );
          },
        ),
      ),

      // Map view route
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/map',
        name: 'map',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const MapViewScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            );
          },
        ),
      ),

      // Filter route
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/filter',
        name: 'filter',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const FilterScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            );
          },
        ),
      ),

      // Auth routes
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/login',
        name: AppConstants.loginRoute,
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            );
          },
        ),
      ),

      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/signup',
        name: AppConstants.signupRoute,
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const SignupScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            );
          },
        ),
      ),

      // OTP route
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/otp',
        name: AppConstants.otpRoute,
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return CustomTransitionPage<void>(
            key: state.pageKey,
            child: OTPScreen(
              phoneNumber: extra?['phoneNumber'] ?? '',
              isSignup: extra?['isSignup'] ?? false,
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              );
            },
          );
        },
      ),
    ],

    // Route change listener
    observers: [
      GoRouterObserver(
        onChanged: (state) {
          _currentPath = state?.uri.toString() ?? '/';
        },
      ),
    ],

    // Error page
    errorPageBuilder: (context, state) {
      return MaterialPage(
        key: state.pageKey,
        child: Scaffold(
          body: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/error.png', // Ensure you have this asset
                    width: 150,
                    height: 150,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.error_outline,
                      size: 100,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '404',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: AppTheme.emeraldGreen,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Page not found',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'The page you are looking for doesn\'t exist or has been moved.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () => context.go('/'),
                    icon: const Icon(Icons.home),
                    label: const Text('Go Home'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.emeraldGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );

  /// Handle bottom navigation tab changes
  void _onBottomNavTap(int index, BuildContext context) {
    if (_currentIndex == index) return;

    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/search');
        break;
      case 2:
        context.go('/offers');
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }

  /// Update bottom navigation index based on current route
  void _updateBottomNavIndex(String location) {
    if (location == '/' || location.startsWith('/?')) {
      _currentIndex = 0;
    } else if (location.startsWith('/search')) {
      _currentIndex = 1;
    } else if (location.startsWith('/offers')) {
      _currentIndex = 2;
    } else if (location.startsWith('/profile')) {
      _currentIndex = 3;
    }
  }

  /// Navigate to a named route
  void navigateTo(BuildContext context, String routeName, {Object? arguments}) {
    context.goNamed(routeName, extra: arguments);
  }

  /// Navigate to a route with parameters
  void navigateToWithParams(
    BuildContext context,
    String routeName, {
    Map<String, String> pathParameters = const {},
    Map<String, dynamic> queryParameters = const {},
    Object? extra,
  }) {
    context.goNamed(
      routeName,
      pathParameters: pathParameters,
      queryParameters: queryParameters,
      extra: extra,
    );
  }

  /// Go back to previous page
  void goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  /// Navigate from splash to home
  static void navigateFromSplashToHome(BuildContext context) {
    context.go('/');
  }

  /// Navigate to login screen
  static void navigateToLogin(BuildContext context) {
    context.go('/login');
  }

  /// Navigate to home screen
  static void navigateToHome(BuildContext context) {
    context.go('/');
  }

  /// Navigate to PG detail screen
  static void navigateToPGDetail(BuildContext context, String pgId) {
    context.go('/pg/$pgId');
  }

  /// Navigate to booking screen
  static void navigateToBooking(BuildContext context, String pgId) {
    context.go('/booking/$pgId');
  }

  /// Navigate to settings screen
  static void navigateToSettings(BuildContext context) {
    context.go('/settings');
  }

  /// Navigate to wishlist screen
  static void navigateToWishlist(BuildContext context) {
    context.go('/wishlist');
  }

  /// Navigate to map view screen
  static void navigateToMap(BuildContext context) {
    context.go('/map');
  }

  /// Navigate to filter screen
  static void navigateToFilter(BuildContext context) {
    context.go('/filter');
  }

  /// Navigate to OTP screen
  static void navigateToOTP(
    BuildContext context,
    String phoneNumber, {
    bool isSignup = false,
  }) {
    context.goNamed(
      AppConstants.otpRoute,
      extra: {
        'phoneNumber': phoneNumber,
        'isSignup': isSignup,
      },
    );
  }

  /// Show loading dialog
  static void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const LoadingDialog(),
    );
  }

  /// Hide loading dialog
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  /// Show success dialog
  static void showSuccessDialog({
    required BuildContext context,
    required String title,
    required String message,
    VoidCallback? onOkPressed,
  }) {
    showDialog(
      context: context,
      builder: (context) => FeedbackDialog(
        title: title,
        message: message,
        icon: Icons.check_circle,
        iconColor: Colors.green,
        onOkPressed: onOkPressed ?? () => Navigator.of(context).pop(),
      ),
    );
  }

  /// Show error dialog
  static void showErrorDialog({
    required BuildContext context,
    required String title,
    required String message,
    VoidCallback? onOkPressed,
  }) {
    showDialog(
      context: context,
      builder: (context) => FeedbackDialog(
        title: title,
        message: message,
        icon: Icons.error_outline,
        iconColor: Colors.red,
        onOkPressed: onOkPressed ?? () => Navigator.of(context).pop(),
      ),
    );
  }

  /// Show confirmation dialog
  static Future<bool> showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              cancelText,
              style: TextStyle(
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isDestructive ? Colors.red : AppTheme.emeraldGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Show snackbar
  static void showSnackBar({
    required BuildContext context,
    required String message,
    bool isError = false,
    IconData? icon,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              icon ?? (isError ? Icons.error_outline : Icons.check_circle),
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade800 : AppTheme.emeraldGreen,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        action: SnackBarAction(
          label: 'DISMISS',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}

/// Updated Main Navigation Wrapper with WaterDropNavBar
class MainNavigationWrapper extends StatelessWidget {
  final Widget child;
  final int currentIndex;
  final ValueChanged<int> onTabTapped;

  const MainNavigationWrapper({
    super.key,
    required this.child,
    required this.currentIndex,
    required this.onTabTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content
          child,

          // Navigation bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildWaterDropNavBar(context),
          ),
        ],
      ),
      extendBody: true, // Important for water drop effect
    );
  }

  Widget _buildWaterDropNavBar(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withOpacity(0.8),
                Colors.white.withOpacity(0.9),
              ],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: WaterDropNavBar(
                backgroundColor: Colors.transparent,
                onItemSelected: onTabTapped,
                selectedIndex: currentIndex,
                waterDropColor: AppTheme.emeraldGreen,
                inactiveIconColor: Colors.grey[600],
                iconSize: 24,
                barItems: [
                  BarItem(
                    filledIcon: Icons.home_rounded,
                    outlinedIcon: Icons.home_outlined,
                  ),
                  BarItem(
                    filledIcon: Icons.search_rounded,
                    outlinedIcon: Icons.search_outlined,
                  ),
                  BarItem(
                    filledIcon: Icons.local_offer_rounded,
                    outlinedIcon: Icons.local_offer_outlined,
                  ),
                  BarItem(
                    filledIcon: Icons.person_rounded,
                    outlinedIcon: Icons.person_outline_rounded,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Observer for tracking route changes
class GoRouterObserver extends NavigatorObserver {
  final void Function(GoRouterState? state)? onChanged;

  GoRouterObserver({this.onChanged});

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (route.settings is GoRouteData) {
      onChanged?.call(null);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute?.settings is GoRouteData) {
      onChanged?.call(null);
    }
  }
}

/// Enhanced Loading dialog widget
class LoadingDialog extends StatelessWidget {
  const LoadingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.emeraldGreen.withOpacity(0.1),
                        AppTheme.emeraldGreen.withOpacity(0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(
                        color: AppTheme.emeraldGreen,
                        strokeWidth: 3,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Please wait...',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2E3A59),
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'We\'re processing your request',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Reusable feedback dialog (for success and error)
class FeedbackDialog extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onOkPressed;

  const FeedbackDialog({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    required this.iconColor,
    required this.onOkPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2E3A59),
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onOkPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.emeraldGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Extension methods for easier navigation
extension NavigationExtension on BuildContext {
  void navigateTo(String routeName, {Object? arguments}) {
    goNamed(routeName, extra: arguments);
  }

  void showSnackBar(String message, {bool isError = false}) {
    NavigationService.showSnackBar(
      context: this,
      message: message,
      isError: isError,
    );
  }

  void showLoading() {
    NavigationService.showLoadingDialog(this);
  }

  void hideLoading() {
    NavigationService.hideLoadingDialog(this);
  }

  void showSuccess(String title, String message, {VoidCallback? onOk}) {
    NavigationService.showSuccessDialog(
      context: this,
      title: title,
      message: message,
      onOkPressed: onOk,
    );
  }

  void showError(String title, String message, {VoidCallback? onOk}) {
    NavigationService.showErrorDialog(
      context: this,
      title: title,
      message: message,
      onOkPressed: onOk,
    );
  }

  Future<bool> showConfirmation(
    String title,
    String message, {
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
  }) {
    return NavigationService.showConfirmationDialog(
      context: this,
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
      isDestructive: isDestructive,
    );
  }
}

// Placeholder screens (keeping the same as before)
class PGDetailScreen extends StatelessWidget {
  final String pgId;

  const PGDetailScreen({super.key, required this.pgId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('PG Details'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2E7D32),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.home_work_rounded,
                size: 64, color: Color(0xFF2E7D32)),
            const SizedBox(height: 16),
            Text('PG Details for ID: $pgId'),
            const SizedBox(height: 8),
            const Text('Detailed view coming soon!'),
          ],
        ),
      ),
    );
  }
}

class BookingScreen extends StatelessWidget {
  final String pgId;

  const BookingScreen({super.key, required this.pgId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Book PG'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2E7D32),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.book_online_rounded,
                size: 64, color: Color(0xFF2E7D32)),
            const SizedBox(height: 16),
            Text('Booking for PG: $pgId'),
            const SizedBox(height: 8),
            const Text('Booking flow coming soon!'),
          ],
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2E7D32),
        elevation: 0,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.settings_rounded, size: 64, color: Color(0xFF2E7D32)),
            SizedBox(height: 16),
            Text('Settings screen coming soon!'),
          ],
        ),
      ),
    );
  }
}

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Wishlist'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2E7D32),
        elevation: 0,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_rounded, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text('Wishlist screen coming soon!'),
          ],
        ),
      ),
    );
  }
}

class MapViewScreen extends StatelessWidget {
  const MapViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Map View'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2E7D32),
        elevation: 0,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_rounded, size: 64, color: Color(0xFF2E7D32)),
            SizedBox(height: 16),
            Text('Map view coming soon!'),
          ],
        ),
      ),
    );
  }
}

class FilterScreen extends StatelessWidget {
  const FilterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Filters'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2E7D32),
        elevation: 0,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.filter_list_rounded, size: 64, color: Color(0xFF2E7D32)),
            SizedBox(height: 16),
            Text('Advanced filters coming soon!'),
          ],
        ),
      ),
    );
  }
}

class OTPScreen extends StatelessWidget {
  final String phoneNumber;
  final bool isSignup;

  const OTPScreen({
    super.key,
    required this.phoneNumber,
    required this.isSignup,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Verify OTP'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2E7D32),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.sms_rounded, size: 64, color: Color(0xFF2E7D32)),
            const SizedBox(height: 16),
            Text('OTP sent to +91 $phoneNumber'),
            const SizedBox(height: 8),
            const Text('OTP verification coming soon!'),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Skip for now'),
            ),
          ],
        ),
      ),
    );
  }
}
