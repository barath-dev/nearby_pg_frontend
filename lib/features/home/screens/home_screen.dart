import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'dart:async';

// Import providers and models
import '../providers/home_provider.dart';
import '../../../shared/models/app_models.dart';
import '../../../shared/widgets/pg_card.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  final CarouselSliderController _carouselController =
      CarouselSliderController();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebouncer;
  Timer? _bannerTimer;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Responsive dimensions
  late double screenWidth;
  late double screenHeight;
  late bool isSmallScreen;
  late bool isTablet;

  // UI state
  bool _isRefreshing = false;
  int _currentBannerIndex = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupScrollListener();
    _initializeScreen();
    _startBannerAutoplay();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateScreenDimensions();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
    );

    // Start animations
    _fadeController.forward();
    _slideController.forward();
  }

  void _updateScreenDimensions() {
    final mediaQuery = MediaQuery.of(context);
    screenWidth = mediaQuery.size.width;
    screenHeight = mediaQuery.size.height;
    isSmallScreen = screenWidth < 375;
    isTablet = screenWidth > 600;
  }

  void _initializeScreen() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _performInitialization();
      }
    });
  }

  Future<void> _performInitialization() async {
    try {
      await context.read<HomeProvider>().initialize();
    } catch (error) {
      debugPrint('Home initialization error: $error');
      if (mounted) {
        _showErrorSnackBar('Failed to load data. Please try again.');
      }
    }
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (!mounted) return;

      // Load more when approaching the end
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        context.read<HomeProvider>().loadMorePGs().catchError((error) {
          debugPrint('Load more error: $error');
        });
      }

      // Hide/show FAB based on scroll position
      setState(() {
        // Update any scroll-dependent UI state here
      });
    });
  }

  void _startBannerAutoplay() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        final provider = context.read<HomeProvider>();
        if (provider.banners.isNotEmpty) {
          final nextIndex = (_currentBannerIndex + 1) % provider.banners.length;
          _carouselController.animateToPage(nextIndex);
        }
      }
    });
  }

  @override
  void dispose() {
    _searchDebouncer?.cancel();
    _bannerTimer?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  // Responsive helpers
  double get horizontalPadding =>
      isSmallScreen
          ? 16.0
          : isTablet
          ? 24.0
          : 20.0;
  double get verticalSpacing => isSmallScreen ? 12.0 : 16.0;
  double get cardRadius => 12.0;
  double get buttonRadius => 8.0;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    _updateScreenDimensions();

    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: AppTheme.emeraldGreen,
          backgroundColor: Colors.white,
          displacement: 60,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              _buildSliverAppBar(),
              SliverToBoxAdapter(child: SizedBox(height: verticalSpacing)),
              SliverToBoxAdapter(child: _buildSearchSection()),
              SliverToBoxAdapter(child: _buildQuickActions()),
              SliverToBoxAdapter(child: _buildBannerSection()),
              SliverToBoxAdapter(child: _buildFeaturedSection()),
              _buildMainContent(),
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
                fontSize: isSmallScreen ? 16 : 18,
                letterSpacing: 0.5,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationButton() {
    return Consumer<HomeProvider>(
      builder: (context, provider, _) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _showLocationPicker,
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                constraints: BoxConstraints(maxWidth: screenWidth * 0.35),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.emeraldGreen.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.emeraldGreen.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (provider.isLocationLoading)
                      SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.emeraldGreen,
                          ),
                        ),
                      )
                    else
                      Icon(
                        Icons.location_on_rounded,
                        size: 14,
                        color: AppTheme.emeraldGreen,
                      ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        provider.currentLocationName.isNotEmpty
                            ? provider.currentLocationName
                            : 'Location',
                        style: TextStyle(
                          color: AppTheme.emeraldGreen,
                          fontSize: isSmallScreen ? 11 : 12,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 14,
                      color: AppTheme.emeraldGreen,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchSection() {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Material(
          elevation: 2,
          borderRadius: BorderRadius.circular(cardRadius),
          shadowColor: Colors.black.withOpacity(0.1),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(cardRadius),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search PGs, areas, amenities...',
                hintStyle: TextStyle(
                  color: Colors.grey[500],
                  fontSize: isSmallScreen ? 14 : 15,
                ),
                prefixIcon: Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.emeraldGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.search_rounded,
                    color: AppTheme.emeraldGreen,
                    size: 18,
                  ),
                ),
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: Icon(
                            Icons.clear_rounded,
                            color: Colors.grey[500],
                            size: 20,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            _handleSearch('');
                          },
                        )
                        : Container(
                          margin: const EdgeInsets.all(8),
                          child: Material(
                            color: AppTheme.emeraldGreen,
                            borderRadius: BorderRadius.circular(8),
                            child: InkWell(
                              onTap: _showFilters,
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                child: const Icon(
                                  Icons.tune_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: isSmallScreen ? 14 : 16,
                ),
              ),
              onChanged: _handleSearch,
              textInputAction: TextInputAction.search,
              onSubmitted: (value) => _handleSearch(value),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {
        'icon': Icons.man_rounded,
        'label': 'Boys PG',
        'color': AppTheme.emeraldGreen,
      },
      {
        'icon': Icons.woman_rounded,
        'label': 'Girls PG',
        'color': const Color(0xFFE91E63),
      },
      {
        'icon': Icons.apartment_rounded,
        'label': 'Co-living',
        'color': const Color(0xFFFF9800),
      },
      {
        'icon': Icons.stars_rounded,
        'label': 'Premium',
        'color': const Color(0xFF9C27B0),
      },
    ];

    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        margin: EdgeInsets.all(horizontalPadding),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth = (constraints.maxWidth - (3 * 8)) / 4;

            return Row(
              children:
                  actions.asMap().entries.map((entry) {
                    final index = entry.key;
                    final action = entry.value;

                    return Expanded(
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200 + (index * 100)),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        child: Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(buttonRadius),
                          elevation: 1,
                          shadowColor: Colors.black.withOpacity(0.1),
                          child: InkWell(
                            onTap:
                                () => _handleQuickAction(
                                  action['label'] as String,
                                ),
                            borderRadius: BorderRadius.circular(buttonRadius),
                            child: Container(
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
                        ),
                      ),
                    );
                  }).toList(),
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
            height: isSmallScreen ? 110 : 130,
            child: Stack(
              children: [
                CarouselSlider.builder(
                  carouselController: _carouselController,
                  itemCount: provider.banners.length,
                  itemBuilder: (context, index, realIndex) {
                    final banner = provider.banners[index];
                    return _buildBannerCard(banner);
                  },
                  options: CarouselOptions(
                    height: double.infinity,
                    viewportFraction: 0.95,
                    autoPlay: false, // Controlled manually
                    enlargeCenterPage: true,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentBannerIndex = index;
                      });
                    },
                  ),
                ),

                // Page indicator
                if (provider.banners.length > 1)
                  Positioned(
                    bottom: 8,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: AnimatedSmoothIndicator(
                        activeIndex: _currentBannerIndex,
                        count: provider.banners.length,
                        effect: WormEffect(
                          dotColor: Colors.white.withOpacity(0.5),
                          activeDotColor: Colors.white,
                          dotHeight: 6,
                          dotWidth: 6,
                          spacing: 4,
                        ),
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

  Widget _buildBannerCard(PromotionalBanner banner) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.emeraldGreen,
            AppTheme.secondaryGreen,
            AppTheme.lightMint,
          ],
        ),
        borderRadius: BorderRadius.circular(cardRadius),
        boxShadow: [
          BoxShadow(
            color: AppTheme.emeraldGreen.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleBannerTap(banner),
          borderRadius: BorderRadius.circular(cardRadius),
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        banner.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        banner.subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: isSmallScreen ? 12 : 13,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    onTap: () => _handleBannerTap(banner),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 12 : 16,
                        vertical: isSmallScreen ? 8 : 10,
                      ),
                      child: Text(
                        banner.actionText,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 11 : 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.emeraldGreen,
                        ),
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

  Widget _buildFeaturedSection() {
    return Consumer<HomeProvider>(
      builder: (context, provider, _) {
        if (provider.featuredPGs.isEmpty) {
          return const SizedBox.shrink();
        }

        return SlideTransition(
          position: _slideAnimation,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: verticalSpacing),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Featured PGs',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 20 : 22,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.deepCharcoal,
                        ),
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _navigateToAllFeatured(),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'View All',
                                style: TextStyle(
                                  color: AppTheme.emeraldGreen,
                                  fontSize: isSmallScreen ? 12 : 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 16,
                                color: AppTheme.emeraldGreen,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: verticalSpacing / 2),
              SizedBox(
                height: isSmallScreen ? 260 : 280,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding - 8,
                  ),
                  physics: const BouncingScrollPhysics(),
                  itemCount: provider.featuredPGs.length,
                  itemBuilder: (context, index) {
                    final pg = provider.featuredPGs[index];
                    return Container(
                      width:
                          isSmallScreen
                              ? screenWidth * 0.8
                              : screenWidth * 0.75,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      child: PGCard(
                        pgProperty: pg,
                        onTap: () => _navigateToPGDetail(pg.id),
                        onWishlistTap: () => _toggleWishlist(pg.id),
                        onContactTap: () => _contactPG(pg),
                        variant: PGCardVariant.standard,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMainContent() {
    return Consumer<HomeProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.pgList.isEmpty) {
          return SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: _buildLoadingState(),
            ),
          );
        }

        if (provider.hasError) {
          return SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: _buildErrorWidget(provider.errorMessage),
            ),
          );
        }

        if (provider.pgList.isEmpty) {
          return SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: _buildEmptyWidget(),
            ),
          );
        }

        return SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index < provider.pgList.length) {
                  final pg = provider.pgList[index];
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      margin: EdgeInsets.only(bottom: verticalSpacing),
                      child: PGCard(
                        pgProperty: pg,
                        onTap: () => _navigateToPGDetail(pg.id),
                        onWishlistTap: () => _toggleWishlist(pg.id),
                        onContactTap: () => _contactPG(pg),
                        variant: PGCardVariant.detailed,
                      ),
                    ),
                  );
                } else if (provider.isLoadingMore) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.emeraldGreen,
                      ),
                    ),
                  );
                }
                return null;
              },
              childCount:
                  provider.pgList.length + (provider.isLoadingMore ? 1 : 0),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: EdgeInsets.all(horizontalPadding * 2),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.emeraldGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                color: AppTheme.emeraldGreen,
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Finding perfect PGs for you...',
            style: TextStyle(
              color: AppTheme.deepCharcoal,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'This won\'t take long',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Container(
      padding: EdgeInsets.all(horizontalPadding),
      child: Center(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: Colors.red[400],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.deepCharcoal,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.read<HomeProvider>().refresh(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.emeraldGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(buttonRadius),
                ),
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text(
                'Try Again',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Container(
      padding: EdgeInsets.all(horizontalPadding),
      child: Center(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.emeraldGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 40,
                color: AppTheme.emeraldGreen,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No PGs found nearby',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.deepCharcoal,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or location filters',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed:
                  () =>
                      context.read<HomeProvider>().requestLocationPermission(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.emeraldGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(buttonRadius),
                ),
              ),
              icon: const Icon(Icons.my_location_rounded),
              label: const Text(
                'Enable Location',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return AnimatedScale(
      scale: _isRefreshing ? 0.8 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: FloatingActionButton(
        onPressed: _showFilters,
        backgroundColor: AppTheme.emeraldGreen,
        foregroundColor: Colors.white,
        elevation: 4,
        child: const Icon(Icons.filter_list_rounded),
      ),
    );
  }

  // Event handlers
  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    try {
      await context.read<HomeProvider>().refresh();
      if (mounted) {
        _showSuccessSnackBar('Data refreshed successfully');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Failed to refresh data');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  void _handleSearch(String query) {
    _searchDebouncer?.cancel();
    _searchDebouncer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        try {
          if (query.isNotEmpty) {
            context.read<HomeProvider>().searchPGs(query);
          } else {
            context.read<HomeProvider>().clearSearch();
          }
        } catch (e) {
          debugPrint('Search error: $e');
          _showErrorSnackBar('Search failed. Please try again.');
        }
      }
    });
  }

  void _handleQuickAction(String action) {
    // Implement quick action logic
    _showInfoSnackBar('$action filter applied');
  }

  void _handleBannerTap(PromotionalBanner banner) {
    // Implement banner action logic
    _showInfoSnackBar('Opening ${banner.title}...');
  }

  void _navigateToPGDetail(String pgId) {
    // Implement navigation to PG detail
    _showInfoSnackBar('Opening PG details...');
  }

  void _navigateToAllFeatured() {
    // Implement navigation to all featured PGs
    _showInfoSnackBar('Showing all featured PGs...');
  }

  void _toggleWishlist(String pgId) {
    // Implement wishlist toggle
    context.read<HomeProvider>().toggleWishlist(pgId);
  }

  void _contactPG(PGProperty pg) {
    // Implement contact functionality
    _showInfoSnackBar('Calling ${pg.name}...');
  }

  void _showLocationPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildLocationPicker(),
    );
  }

  Widget _buildLocationPicker() {
    return Container(
      padding: EdgeInsets.all(horizontalPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
          Text(
            'Select Location',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.deepCharcoal,
            ),
          ),
          const SizedBox(height: 20),
          _buildLocationOption(
            Icons.my_location_rounded,
            'Use Current Location',
            () {
              Navigator.pop(context);
              context.read<HomeProvider>().requestLocationPermission();
            },
          ),
          const SizedBox(height: 12),
          _buildLocationOption(Icons.search_rounded, 'Search Location', () {
            Navigator.pop(context);
            // TODO: Implement location search
          }),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
        ],
      ),
    );
  }

  Widget _buildLocationOption(IconData icon, String title, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(buttonRadius),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[200]!),
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
                  style: TextStyle(
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
              Expanded(
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
                child: Text(
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
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.emeraldGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(buttonRadius),
                ),
              ),
              child: const Text(
                'Apply Filters',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
        ],
      ),
    );
  }

  // Helper methods for showing messages
  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: EdgeInsets.all(horizontalPadding),
        ),
      );
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: AppTheme.emeraldGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: EdgeInsets.all(horizontalPadding),
        ),
      );
    }
  }

  void _showInfoSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppTheme.emeraldGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: EdgeInsets.all(horizontalPadding),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
