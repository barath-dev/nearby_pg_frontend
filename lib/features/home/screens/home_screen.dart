// lib/features/home/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:math' as math;

// Import providers and models
import '../providers/home_provider.dart';
import '../../../shared/models/app_models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  late AnimationController _animationController;
  late AnimationController _headerAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late TabController _tabController;

  bool _isHeaderExpanded = true;
  int _currentCategory = 0;

  final List<Map<String, dynamic>> _categories = [
    {'icon': Icons.home_filled, 'label': 'All'},
    {'icon': Icons.apartment, 'label': 'Single'},
    {'icon': Icons.group, 'label': 'Shared'},
    {'icon': Icons.hotel, 'label': 'Deluxe'},
    {'icon': Icons.location_city, 'label': 'Family'},
  ];

  @override
  void initState() {
    super.initState();

    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    // Initialize animation controllers
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _tabController = TabController(length: 3, vsync: this);

    // Initialize animations
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<double>(
      begin: 30.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeProvider>().initialize();
      _animationController.forward();
    });

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    _animationController.dispose();
    _headerAnimationController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Header collapse animation
    final offset = _scrollController.offset;
    final shouldExpand = offset < 50;

    if (shouldExpand != _isHeaderExpanded) {
      setState(() {
        _isHeaderExpanded = shouldExpand;
      });

      if (shouldExpand) {
        _headerAnimationController.reverse();
      } else {
        _headerAnimationController.forward();
      }
    }

    // Load more PGs
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      final provider = context.read<HomeProvider>();
      if (!provider.isLoadingMore) {
        provider.loadMorePGs();
      }
    }
  }

  void _navigateToPGDetail(String pgId) {
    Navigator.pushNamed(context, AppConstants.pgDetailRoute, arguments: pgId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFC),
      body: Consumer<HomeProvider>(
        builder: (context, provider, child) {
          return RefreshIndicator(
            onRefresh: () => provider.refreshData(),
            color: AppTheme.emeraldGreen,
            backgroundColor: Colors.white,
            displacement: 80,
            child: provider.isLoading
                ? _buildLoadingState()
                : provider.hasError
                    ? _buildErrorState(provider)
                    : _buildContent(provider),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return CustomScrollView(
      slivers: [
        // Enhanced shimmer app bar
        const SliverAppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          pinned: true,
          expandedHeight: 0,
          toolbarHeight: 0,
        ),

        // Enhanced content shimmer
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 60),

              // App header shimmer
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildShimmerBox(150, 28, radius: 8),
                      const SizedBox(height: 8),
                      _buildShimmerBox(100, 16, radius: 4),
                    ],
                  ),
                  const Spacer(),
                  _buildShimmerCircle(48),
                ],
              ),

              const SizedBox(height: 32),

              // Search box shimmer
              _buildShimmerBox(double.infinity, 60, radius: 16),

              const SizedBox(height: 32),

              // Category shimmer
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  itemBuilder: (context, index) => Container(
                    width: 70,
                    margin: const EdgeInsets.only(right: 16),
                    child: Column(
                      children: [
                        _buildShimmerCircle(48),
                        const SizedBox(height: 8),
                        _buildShimmerBox(60, 12, radius: 4),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Premium banner shimmer
              _buildShimmerBox(double.infinity, 180, radius: 24),
              const SizedBox(height: 32),

              // Section header
              Row(
                children: [
                  _buildShimmerBox(120, 24, radius: 6),
                  const Spacer(),
                  _buildShimmerBox(60, 20, radius: 4),
                ],
              ),
              const SizedBox(height: 20),

              // Featured cards shimmer
              SizedBox(
                height: 300,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 3,
                  itemBuilder: (context, index) => Container(
                    width: 240,
                    margin: const EdgeInsets.only(right: 16),
                    child: _buildShimmerBox(240, 300, radius: 24),
                  ),
                ),
              ),

              const SizedBox(height: 32),
              _buildShimmerBox(120, 24, radius: 6),
              const SizedBox(height: 20),

              // List cards shimmer
              ...List.generate(
                  3,
                  (index) => Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child:
                            _buildShimmerBox(double.infinity, 140, radius: 20),
                      )),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerBox(double width, double height, {double radius = 8}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: const Alignment(-1.0, 0.0),
          end: const Alignment(1.0, 0.0),
          colors: [
            Colors.grey[200]!,
            Colors.grey[100]!,
            Colors.grey[200]!,
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerCircle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: const Alignment(-1.0, 0.0),
          end: const Alignment(1.0, 0.0),
          colors: [
            Colors.grey[200]!,
            Colors.grey[100]!,
            Colors.grey[200]!,
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(HomeProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.red[50],
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                Icons.wifi_off_rounded,
                size: 50,
                color: Colors.red[400],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Connection Lost',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[800],
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Please check your internet connection\nand try again',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            _buildPrimaryButton(
              onPressed: () => provider.initialize(),
              label: 'Try Again',
              icon: Icons.refresh,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(HomeProvider provider) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Transparent AppBar for status bar spacing
                const SliverAppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  toolbarHeight: 0,
                  pinned: true,
                ),

                // Main content
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 20),

                      // Header
                      _buildModernHeader(provider),

                      const SizedBox(height: 32),

                      // Search Bar
                      _buildModernSearchBar(provider),

                      const SizedBox(height: 32),

                      // Categories
                      _buildCategories(),

                      const SizedBox(height: 32),

                      // Premium banners
                      if (provider.banners.isNotEmpty) ...[
                        _buildModernBanners(provider),
                        const SizedBox(height: 32),
                      ],

                      // Featured PGs with enhanced design
                      if (provider.featuredPGs.isNotEmpty) ...[
                        _buildModernSectionHeader(
                          'Featured Properties',
                          'Handpicked for you',
                          onViewAll: () {
                            // Navigate to view all featured PGs
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildModernFeaturedPGs(provider),
                        const SizedBox(height: 32),
                      ],

                      // Tab control for different PG types
                      _buildTabControl(),

                      const SizedBox(height: 20),

                      // Nearby PGs header
                      _buildModernSectionHeader(
                        'Nearby Accommodations',
                        'Available in your area',
                        onViewAll: () {
                          // Navigate to view all nearby PGs
                        },
                      ),
                      const SizedBox(height: 20),
                    ]),
                  ),
                ),

                // Enhanced nearby PGs list
                _buildNearbyPGsList(provider),

                // Bottom spacing
                const SliverToBoxAdapter(
                  child: SizedBox(height: 40),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModernHeader(HomeProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Find Your Perfect Stay',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1E293B),
                      letterSpacing: -0.5,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                provider.currentLocationName.isNotEmpty
                    ? 'in ${provider.currentLocationName}'
                    : 'Discover amazing places around you',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            // Navigate to profile or notifications
          },
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: Colors.grey[100]!,
                width: 1,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(
                  Icons.notifications_outlined,
                  color: Color(0xFF1E293B),
                  size: 24,
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.red[400],
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernSearchBar(HomeProvider provider) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppConstants.searchRoute);
      },
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 20),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.emeraldGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.search,
                color: AppTheme.emeraldGreen,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Search for locations, PGs...',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.tune,
                color: Colors.grey[600],
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final isSelected = _currentCategory == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                _currentCategory = index;
              });
            },
            child: Container(
              width: 70,
              margin: EdgeInsets.only(
                right: index == _categories.length - 1 ? 0 : 24,
              ),
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.emeraldGreen : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected
                              ? AppTheme.emeraldGreen.withOpacity(0.3)
                              : Colors.black.withOpacity(0.04),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      _categories[index]['icon'],
                      color:
                          isSelected ? Colors.white : const Color(0xFF64748B),
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _categories[index]['label'],
                    style: TextStyle(
                      color: isSelected
                          ? const Color(0xFF1E293B)
                          : const Color(0xFF64748B),
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildModernBanners(HomeProvider provider) {
    return SizedBox(
      height: 180,
      child: Swiper(
        itemBuilder: (context, index) =>
            _buildModernBannerItem(provider.banners[index]),
        itemCount: provider.banners.length,
        viewportFraction: 0.85,
        scale: 0.9,
        autoplay: true,
        autoplayDelay: 5000,
        pagination: SwiperPagination(
          builder: DotSwiperPaginationBuilder(
            color: Colors.white.withOpacity(0.5),
            activeColor: Colors.white,
            size: 6.0,
            activeSize: 8.0,
            space: 4.0,
          ),
          alignment: Alignment.bottomRight,
          margin: const EdgeInsets.only(bottom: 16, right: 20),
        ),
      ),
    );
  }

  Widget _buildModernBannerItem(PromotionalBanner banner) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Background image
            CachedNetworkImage(
              imageUrl: banner.imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              placeholder: (context, url) => Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.grey[200]!,
                      Colors.grey[300]!,
                    ],
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.emeraldGreen.withOpacity(0.8),
                      AppTheme.emeraldGreen,
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.image_outlined,
                    color: Colors.white.withOpacity(0.7),
                    size: 40,
                  ),
                ),
              ),
            ),

            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.0),
                    Colors.black.withOpacity(0.4),
                    Colors.black.withOpacity(0.7),
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
            ),

            // Content
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (banner.description.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          banner.description.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    Text(
                      banner.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Action button
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernSectionHeader(
    String title,
    String subtitle, {
    VoidCallback? onViewAll,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        if (onViewAll != null)
          GestureDetector(
            onTap: onViewAll,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View All',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: Colors.grey[700],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTabControl() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        labelColor: AppTheme.emeraldGreen,
        unselectedLabelColor: Colors.grey[600],
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        tabs: const [
          Tab(text: 'Recommended'),
          Tab(text: 'Newest'),
          Tab(text: 'Price'),
        ],
      ),
    );
  }

  Widget _buildModernFeaturedPGs(HomeProvider provider) {
    return SizedBox(
      height: 320,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: provider.featuredPGs.length,
        itemBuilder: (context, index) {
          final pg = provider.featuredPGs[index];
          return Container(
            width: 250,
            margin: EdgeInsets.only(
              right: index == provider.featuredPGs.length - 1 ? 0 : 20,
            ),
            child: _buildModernPGCard(
              pg: pg,
              onTap: () => _navigateToPGDetail(pg.id),
              isWishlisted: provider.isWishlisted(pg.id),
              onWishlistTap: () => provider.toggleWishlist(pg.id),
              isFeatured: true,
            ),
          );
        },
      ),
    );
  }

  Widget _buildNearbyPGsList(HomeProvider provider) {
    if (provider.nearbyPGs.isEmpty) {
      return SliverToBoxAdapter(
        child: _buildModernEmptyState(),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index < provider.nearbyPGs.length) {
              final pg = provider.nearbyPGs[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: _buildModernPGCard(
                  pg: pg,
                  onTap: () => _navigateToPGDetail(pg.id),
                  isWishlisted: provider.isWishlisted(pg.id),
                  onWishlistTap: () => provider.toggleWishlist(pg.id),
                  isHorizontal: true,
                  showDistance: true,
                ),
              );
            } else if (provider.isLoadingMore) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Center(
                  child: Container(
                    width: 50,
                    height: 50,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.emeraldGreen.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.emeraldGreen,
                      ),
                      strokeWidth: 3,
                    ),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
          childCount:
              provider.nearbyPGs.length + (provider.isLoadingMore ? 1 : 0),
        ),
      ),
    );
  }

  Widget _buildModernPGCard({
    required PGProperty pg,
    required VoidCallback onTap,
    required bool isWishlisted,
    required VoidCallback onWishlistTap,
    bool isFeatured = false,
    bool isHorizontal = false,
    bool showDistance = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: isHorizontal ? 130 : null,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: isHorizontal
              ? _buildHorizontalPGCard(
                  pg: pg,
                  isWishlisted: isWishlisted,
                  onWishlistTap: onWishlistTap,
                  showDistance: showDistance,
                )
              : _buildVerticalPGCard(
                  pg: pg,
                  isWishlisted: isWishlisted,
                  onWishlistTap: onWishlistTap,
                  isFeatured: isFeatured,
                ),
        ),
      ),
    );
  }

  Widget _buildVerticalPGCard({
    required PGProperty pg,
    required bool isWishlisted,
    required VoidCallback onWishlistTap,
    bool isFeatured = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image section
        Stack(
          children: [
            // PG Image
            Container(
              height: 170,
              width: double.infinity,
              color: Colors.grey[200],
              child: CachedNetworkImage(
                imageUrl: pg.images.isNotEmpty
                    ? pg.images.first
                    : 'https://via.placeholder.com/300',
                fit: BoxFit.cover,
                placeholder: (context, url) => Center(
                  child: SizedBox(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.grey[400]!,
                      ),
                      strokeWidth: 2,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Icon(
                  Icons.home_outlined,
                  size: 60,
                  color: Colors.grey[400],
                ),
              ),
            ),

            // Top actions
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Rating badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 16,
                          color: Colors.amber[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          pg.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Color(0xFF1E293B),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Wishlist button
                  GestureDetector(
                    onTap: onWishlistTap,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isWishlisted
                            ? Icons.favorite_rounded
                            : Icons.favorite_outline_rounded,
                        color:
                            isWishlisted ? Colors.red[400] : Colors.grey[700],
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom tags
            if (isFeatured)
              Positioned(
                bottom: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.emeraldGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.verified,
                        size: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'FEATURED',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),

        // Content section
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // PG Name
              Text(
                pg.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 8),

              // Location
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 14,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      pg.area,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Amenities row
              Row(
                children: [
                  ...List.generate(
                    math.min(3, pg.amenities.length),
                    (index) => Container(
                      margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppTheme.emeraldGreen.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getAmenityIcon(pg.amenities[index]),
                        size: 16,
                        color: AppTheme.emeraldGreen,
                      ),
                    ),
                  ),
                  if (pg.amenities.length > 3) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '+${pg.amenities.length - 3}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  Text(
                    '₹${pg.price}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.emeraldGreen,
                    ),
                  ),
                  Text(
                    '/mo',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalPGCard({
    required PGProperty pg,
    required bool isWishlisted,
    required VoidCallback onWishlistTap,
    bool showDistance = false,
  }) {
    return Row(
      children: [
        // Image container
        Container(
          width: 130,
          height: double.infinity,
          color: Colors.grey[200],
          child: Stack(
            fit: StackFit.expand,
            children: [
              // PG Image
              CachedNetworkImage(
                imageUrl: pg.images.isNotEmpty
                    ? pg.images.first
                    : 'https://via.placeholder.com/300',
                fit: BoxFit.cover,
                placeholder: (context, url) => Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.grey[400]!,
                      ),
                      strokeWidth: 2,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Icon(
                  Icons.home_outlined,
                  size: 40,
                  color: Colors.grey[400],
                ),
              ),

              // Rating badge
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star_rounded,
                        size: 12,
                        color: Colors.amber[600],
                      ),
                      const SizedBox(width: 2),
                      Text(
                        pg.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Color(0xFF1E293B),
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Content container
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row with title and wishlist
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        pg.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: onWishlistTap,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          isWishlisted
                              ? Icons.favorite_rounded
                              : Icons.favorite_outline_rounded,
                          color:
                              isWishlisted ? Colors.red[400] : Colors.grey[600],
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Location
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 14,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        pg.area,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Price and amenities
                Row(
                  children: [
                    Text(
                      '₹${pg.price}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.emeraldGreen,
                      ),
                    ),
                    Text(
                      '/mo',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[600],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${pg.availableRooms} Rooms',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  IconData _getAmenityIcon(String amenity) {
    final amenityIcons = {
      'WIFI': Icons.wifi,
      'AC': Icons.ac_unit,
      'MEALS': Icons.restaurant,
      'LAUNDRY': Icons.local_laundry_service,
      'PARKING': Icons.local_parking,
      'GYM': Icons.fitness_center,
      'SECURITY': Icons.security,
      'HOUSEKEEPING': Icons.cleaning_services,
      'HOT_WATER': Icons.water_drop,
      'POWER_BACKUP': Icons.power,
      'CCTV': Icons.videocam,
      'STUDY_ROOM': Icons.book,
      'RECREATION_ROOM': Icons.sports_esports,
    };

    return amenityIcons[amenity] ?? Icons.check_circle_outline;
  }

  Widget _buildModernEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 50,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'No PGs Found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                ),
          ),
          const SizedBox(height: 12),
          Text(
            'Try adjusting your location or\nsearch criteria to find more options',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                  height: 1.5,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _buildPrimaryButton(
            onPressed: () {
              Navigator.pushNamed(context, AppConstants.searchRoute);
            },
            label: 'Search Again',
            icon: Icons.search,
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton({
    required VoidCallback onPressed,
    required String label,
    IconData? icon,
    bool isOutlined = false,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isOutlined ? Colors.white : AppTheme.emeraldGreen,
        foregroundColor: isOutlined ? AppTheme.emeraldGreen : Colors.white,
        elevation: isOutlined ? 0 : 8,
        shadowColor: isOutlined
            ? Colors.transparent
            : AppTheme.emeraldGreen.withOpacity(0.3),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: isOutlined
              ? const BorderSide(color: AppTheme.emeraldGreen)
              : BorderSide.none,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
