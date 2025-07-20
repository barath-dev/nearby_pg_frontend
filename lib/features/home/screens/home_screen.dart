// lib/features/home/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:card_swiper/card_swiper.dart';
// No need for smooth_page_indicator as Swiper has built-in pagination

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

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  // Variables for responsive layout
  double get _horizontalPadding =>
      MediaQuery.of(context).size.width < 600 ? 16.0 : 24.0;
  double get _verticalSpacing =>
      MediaQuery.of(context).size.width < 600 ? 16.0 : 24.0;

  @override
  void initState() {
    super.initState();

    // Load data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeProvider>().initialize();
    });

    // Setup scroll listener for pagination
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Load more data when reaching the bottom of the list
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

  void _showComingSoonMessage(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Consumer<HomeProvider>(
        builder: (context, provider, child) {
          return RefreshIndicator(
            onRefresh: () => provider.refreshData(),
            child: provider.isLoading
                ? _buildLoadingState()
                : provider.hasError
                    ? _buildErrorState(provider)
                    : _buildLoadedState(provider),
          );
        },
      ),
    );
  }

  // Loading state with shimmer effect
  Widget _buildLoadingState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(vertical: _verticalSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App bar shimmer
          _buildShimmerAppBar(),

          const SizedBox(height: 24),

          // Banner shimmer
          Container(
            margin: EdgeInsets.symmetric(horizontal: _horizontalPadding),
            height: 180,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
          ),

          const SizedBox(height: 24),

          // Featured PGs shimmer
          _buildSectionShimmer(),

          const SizedBox(height: 12),

          _buildHorizontalCardShimmer(),

          const SizedBox(height: 24),

          // Nearby PGs shimmer
          _buildSectionShimmer(),

          const SizedBox(height: 12),

          // PG list shimmer
          _buildVerticalCardShimmer(),
        ],
      ),
    );
  }

  Widget _buildShimmerAppBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: _horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 48), // Status bar space
          Row(
            children: [
              Container(
                width: 120,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const Spacer(),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: 180,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 16),
          // Search bar shimmer
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionShimmer() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: _horizontalPadding),
      child: Container(
        width: 140,
        height: 24,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Widget _buildHorizontalCardShimmer() {
    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: _horizontalPadding),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            width: 220,
            margin: const EdgeInsets.only(right: 16),
            child: const PGCardShimmer(variant: PGCardVariant.compact),
          );
        },
      ),
    );
  }

  Widget _buildVerticalCardShimmer() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      padding: EdgeInsets.symmetric(horizontal: _horizontalPadding),
      itemBuilder: (context, index) {
        return const PGCardShimmer();
      },
    );
  }

  // Error state with retry button
  Widget _buildErrorState(HomeProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              provider.errorMessage,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => provider.initialize(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.emeraldGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Loaded state with content
  Widget _buildLoadedState(HomeProvider provider) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // App bar
        _buildAppBar(provider),

        // Location indicator
        SliverToBoxAdapter(
          child: _buildLocationIndicator(provider),
        ),

        // Promotional banners
        if (provider.banners.isNotEmpty)
          SliverToBoxAdapter(
            child: _buildBanners(provider),
          ),

        // Featured PGs section
        if (provider.featuredPGs.isNotEmpty)
          SliverToBoxAdapter(
            child: _buildFeaturedPGs(provider),
          ),

        // Nearby PGs section header
        SliverToBoxAdapter(
          child: _buildSectionHeader(
            title: 'Nearby PGs',
            onViewAll: () => _showComingSoonMessage('Nearby PGs page'),
          ),
        ),

        // Nearby PGs list
        _buildNearbyPGsList(provider),

        // Bottom padding
        SliverToBoxAdapter(child: SizedBox(height: _verticalSpacing)),
      ],
    );
  }

  Widget _buildAppBar(HomeProvider provider) {
    return SliverAppBar(
      floating: true,
      backgroundColor: Colors.white,
      elevation: 0,
      toolbarHeight: 64,
      title: Row(
        children: [
          Text(
            'NEARBY',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.emeraldGreen,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
          ),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.emeraldGreen,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'PG',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.notifications_outlined,
            color: Colors.black87,
          ),
          onPressed: () => _showComingSoonMessage('Notifications'),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Container(
          margin: EdgeInsets.fromLTRB(
            _horizontalPadding,
            0,
            _horizontalPadding,
            12,
          ),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search for PGs, locations...',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              suffixIcon: provider.isLocationLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: Padding(
                        padding: EdgeInsets.all(12.0),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.emeraldGreen,
                          ),
                        ),
                      ),
                    )
                  : IconButton(
                      icon: const Icon(
                        Icons.filter_list,
                        color: Colors.grey,
                      ),
                      onPressed: () => _showComingSoonMessage('Filters'),
                    ),
            ),
            readOnly: true,
            onTap: () {
              // Navigate to search screen
              Navigator.pushNamed(context, AppConstants.searchRoute);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLocationIndicator(HomeProvider provider) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        _horizontalPadding,
        8,
        _horizontalPadding,
        16,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.location_on,
            size: 16,
            color: AppTheme.emeraldGreen,
          ),
          const SizedBox(width: 4),
          Text(
            'Your Location: ',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          Expanded(
            child: Text(
              provider.currentLocationName,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton(
            onPressed: () => _showComingSoonMessage('Change location feature'),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(40, 20),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              foregroundColor: AppTheme.emeraldGreen,
            ),
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  Widget _buildBanners(HomeProvider provider) {
    return Column(
      children: [
        Container(
          height: 180,
          margin: EdgeInsets.symmetric(horizontal: _horizontalPadding),
          child: Swiper(
            itemBuilder: (context, index) =>
                _buildBannerItem(provider.banners[index]),
            itemCount: provider.banners.length,
            viewportFraction: 0.92,
            scale: 0.95,
            autoplay: true,
            autoplayDelay: 5000,
            pagination: SwiperPagination(
              builder: DotSwiperPaginationBuilder(
                color: Colors.grey[300]!,
                activeColor: AppTheme.emeraldGreen,
                size: 8.0,
                activeSize: 8.0,
              ),
            ),
            // Optional: Uncomment for navigation arrows
            // control: SwiperControl(
            //   color: AppTheme.emeraldGreen,
            // ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildBannerItem(PromotionalBanner banner) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Banner image
            Image.network(
              banner.imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppTheme.lightMint,
                  child: Center(
                    child: Icon(
                      Icons.broken_image,
                      color: AppTheme.emeraldGreen.withOpacity(0.5),
                      size: 48,
                    ),
                  ),
                );
              },
            ),

            // Overlay gradient
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                    stops: const [0.6, 1.0],
                  ),
                ),
              ),
            ),

            // Banner content
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    banner.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    banner.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.9),
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

  Widget _buildFeaturedPGs(HomeProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          title: 'Featured PGs',
          onViewAll: () => _showComingSoonMessage('Featured PGs page'),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: _horizontalPadding),
            itemCount: provider.featuredPGs.length,
            itemBuilder: (context, index) {
              final pg = provider.featuredPGs[index];
              return Container(
                width: 220,
                margin: const EdgeInsets.only(right: 16),
                child: PGCard(
                  pgProperty: pg,
                  variant: PGCardVariant.compact,
                  onTap: () => _navigateToPGDetail(pg.id),
                  isWishlisted: provider.isWishlisted(pg.id),
                  onWishlistTap: () => provider.toggleWishlist(pg.id),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSectionHeader(
      {required String title, required VoidCallback onViewAll}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: _horizontalPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          TextButton(
            onPressed: onViewAll,
            child: const Text('View All'),
          ),
        ],
      ),
    );
  }

  Widget _buildNearbyPGsList(HomeProvider provider) {
    if (provider.nearbyPGs.isEmpty) {
      return SliverToBoxAdapter(
        child: _buildEmptyNearbyState(),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: _horizontalPadding),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index < provider.nearbyPGs.length) {
              final pg = provider.nearbyPGs[index];
              return PGCard(
                pgProperty: pg,
                onTap: () => _navigateToPGDetail(pg.id),
                isWishlisted: provider.isWishlisted(pg.id),
                onWishlistTap: () => provider.toggleWishlist(pg.id),
                showDistance: true,
                distance: pg.distanceFromCenter,
              );
            } else if (provider.isLoadingMore) {
              // Show loading indicator at the end
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              );
            } else {
              return const SizedBox.shrink();
            }
          },
          childCount:
              provider.nearbyPGs.length + (provider.isLoadingMore ? 1 : 0),
        ),
      ),
    );
  }

  Widget _buildEmptyNearbyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(
            Icons.location_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No PGs found nearby',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Try changing your location or expanding search radius',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
