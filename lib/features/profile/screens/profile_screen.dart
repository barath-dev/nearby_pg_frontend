import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

import '../providers/profile_provider.dart';
import '../../../shared/models/app_models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Initialize profile data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().initialize();
    });

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    setState(() {
      _isScrolled = _scrollController.offset > 10;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      body: Consumer<ProfileProvider>(
        builder: (context, provider, child) {
          if (!provider.isAuthenticated) {
            return _buildLoginPrompt(context);
          }

          if (provider.isLoading && !provider.hasProfile) {
            return _buildLoadingState();
          }

          return NestedScrollView(
            controller: _scrollController,
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              _buildProfileHeader(provider),
              _buildTabBar(),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildBookingsTab(provider),
                _buildWishlistTab(provider),
                _buildReviewsTab(provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(ProfileProvider provider) {
    final profile = provider.userProfile;
    if (profile == null) return SliverToBoxAdapter(child: Container());

    return SliverAppBar(
      expandedHeight: 240.0,
      floating: false,
      pinned: true,
      elevation: _isScrolled ? 2 : 0,
      backgroundColor: Colors.white,
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: AppTheme.gray600),
          onPressed: () => _showSettingsSheet(provider),
        ),
        IconButton(
          icon: const Icon(Icons.edit_outlined, color: AppTheme.gray600),
          onPressed: () => _showEditProfileSheet(provider),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              // Profile image
              GestureDetector(
                onTap: () => _showProfileImageOptions(provider),
                child: Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.emeraldGreen,
                          width: 3,
                        ),
                      ),
                      child: ClipOval(
                        child: provider.selectedProfileImage != null
                            ? Image.file(
                                provider.selectedProfileImage!,
                                fit: BoxFit.cover,
                              )
                            : profile.profilePicture != null
                                ? CachedNetworkImage(
                                    imageUrl: profile.profilePicture!,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      color: AppTheme.gray200,
                                      child: const Icon(
                                        Icons.person,
                                        color: AppTheme.gray400,
                                        size: 40,
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        _buildAvatarPlaceholder(profile.name),
                                  )
                                : _buildAvatarPlaceholder(profile.name),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.emeraldGreen,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // User name
              Text(
                profile.name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.deepCharcoal,
                    ),
              ),

              const SizedBox(height: 4),

              // Phone number
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.phone,
                    size: 14,
                    color: AppTheme.gray600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '+91 ${profile.phone}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.gray600,
                        ),
                  ),
                ],
              ),

              if (profile.email.isNotEmpty) ...[
                const SizedBox(height: 4),

                // Email
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.email,
                      size: 14,
                      color: AppTheme.gray600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      profile.email,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.gray600,
                          ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 12),

              // Verified badge
              if (profile.isVerified)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.success.withOpacity(0.3),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified_user,
                        color: AppTheme.success,
                        size: 14,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Verified User',
                        style: TextStyle(
                          color: AppTheme.success,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return SliverPersistentHeader(
      delegate: _SliverAppBarDelegate(
        TabBar(
          controller: _tabController,
          labelColor: AppTheme.emeraldGreen,
          unselectedLabelColor: AppTheme.gray600,
          indicatorColor: AppTheme.emeraldGreen,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'BOOKINGS'),
            Tab(text: 'WISHLIST'),
            Tab(text: 'REVIEWS'),
          ],
        ),
      ),
      pinned: true,
    );
  }

  Widget _buildBookingsTab(ProfileProvider provider) {
    if (provider.isLoading) {
      return _buildTabLoadingState();
    }

    final bookings = provider.userBookings;

    if (bookings.isEmpty) {
      return _buildEmptyState(
        icon: Icons.bookmark_border,
        title: 'No Bookings Yet',
        message: 'Your booking history will appear here',
        buttonText: 'Find PGs',
        onButtonPressed: () {
          Navigator.pushNamed(context, AppConstants.searchRoute);
        },
      );
    }

    return RefreshIndicator(
      onRefresh: provider.refresh,
      color: AppTheme.emeraldGreen,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return _buildBookingCard(booking);
        },
      ),
    );
  }

  Widget _buildWishlistTab(ProfileProvider provider) {
    if (provider.isLoading) {
      return _buildTabLoadingState();
    }

    final wishlistPGs = provider.wishlistPGs;

    if (wishlistPGs.isEmpty) {
      return _buildEmptyState(
        icon: Icons.favorite_border,
        title: 'Wishlist Empty',
        message: 'Save your favorite PGs here',
        buttonText: 'Explore PGs',
        onButtonPressed: () {
          Navigator.pushNamed(context, AppConstants.searchRoute);
        },
      );
    }

    return RefreshIndicator(
      onRefresh: provider.refresh,
      color: AppTheme.emeraldGreen,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: wishlistPGs.length,
        itemBuilder: (context, index) {
          final pg = wishlistPGs[index];
          return _buildWishlistCard(pg, provider);
        },
      ),
    );
  }

  Widget _buildReviewsTab(ProfileProvider provider) {
    return _buildEmptyState(
      icon: Icons.rate_review_outlined,
      title: 'No Reviews Yet',
      message: 'Your reviews will appear here',
      buttonText: 'Write a Review',
      onButtonPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review feature coming soon!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }

  Widget _buildBookingCard(Booking booking) {
    final statusColor = _getStatusColor(booking.status);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PG Image and Info
          Row(
            children: [
              // PG Image
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: booking.pgImage != null
                      ? CachedNetworkImage(
                          imageUrl: booking.pgImage!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: AppTheme.gray200,
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: AppTheme.gray200,
                            child: const Icon(
                              Icons.image_not_supported,
                              color: AppTheme.gray400,
                            ),
                          ),
                        )
                      : Container(
                          color: AppTheme.gray200,
                          child: const Icon(
                            Icons.home,
                            color: AppTheme.gray400,
                          ),
                        ),
                ),
              ),

              // PG Info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.pgName ?? 'PG Accommodation',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        booking.pgAddress ?? 'Address not available',
                        style: const TextStyle(
                          color: AppTheme.gray600,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          // Status badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _getStatusText(booking.status),
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                              ),
                            ),
                          ),

                          const Spacer(),

                          // Booking price
                          Text(
                            '₹${booking.totalAmount.toInt()}',
                            style: const TextStyle(
                              color: AppTheme.emeraldGreen,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Divider
          const Divider(height: 1),

          // Booking details
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Check-in date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Check-in',
                        style: TextStyle(
                          color: AppTheme.gray600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(booking.checkInDate),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                // View details button
                TextButton(
                  onPressed: () {
                    // Navigate to booking details
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Booking details coming soon!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.emeraldGreen,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  child: const Text('View Details'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWishlistCard(PGProperty pg, ProfileProvider provider) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // PG Image and Wishlist button
          Stack(
            children: [
              // PG Image
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 150,
                  child: pg.images.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: pg.images.first,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: AppTheme.gray200,
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: AppTheme.gray200,
                            child: const Icon(
                              Icons.image_not_supported,
                              color: AppTheme.gray400,
                            ),
                          ),
                        )
                      : Container(
                          color: AppTheme.gray200,
                          child: const Icon(
                            Icons.home,
                            color: AppTheme.gray400,
                          ),
                        ),
                ),
              ),

              // Wishlist button
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () {
                    provider.toggleWishlist(pg.id);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 20,
                    ),
                  ),
                ),
              ),

              // Gender badge
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        _getGenderColor(pg.genderPreference).withOpacity(0.8),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _getGenderText(pg.genderPreference),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // PG Info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // PG Name
                    Expanded(
                      child: Text(
                        pg.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // Price
                    Text(
                      '₹${pg.price.toInt()}/mo',
                      style: const TextStyle(
                        color: AppTheme.emeraldGreen,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Address
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 14,
                      color: AppTheme.gray600,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        pg.address,
                        style: const TextStyle(
                          color: AppTheme.gray600,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Rating and amenities
                Row(
                  children: [
                    // Rating
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getRatingColor(pg.rating).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 12,
                            color: _getRatingColor(pg.rating),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            pg.rating.toString(),
                            style: TextStyle(
                              color: _getRatingColor(pg.rating),
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Amenities
                    Expanded(
                      child: Row(
                        children: [
                          if (pg.amenities.contains('WIFI'))
                            _buildAmenityIcon(Icons.wifi, 'Wi-Fi'),
                          if (pg.amenities.contains('AC'))
                            _buildAmenityIcon(Icons.ac_unit, 'AC'),
                          if (pg.amenities.contains('MEALS'))
                            _buildAmenityIcon(Icons.restaurant, 'Meals'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Action buttons
                Row(
                  children: [
                    // View button
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          // Navigate to PG details
                          Navigator.pushNamed(
                            context,
                            AppConstants.pgDetailRoute,
                            arguments: pg.id,
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.emeraldGreen,
                          side: const BorderSide(color: AppTheme.emeraldGreen),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('View'),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Book button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.emeraldGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Book'),
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
  }

  Widget _buildAmenityIcon(IconData icon, String tooltip) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Tooltip(
        message: tooltip,
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppTheme.gray100,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(
            icon,
            size: 12,
            color: AppTheme.gray600,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginPrompt(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.account_circle,
            size: 80,
            color: AppTheme.gray400,
          ),
          const SizedBox(height: 20),
          Text(
            'Login Required',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.deepCharcoal,
                ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Please login to view your profile and access personalized features',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.gray600,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.goNamed(AppConstants.loginRoute);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.emeraldGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Login',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, AppConstants.signupRoute);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.emeraldGreen,
            ),
            child: const Text('Create an Account'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.emeraldGreen),
          ),
          SizedBox(height: 16),
          Text(
            'Loading profile...',
            style: TextStyle(color: AppTheme.gray600),
          ),
        ],
      ),
    );
  }

  Widget _buildTabLoadingState() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            height: 180,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
    required String buttonText,
    required VoidCallback onButtonPressed,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppTheme.gray400,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.deepCharcoal,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.gray600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onButtonPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.emeraldGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(buttonText),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarPlaceholder(String name) {
    final initials = name.isNotEmpty
        ? name
            .split(' ')
            .map((part) => part.isNotEmpty ? part[0] : '')
            .join()
            .toUpperCase()
        : '?';

    return Container(
      color: AppTheme.emeraldGreen,
      child: Center(
        child: Text(
          initials.length > 2 ? initials.substring(0, 2) : initials,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 36,
          ),
        ),
      ),
    );
  }

  void _showProfileImageOptions(ProfileProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              'Update Profile Picture',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.deepCharcoal,
                  ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.emeraldGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.photo_camera,
                  color: AppTheme.emeraldGreen,
                ),
              ),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.pop(context);
                // In a real app, would use image_picker
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Camera functionality coming soon!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.emeraldGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.photo_library,
                  color: AppTheme.emeraldGreen,
                ),
              ),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                // In a real app, would use image_picker
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Gallery functionality coming soon!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            if (provider.userProfile?.profilePicture != null)
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                ),
                title: const Text('Remove Photo'),
                onTap: () {
                  Navigator.pop(context);
                  provider.removeProfileImage();
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showSettingsSheet(ProfileProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              'Settings',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.deepCharcoal,
                  ),
            ),
            const SizedBox(height: 24),

            // Settings options
            _buildSettingsTile(
              icon: Icons.person,
              title: 'Account Settings',
              onTap: () {
                // Navigate to account settings
                Navigator.pop(context);
                _showEditProfileSheet(provider);
              },
            ),
            const Divider(),
            _buildSettingsTile(
              icon: Icons.notifications,
              title: 'Notifications',
              onTap: () {
                // Navigate to notifications settings
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Notification settings coming soon!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            const Divider(),
            _buildSettingsTile(
              icon: Icons.security,
              title: 'Privacy & Security',
              onTap: () {
                // Navigate to privacy settings
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Privacy settings coming soon!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            const Divider(),
            _buildSettingsTile(
              icon: Icons.help_outline,
              title: 'Help & Support',
              onTap: () {
                // Navigate to help
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Help & support coming soon!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            const Divider(),
            _buildSettingsTile(
              icon: Icons.info_outline,
              title: 'About',
              onTap: () {
                // Navigate to about
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('About page coming soon!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            const Divider(),

            const Spacer(),

            // Logout button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Handle logout
                  Navigator.pop(context);
                  _showLogoutConfirmation(provider);
                },
                icon: const Icon(Icons.logout),
                label: const Text(
                  'Logout',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.emeraldGreen),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
    );
  }

  void _showEditProfileSheet(ProfileProvider provider) {
    final profile = provider.userProfile;
    if (profile == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              'Edit Profile',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.deepCharcoal,
                  ),
            ),
            const SizedBox(height: 24),

            Expanded(
              child: ListView(
                children: [
                  // Profile Image
                  Center(
                    child: GestureDetector(
                      onTap: () => _showProfileImageOptions(provider),
                      child: Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppTheme.emeraldGreen,
                                width: 3,
                              ),
                            ),
                            child: ClipOval(
                              child: provider.selectedProfileImage != null
                                  ? Image.file(
                                      provider.selectedProfileImage!,
                                      fit: BoxFit.cover,
                                    )
                                  : profile.profilePicture != null
                                      ? CachedNetworkImage(
                                          imageUrl: profile.profilePicture!,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              Container(
                                            color: AppTheme.gray200,
                                            child: const Icon(
                                              Icons.person,
                                              color: AppTheme.gray400,
                                              size: 40,
                                            ),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              _buildAvatarPlaceholder(
                                                  profile.name),
                                        )
                                      : _buildAvatarPlaceholder(profile.name),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppTheme.emeraldGreen,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Name
                  const Text(
                    'Full Name',
                    style: TextStyle(
                      color: AppTheme.gray600,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: profile.name,
                    decoration: const InputDecoration(
                      hintText: 'Enter your full name',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    readOnly: true, // For demo purposes
                  ),
                  const SizedBox(height: 16),

                  // Email
                  const Text(
                    'Email Address',
                    style: TextStyle(
                      color: AppTheme.gray600,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: profile.email,
                    decoration: const InputDecoration(
                      hintText: 'Enter your email address',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    readOnly: true, // For demo purposes
                  ),
                  const SizedBox(height: 16),

                  // Phone
                  const Text(
                    'Phone Number',
                    style: TextStyle(
                      color: AppTheme.gray600,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: profile.phone,
                    decoration: const InputDecoration(
                      hintText: 'Enter your phone number',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      prefixText: '+91 ',
                    ),
                    keyboardType: TextInputType.phone,
                    readOnly: true, // For demo purposes
                  ),
                  const SizedBox(height: 16),

                  // Gender
                  const Text(
                    'Gender',
                    style: TextStyle(
                      color: AppTheme.gray600,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.gray300),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Text(
                          profile.gender ?? 'Not specified',
                          style: TextStyle(
                            color: profile.gender != null
                                ? AppTheme.deepCharcoal
                                : AppTheme.gray600,
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.arrow_drop_down,
                          color: AppTheme.gray600,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Location
                  const Text(
                    'Current Location',
                    style: TextStyle(
                      color: AppTheme.gray600,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: profile.currentLocation,
                    decoration: const InputDecoration(
                      hintText: 'Enter your current location',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    readOnly: true, // For demo purposes
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Save profile changes
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profile editing coming soon!'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.emeraldGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Save Changes',
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
    );
  }

  void _showLogoutConfirmation(ProfileProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              provider.logout();
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppConstants.loginRoute,
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'PENDING':
        return 'Pending';
      case 'CONFIRMED':
        return 'Confirmed';
      case 'CHECKED_IN':
        return 'Checked In';
      case 'CHECKED_OUT':
        return 'Checked Out';
      case 'CANCELLED':
        return 'Cancelled';
      case 'REFUNDED':
        return 'Refunded';
      default:
        return 'Unknown';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
        return Colors.orange;
      case 'CONFIRMED':
        return AppTheme.emeraldGreen;
      case 'CHECKED_IN':
        return Colors.blue;
      case 'CHECKED_OUT':
        return Colors.purple;
      case 'CANCELLED':
        return Colors.red;
      case 'REFUNDED':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _getGenderText(String gender) {
    switch (gender) {
      case 'MALE':
        return 'Male Only';
      case 'FEMALE':
        return 'Female Only';
      case 'ANY':
        return 'Any Gender';
      default:
        return 'Co-Ed';
    }
  }

  Color _getGenderColor(String gender) {
    switch (gender) {
      case 'MALE':
        return Colors.blue;
      case 'FEMALE':
        return Colors.pink;
      default:
        return Colors.purple;
    }
  }

  Color _getRatingColor(double rating) {
    if (rating >= 4.5) return Colors.green;
    if (rating >= 3.5) return Colors.amber;
    if (rating >= 2.5) return Colors.orange;
    return Colors.red;
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverAppBarDelegate(this.tabBar);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant _SliverAppBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar;
  }
}
