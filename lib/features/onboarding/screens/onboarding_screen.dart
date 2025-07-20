import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nearby_pg/core/services/navigation_service.dart';
import 'package:nearby_pg/core/theme/app_theme.dart';
import 'package:nearby_pg/shared/providers/app_provider.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

/// Enhanced onboarding screen with modern UI and smooth animations
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLastPage = false;

  // Onboarding data with illustrations, titles, and descriptions
  final List<Map<String, dynamic>> _onboardingData = [
    {
      'title': 'Find Your Perfect PG',
      'description':
          'Discover thousands of PGs that match your preferences and budget',
      'image': 'assets/images/onboarding_1.png',
      'color': const Color(0xFF2E7D32), // AppTheme.emeraldGreen
    },
    {
      'title': 'Compare and Choose',
      'description':
          'Compare amenities, prices, and reviews to make the best decision',
      'image': 'assets/images/onboarding_2.png',
      'color': const Color(0xFF388E3C), // AppTheme.mediumGreen
    },
    {
      'title': 'Book Instantly',
      'description':
          'Book your accommodation with just a few taps and move in hassle-free',
      'image': 'assets/images/onboarding_3.png',
      'color': const Color(0xFF4CAF50), // AppTheme.lightGreen
    },
  ];

  @override
  void initState() {
    super.initState();

    // Configure status bar to match onboarding style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
      _isLastPage = page == _onboardingData.length - 1;
    });
  }

  void _completeOnboarding() {
    // Mark first-time flag as false
    context.read<AppProvider>().setFirstTime(false);

    // Navigate to login screen
    NavigationService.navigateToLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background and page content
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: _onboardingData.length,
            itemBuilder: (context, index) => _buildOnboardingPage(index),
          ),

          // Navigation controls
          _buildNavigationControls(),
        ],
      ),
    );
  }

  /// Build individual onboarding page
  Widget _buildOnboardingPage(int index) {
    final data = _onboardingData[index];
    final deviceHeight = MediaQuery.of(context).size.height;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [data['color'], data['color'].withOpacity(0.7)],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header with app logo
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.home_rounded,
                      color: AppTheme.emeraldGreen,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'NEARBY PG',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),

            // Illustration
            Expanded(
              flex: 5,
              child: FractionallySizedBox(
                widthFactor: 0.8,
                child: _buildPlaceholderImage(data),
              ),
            ),

            // Content
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      data['title'],
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      data['description'],
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            // Bottom spacing
            SizedBox(height: deviceHeight * 0.1),
          ],
        ),
      ),
    );
  }

  /// Build navigation controls (skip, indicators, next/get started button)
  Widget _buildNavigationControls() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Skip button (top-right)
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _completeOnboarding,
                child: Text(
                  'Skip',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const Spacer(),

            // Page indicator and next button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Page indicator
                SmoothPageIndicator(
                  controller: _pageController,
                  count: _onboardingData.length,
                  effect: WormEffect(
                    dotHeight: 10,
                    dotWidth: 10,
                    activeDotColor: Colors.white,
                    dotColor: Colors.white.withOpacity(0.5),
                  ),
                ),

                // Next/Get Started button
                ElevatedButton(
                  onPressed: () {
                    if (_isLastPage) {
                      _completeOnboarding();
                    } else {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.emeraldGreen,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _isLastPage ? 'Get Started' : 'Next',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build placeholder image for illustrations
  /// In a real app, replace with actual illustrations
  Widget _buildPlaceholderImage(Map<String, dynamic> data) {
    final iconData =
        data['title'].contains('Find')
            ? Icons.search
            : data['title'].contains('Compare')
            ? Icons.compare
            : Icons.bookmark;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(iconData, size: 100, color: Colors.white),
          const SizedBox(height: 24),
          Text(
            'Illustration\n${data['title']}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
