import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter/services.dart';
import 'dart:async';

// Import providers and models
import '../providers/home_provider.dart';
import '../../../shared/models/app_models.dart';
import '../../../shared/widgets/pg_card.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/navigation_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  final PageController _carouselController = PageController();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebouncer;
  Timer? _bannerTimer;
  int _currentBannerIndex = 0;
  bool _isExpanded = false;

  // For animations
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Responsive values
  double get horizontalPadding => isSmallScreen ? 16.0 : 20.0;
  double get verticalSpacing => isSmallScreen ? 16.0 : 24.0;
  bool get isSmallScreen => MediaQuery.of(context).size.width < 360;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeHomeData();
    _setupScrollListener();
    _setupBannerTimer();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _animationController.forward();
  }

  void _initializeHomeData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeProvider>().initialize();
    });
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 300) {
        context.read<HomeProvider>().loadMorePGs();
      }
    });
  }

  void _setupBannerTimer() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      final provider = context.read<HomeProvider>();
      if (provider.banners.isEmpty) return;

      if (_carouselController.hasClients) {
        final nextPage = (_currentBannerIndex + 1) % provider.banners.length;
        _carouselController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _carouselController.dispose();
    _searchDebouncer?.cancel();
    _bannerTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _handleSearch(String query) {
    if (query.trim().isEmpty) return;

    _searchDebouncer?.cancel();
    _searchDebouncer = Timer(const Duration(milliseconds: 500), () {
      Navigator.pushNamed(
        context,
        AppConstants.searchRoute,
        arguments: {'query': query},
      );
    });
  }

  void _navigateToPGDetail(String pgId) {
    Navigator.pushNamed(context, AppConstants.pgDetailRoute, arguments: pgId);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            _buildSliverAppBar(),
            SliverPersistentHeader(
              delegate: _SliverSearchBarDelegate(
                child: _buildSearchBar(),
                minHeight: 80,
                maxHeight: 80,
              ),
              pinned: true,
            ),
          ];
        },
        body: RefreshIndicator(
          onRefresh: () => context.read<HomeProvider>().refresh(),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildQuickActions()),
              SliverToBoxAdapter(child: _buildBannerSection()),
              _buildFeaturedPGsSection(),
              _buildNearbyPGsSection(),
              _buildRecommendedPGsSection(),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 100 + MediaQuery.of(context).padding.bottom,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      pinned: true,
      expandedHeight: 80,
      toolbarHeight: 70,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Container(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Row(
            children: [
              Expanded(child: _buildAppLogo()),
              _buildLocationButton(),
            ],
          ),
        ),
        titlePadding: EdgeInsets.zero,
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                Colors.grey.withOpacity(0.2),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppLogo() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Hero(
            tag: 'app_logo',
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.emeraldGreen,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.emeraldGreen.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.home_work_rounded,
                color: Colors.white,
                size: isSmallScreen ? 16 : 18,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'NEARBY PG',
              style: TextStyle(
                color: AppTheme.emeraldGreen,
                fontWeight: FontWeight.w800,
                fontSize: isSmallScreen ? 18 : 20,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationButton() {
    return Consumer<HomeProvider>(
      builder: (context, provider, _) {
        final hasLocation = provider.currentLocation != null;
        final locationName =
            hasLocation ? provider.currentLocation! : 'Set Location';

        return FadeTransition(
          opacity: _fadeAnimation,
          child: GestureDetector(
            onTap: () {
              // Handle location selection
              _showLocationBottomSheet();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color:
                    hasLocation
                        ? AppTheme.emeraldGreen.withOpacity(0.1)
                        : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color:
                      hasLocation
                          ? AppTheme.emeraldGreen.withOpacity(0.3)
                          : Colors.grey[300]!,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color:
                        hasLocation ? AppTheme.emeraldGreen : Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.3,
                    ),
                    child: Text(
                      locationName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color:
                            hasLocation
                                ? AppTheme.emeraldGreen
                                : Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: 14,
                    color:
                        hasLocation ? AppTheme.emeraldGreen : Colors.grey[600],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 16,
      ),
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.gray50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.gray200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 12),
              const Icon(Icons.search, color: AppTheme.gray500, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search PGs, locations, amenities...',
                    hintStyle: TextStyle(
                      color: AppTheme.gray400,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 15),
                  ),
                  style: const TextStyle(
                    color: AppTheme.deepCharcoal,
                    fontSize: 14,
                  ),
                  onChanged: _handleSearch,
                  onTap: () {
                    // Navigate to search screen for better UX
                    Navigator.pushNamed(context, AppConstants.searchRoute);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Container(
                margin: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.emeraldGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.tune,
                    color: AppTheme.emeraldGreen,
                    size: 20,
                  ),
                  onPressed: () {
                    // Show filters
                    _showFilters();
                  },
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                  padding: EdgeInsets.zero,
                  splashRadius: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    final List<Map<String, dynamic>> actions = [
      {
        'icon': Icons.apartment,
        'label': 'PG Hostels',
        'color': Colors.blue,
        'onTap': () {
          // Navigate to PG hostels filter
          Navigator.pushNamed(
            context,
            AppConstants.searchRoute,
            arguments: {'filter': 'hostels'},
          );
        },
      },
      {
        'icon': Icons.location_city,
        'label': 'Apartments',
        'color': Colors.orange,
        'onTap': () {
          // Navigate to apartments filter
          Navigator.pushNamed(
            context,
            AppConstants.searchRoute,
            arguments: {'filter': 'apartments'},
          );
        },
      },
      {
        'icon': Icons.food_bank,
        'label': 'With Meals',
        'color': Colors.green,
        'onTap': () {
          // Navigate to with meals filter
          Navigator.pushNamed(
            context,
            AppConstants.searchRoute,
            arguments: {'filter': 'meals'},
          );
        },
      },
      {
        'icon': Icons.star,
        'label': 'Premium',
        'color': Colors.purple,
        'onTap': () {
          // Navigate to premium filter
          Navigator.pushNamed(
            context,
            AppConstants.searchRoute,
            arguments: {'filter': 'premium'},
          );
        },
      },
      {
        'icon': Icons.local_offer,
        'label': 'Offers',
        'color': Colors.red,
        'onTap': () {
          // Navigate to offers
          Navigator.pushNamed(context, AppConstants.offersRoute);
        },
      },
    ];

    return Container(
      height: 110,
      margin: EdgeInsets.symmetric(vertical: verticalSpacing),
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: SlideTransition(
        position: _slideAnimation,
        child: Consumer<HomeProvider>(
          builder: (context, provider, _) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children:
                    actions.map((action) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: InkWell(
                          onTap: action['onTap'] as VoidCallback,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: isSmallScreen ? 70 : 80,
                            padding: EdgeInsets.symmetric(
                              vertical: isSmallScreen ? 12 : 14,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: (action['color'] as Color)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    action['icon'] as IconData,
                                    color: action['color'] as Color,
                                    size: isSmallScreen ? 20 : 22,
                                  ),
                                ),
                                SizedBox(height: isSmallScreen ? 4 : 6),
                                Text(
                                  action['label'] as String,
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 10 : 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[700],
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBannerSection() {
    return Consumer<HomeProvider>(
      builder: (context, provider, _) {
        if (provider.banners.isEmpty) {
          return const SizedBox.shrink();
        }

        return SlideTransition(
          position: _slideAnimation,
          child: Container(
            margin: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalSpacing,
            ),
            height: isSmallScreen ? 150 : 180,
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _carouselController,
                    itemCount: provider.banners.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentBannerIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final banner = provider.banners[index];
                      return GestureDetector(
                        onTap: () {
                          // Handle banner click
                          if (banner.actionUrl.isNotEmpty) {
                            // Navigate or handle action
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            children: [
                              // Banner image
                              Positioned.fill(
                                child: Image.network(
                                  banner.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[300],
                                      child: const Center(
                                        child: Icon(
                                          Icons.image_not_supported,
                                          color: Colors.white,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),

                              // Gradient overlay for text visibility
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withOpacity(0.6),
                                      ],
                                      stops: const [0.6, 1.0],
                                    ),
                                  ),
                                ),
                              ),

                              // Banner text content
                              Positioned(
                                bottom: 16,
                                left: 16,
                                right: 16,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (banner.title.isNotEmpty)
                                      Text(
                                        banner.title,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          shadows: [
                                            Shadow(
                                              blurRadius: 2,
                                              color: Colors.black,
                                              offset: Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    if (banner.description.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        banner.description,
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize: 12,
                                          shadows: const [
                                            Shadow(
                                              blurRadius: 2,
                                              color: Colors.black,
                                              offset: Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                // Page indicator
                Center(
                  child: SmoothPageIndicator(
                    controller: _carouselController,
                    count: provider.banners.length,
                    effect: ExpandingDotsEffect(
                      activeDotColor: AppTheme.emeraldGreen,
                      dotColor: Colors.grey[300]!,
                      dotHeight: 8,
                      dotWidth: 8,
                      expansionFactor: 3,
                      spacing: 4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeaturedPGsSection() {
    return Consumer<HomeProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.featuredPGs.isEmpty) {
          return SliverToBoxAdapter(child: _buildLoadingPGCards());
        }

        if (provider.featuredPGs.isEmpty) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }

        return SliverToBoxAdapter(
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Featured PGs',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.deepCharcoal,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Navigate to featured PGs list
                          Navigator.pushNamed(
                            context,
                            AppConstants.searchRoute,
                            arguments: {'filter': 'featured'},
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.emeraldGreen,
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        ),
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 280,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: 8,
                    ),
                    itemCount: provider.featuredPGs.length,
                    itemBuilder: (context, index) {
                      final pg = provider.featuredPGs[index];
                      return Container(
                        width: 220,
                        margin: const EdgeInsets.only(right: 16),
                        child: PGCard(
                          pgProperty: pg,
                          onTap: () => _navigateToPGDetail(pg.id),
                          variant: PGCardVariant.compact,
                          isWishlisted: provider.isWishlisted(pg.id),
                          onWishlistTap: () => provider.toggleWishlist(pg.id),
                          showDistance: true,
                          distance: pg.distanceFromCenter,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNearbyPGsSection() {
    return Consumer<HomeProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.nearbyPGs.isEmpty) {
          return SliverToBoxAdapter(child: _buildLoadingPGCards());
        }

        if (provider.nearbyPGs.isEmpty && !provider.isLoading) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }

        return SliverToBoxAdapter(
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Nearby PGs',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.deepCharcoal,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Navigate to nearby PGs list
                          Navigator.pushNamed(
                            context,
                            AppConstants.searchRoute,
                            arguments: {'filter': 'nearby'},
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.emeraldGreen,
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        ),
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 280,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: 8,
                    ),
                    itemCount: provider.nearbyPGs.length,
                    itemBuilder: (context, index) {
                      final pg = provider.nearbyPGs[index];
                      return Container(
                        width: 220,
                        margin: const EdgeInsets.only(right: 16),
                        child: PGCard(
                          pgProperty: pg,
                          onTap: () => _navigateToPGDetail(pg.id),
                          variant: PGCardVariant.compact,
                          isWishlisted: provider.isWishlisted(pg.id),
                          onWishlistTap: () => provider.toggleWishlist(pg.id),
                          showDistance: true,
                          distance: pg.distanceFromCenter,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecommendedPGsSection() {
    return Consumer<HomeProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.pgList.isEmpty) {
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildLoadingPGCard(),
              childCount: 3,
            ),
          );
        }

        if (provider.pgList.isEmpty && !provider.isLoading) {
          return SliverToBoxAdapter(child: _buildEmptyState());
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index == 0) {
                return Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    verticalSpacing,
                    horizontalPadding,
                    8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recommended For You',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.deepCharcoal,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Navigate to recommended list
                          Navigator.pushNamed(
                            context,
                            AppConstants.searchRoute,
                            arguments: {'filter': 'recommended'},
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.emeraldGreen,
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        ),
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                );
              }

              final pgIndex = index - 1;
              if (pgIndex < provider.pgList.length) {
                final pg = provider.pgList[pgIndex];
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(0, 0.05 * (pgIndex % 3 + 1)),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: Interval(
                        0.2 + (pgIndex % 3) * 0.1,
                        1.0,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: 8,
                    ),
                    child: PGCard(
                      pgProperty: pg,
                      onTap: () => _navigateToPGDetail(pg.id),
                      variant: PGCardVariant.standard,
                      isWishlisted: provider.isWishlisted(pg.id),
                      onWishlistTap: () => provider.toggleWishlist(pg.id),
                      showDistance: true,
                      distance: pg.distanceFromCenter,
                    ),
                  ),
                );
              }

              // Show loading indicator at the end
              if (pgIndex == provider.pgList.length && provider.isLoadingMore) {
                return Padding(
                  padding: EdgeInsets.all(verticalSpacing),
                  child: const Center(child: CircularProgressIndicator()),
                );
              }

              return null;
            },
            childCount:
                provider.pgList.length + 1 + (provider.isLoadingMore ? 1 : 0),
          ),
        );
      },
    );
  }

  Widget _buildLoadingPGCards() {
    return Container(
      height: 280,
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalSpacing,
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            width: 220,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 16,
                        width: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 12,
                        width: 180,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            height: 14,
                            width: 80,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          Container(
                            height: 20,
                            width: 70,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingPGCard() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    width: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 12,
                    width: 250,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: EdgeInsets.all(verticalSpacing * 2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No PGs Found',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.deepCharcoal,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters or search criteria',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.gray600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              context.read<HomeProvider>().resetFilters();
              context.read<HomeProvider>().refresh();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Reset Filters'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.emeraldGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Consumer<HomeProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading || !provider.hasLocationPermission) {
          return const SizedBox.shrink();
        }

        return FloatingActionButton(
          onPressed: () {
            // Open map view
            Navigator.pushNamed(context, AppConstants.mapViewRoute);
          },
          backgroundColor: AppTheme.emeraldGreen,
          child: const Icon(Icons.map, color: Colors.white),
        );
      },
    );
  }

  void _showLocationBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  'Select Location',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.deepCharcoal,
                  ),
                ),
                const SizedBox(height: 24),
                _buildActionButton(
                  icon: Icons.my_location,
                  title: 'Use Current Location',
                  onTap: () {
                    // Request location permission and get current location
                    Navigator.pop(context);
                    context.read<HomeProvider>().getCurrentLocation();
                  },
                ),
                const SizedBox(height: 16),
                _buildActionButton(
                  icon: Icons.search,
                  title: 'Search for Area',
                  onTap: () {
                    // Navigate to location search
                    Navigator.pop(context);
                    // Show search dialog
                  },
                ),
                const SizedBox(height: 16),
                _buildActionButton(
                  icon: Icons.place,
                  title: 'Select on Map',
                  onTap: () {
                    // Navigate to map selection
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppConstants.mapViewRoute);
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    double buttonRadius = 12,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(buttonRadius),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.gray300),
          borderRadius: BorderRadius.circular(buttonRadius),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.emeraldGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppTheme.emeraldGreen, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.deepCharcoal,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildFiltersSheet(),
    );
  }

  Widget _buildFiltersSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Filters',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.deepCharcoal,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Reset',
                  style: TextStyle(
                    color: AppTheme.emeraldGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Coming soon placeholder - will be replaced with actual filters in production
          const Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.construction_rounded,
                    size: 48,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Advanced Filters',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Coming Soon!',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SliverSearchBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double minHeight;
  final double maxHeight;

  _SliverSearchBarDelegate({
    required this.child,
    this.minHeight = 60,
    this.maxHeight = 60,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(child: child);
  }

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  bool shouldRebuild(_SliverSearchBarDelegate oldDelegate) {
    return oldDelegate.minHeight != minHeight ||
        oldDelegate.maxHeight != maxHeight ||
        oldDelegate.child != child;
  }
}
