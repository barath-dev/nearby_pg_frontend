import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:nearby_pg/features/auth/screens/login_screen.dart';
import 'package:nearby_pg/features/auth/screens/signup_screen.dart';
import 'package:nearby_pg/features/offers/screens/offers_screen.dart';

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
        builder: (context, state) => const SplashScreen(),
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
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),

          // Search tab
          GoRoute(
            path: '/search',
            name: AppConstants.searchRoute,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SearchScreen(),
            ),
          ),

          // Offers tab
          GoRoute(
            path: '/offers',
            name: AppConstants.offersRoute,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: OffersScreen(),
            ),
          ),

          // Profile tab
          GoRoute(
            path: '/profile',
            name: AppConstants.profileRoute,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfileScreen(),
            ),
          ),
        ],
      ),

      // Routes outside the bottom navigation
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/pg/:id',
        name: AppConstants.pgDetailRoute,
        builder: (context, state) {
          final pgId = state.pathParameters['id']!;
          return PGDetailScreen(pgId: pgId);
        },
      ),

      // Booking route
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/booking/:pgId',
        name: 'booking',
        builder: (context, state) {
          final pgId = state.pathParameters['pgId']!;
          return BookingScreen(pgId: pgId);
        },
      ),

      // Settings route
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),

      // Wishlist route
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/wishlist',
        name: 'wishlist',
        builder: (context, state) => const WishlistScreen(),
      ),

      // Map view route
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/map',
        name: 'map',
        builder: (context, state) => const MapViewScreen(),
      ),

      // Filter route
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/filter',
        name: 'filter',
        builder: (context, state) => const FilterScreen(),
      ),

      // Auth routes
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/login',
        name: AppConstants.loginRoute,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: LoginScreen(),
        ),
      ),

      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/signup',
        name: AppConstants.signupRoute,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: SignupScreen(),
        ),
      ),

      // OTP route
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/otp',
        name: AppConstants.otpRoute,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return OTPScreen(
            phoneNumber: extra?['phoneNumber'] ?? '',
            isSignup: extra?['isSignup'] ?? false,
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
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  'Page not found',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'The requested page does not exist.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.go('/'),
                  child: const Text('Go Home'),
                ),
              ],
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
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: onOkPressed ?? () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
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
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: isDestructive
                ? TextButton.styleFrom(foregroundColor: Colors.red)
                : null,
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
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// Updated Splash Screen with GoRouter integration
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _textOpacityAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _configureSystemUI();
    _checkAuthAndNavigate();
  }

  void _configureSystemUI() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppTheme.emeraldGreen,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    _textOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 0.7, curve: Curves.easeIn),
      ),
    );

    _slideAnimation = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 0.7, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  void _checkAuthAndNavigate() async {
    // Wait for splash duration
    await Future.delayed(AppConstants.splashDuration);

    if (mounted) {
      // Navigate to home using GoRouter
      NavigationService.navigateFromSplashToHome(context);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.emeraldGreen, AppTheme.secondaryGreen],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated Logo
                    Transform.scale(
                      scale: _scaleAnimation.value,
                      child: FadeTransition(
                        opacity: _opacityAnimation,
                        child: Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 30,
                                offset: const Offset(0, 15),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // App Icon
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppTheme.emeraldGreen,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.home_work_rounded,
                                  color: Colors.white,
                                  size: 48,
                                ),
                              ),
                              const SizedBox(height: 20),

                              // App Name
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'NEARBY',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(
                                          color: AppTheme.emeraldGreen,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 1.2,
                                        ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.emeraldGreen,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'PG',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Tagline
                    FadeTransition(
                      opacity: _textOpacityAnimation,
                      child: Transform.translate(
                        offset: Offset(0, _slideAnimation.value),
                        child: Text(
                          'Find Your Perfect PG',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Subtitle
                    FadeTransition(
                      opacity: _textOpacityAnimation,
                      child: Transform.translate(
                        offset: Offset(0, _slideAnimation.value),
                        child: Text(
                          'Premium PG Discovery Platform',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(color: Colors.white.withOpacity(0.8)),
                        ),
                      ),
                    ),

                    const SizedBox(height: 60),

                    // Loading indicator
                    FadeTransition(
                      opacity: _textOpacityAnimation,
                      child: const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 3,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Updated Main Navigation Wrapper to work with GoRouter
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
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: onTabTapped,
            selectedItemColor: AppTheme.emeraldGreen,
            unselectedItemColor: AppTheme.gray600,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            backgroundColor: Colors.white,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search_outlined),
                activeIcon: Icon(Icons.search),
                label: 'Search',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.local_offer_outlined),
                activeIcon: Icon(Icons.local_offer),
                label: 'Offers',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
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
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32).withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Center(
                child: SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    color: Color(0xFF2E7D32),
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
            Text('Detailed view coming soon!'),
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
            Text('Booking flow coming soon!'),
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
            Text('OTP verification coming soon!'),
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
