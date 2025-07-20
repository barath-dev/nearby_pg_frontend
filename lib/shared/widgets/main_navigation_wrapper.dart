import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:nearby_pg/core/theme/app_theme.dart';
import 'package:provider/provider.dart';

// Import screens
import '../../features/home/screens/home_screen.dart';
import '../../features/search/screens/search_screen.dart';
import '../../features/profile/screens/profile_screen.dart';

// Import providers
import '../../shared/providers/app_provider.dart';

class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isExiting = false;
  DateTime? _lastBackPressTime;

  // Bottom navigation items configuration
  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.home_rounded,
      activeIcon: Icons.home_rounded,
      label: 'Home',
      screen: const HomeScreen(),
    ),
    NavigationItem(
      icon: Icons.search_rounded,
      activeIcon: Icons.search_rounded,
      label: 'Search',
      screen: const SearchScreen(),
    ),
    NavigationItem(
      icon: Icons.local_offer_rounded,
      activeIcon: Icons.local_offer_rounded,
      label: 'Offers',
      screen: const OffersScreen(),
    ),
    NavigationItem(
      icon: Icons.person_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
      screen: const ProfileScreen(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });

      // Animate to the selected page
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

      // Provide haptic feedback
      HapticFeedback.lightImpact();
    }
  }

  void _onPageChanged(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  // Handle back button press
  Future<bool> _onWillPop() async {
    if (_currentIndex != 0) {
      // If not on home tab, go to home tab
      setState(() {
        _currentIndex = 0;
      });
      _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      return false;
    }

    // Double press to exit
    final now = DateTime.now();
    if (_lastBackPressTime == null ||
        now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
      _lastBackPressTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Press back again to exit'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return false;
    }

    // Animate exit
    setState(() {
      _isExiting = true;
    });
    await _animationController.reverse();

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            physics:
                const NeverScrollableScrollPhysics(), // Disable swipe navigation
            children: _navigationItems.map((item) => item.screen).toList(),
          ),
        ),
        bottomNavigationBar: _buildBottomNavigationBar(),
        extendBody:
            true, // Allow content to flow under the bottom navigation bar
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_navigationItems.length, (index) {
              final item = _navigationItems[index];
              final isSelected = index == _currentIndex;

              return _buildNavItem(item, index, isSelected);
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(NavigationItem item, int index, bool isSelected) {
    // Use different color for selected item based on theme
    final selectedColor = AppTheme.emeraldGreen;
    final unselectedColor = Colors.grey[600]!;

    // Custom animated tab item
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onTabTapped(index),
        borderRadius: BorderRadius.circular(16),
        splashColor: selectedColor.withOpacity(0.1),
        highlightColor: selectedColor.withOpacity(0.05),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color:
                isSelected
                    ? selectedColor.withOpacity(0.1)
                    : Colors.transparent,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon with badge for notifications (example for home tab)
              index == 0 && Provider.of<AppProvider>(context).hasNotifications
                  ? Stack(
                    children: [
                      Icon(
                        isSelected ? item.activeIcon : item.icon,
                        color: isSelected ? selectedColor : unselectedColor,
                        size: 24,
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 8,
                            minHeight: 8,
                          ),
                        ),
                      ),
                    ],
                  )
                  : Icon(
                    isSelected ? item.activeIcon : item.icon,
                    color: isSelected ? selectedColor : unselectedColor,
                    size: 24,
                  ),

              // Label with animation
              if (isSelected) ...[
                const SizedBox(width: 8),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? selectedColor : unselectedColor,
                  ),
                  child: Text(item.label),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Navigation item model
class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Widget screen;

  NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.screen,
  });
}

// Placeholder Offers Screen
class OffersScreen extends StatelessWidget {
  const OffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: AppBar(
        title: Text(
          'Offers & Deals',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppTheme.deepCharcoal,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.grey[200]),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.emeraldGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  Icons.local_offer_rounded,
                  size: 48,
                  color: AppTheme.emeraldGreen,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Exciting Offers Coming Soon!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.deepCharcoal,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'We\'re working on exciting deals and discounts for you. Stay tuned!',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppTheme.gray600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Placeholder offer card
              _buildComingSoonOfferCard(
                context,
                title: 'First Booking Discount',
                description: 'Get 10% off on your first booking',
                color: Colors.orange,
                icon: Icons.card_giftcard,
              ),
              const SizedBox(height: 16),
              _buildComingSoonOfferCard(
                context,
                title: 'Refer & Earn',
                description: 'Refer friends and earn rewards',
                color: Colors.purple,
                icon: Icons.people,
              ),
              const SizedBox(height: 16),
              _buildComingSoonOfferCard(
                context,
                title: 'Premium Membership',
                description: 'Exclusive benefits for premium members',
                color: Colors.blue,
                icon: Icons.star,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComingSoonOfferCard(
    BuildContext context, {
    required String title,
    required String description,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(color: AppTheme.gray600, fontSize: 14),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Coming Soon',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
