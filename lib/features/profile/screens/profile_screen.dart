import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';

// Import providers and models
import '../providers/profile_provider.dart';
import '../../../shared/models/app_models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/navigation_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _setupAnimations();

    // Initialize profile data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().initialize();
    });
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

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      body: Consumer<ProfileProvider>(
        builder: (context, provider, child) {
          if (!provider.isAuthenticated) {
            return _buildLoginPrompt();
          }

          if (provider.isLoading && !provider.hasProfile) {
            return _buildLoadingState();
          }

          return RefreshIndicator(
            onRefresh: () => provider.refresh(),
            color: AppTheme.emeraldGreen,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildSliverAppBar(provider),
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        children: [
                          _buildProfileHeader(provider),
                          _buildStatsCards(provider),
                          _buildTabSection(provider),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Build sliver app bar with profile actions
  Widget _buildSliverAppBar(ProfileProvider provider) {
    return SliverAppBar(
      backgroundColor: AppTheme.emeraldGreen,
      expandedHeight: 120,
      floating: true,
      pinned: true,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Profile',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                AppTheme.emeraldGreen.withOpacity(0.8),
                AppTheme.emeraldGreen,
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.white),
          onPressed: () => _showSettingsSheet(provider),
        ),
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.white),
          onPressed: () => _navigateToEditProfile(provider),
        ),
      ],
    );
  }

  /// Build profile header with avatar and basic info
  Widget _buildProfileHeader(ProfileProvider provider) {
    final profile = provider.userProfile;
    if (profile == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile Picture with upload option
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              // Profile image
              GestureDetector(
                onTap: () => _showProfileImageOptions(provider),
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.emeraldGreen, width: 3),
                  ),
                  child: ClipOval(
                    child: provider.selectedProfileImage != null
                        ? Image.file(
                            provider.selectedProfileImage!,
                            fit: BoxFit.cover,
                          )
                        : profile.profilePicture?.isNotEmpty == true
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
              ),
              
              // Edit button
              if (!provider.isUploadingImage)
                GestureDetector(
                  onTap: () => _showProfileImageOptions(provider),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.emeraldGreen,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              
              // Loading indicator
              if (provider.isUploadingImage)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.emeraldGreen,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Name
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
                size: 16,
                color: AppTheme.gray600,
              ),
              const SizedBox(width: 4),
              Text(
                '+91 ${profile.phoneNumber}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.gray600,
                ),
              ),
            ],
          ),
          
          // Email if available
          if (profile.email != null && profile.email!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.email,
                  size: 16,
                  color: AppTheme.gray600,
                ),
                const SizedBox(width: 4),
                Text(
                  profile.email!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.gray600,
                  ),
                ),
              ],
            ),
          ],
          
          const SizedBox(height: 16),
          
          // Verified badge if applicable
          if (profile.isVerified)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppTheme.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.success.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.verified_user,
                    color: AppTheme.success,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
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
    );
  }

  /// Build stats cards section
  Widget _buildStatsCards(ProfileProvider provider) {
    final stats = provider.profileStats;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildStatCard(
            icon: Icons.bookmark,
            title: 'Bookings',
            value: stats.bookingsCount.toString(),
            color: Colors.orange,
            onTap: () {
              _tabController.animateTo(0);
            },
          ),
          _buildStatCard(
            icon: Icons.favorite,
            title: 'Wishlist',
            value: stats.wishlistCount.toString(),
            color: Colors.red,
            onTap: () {
              _tabController.animateTo(1);
            },
          ),
          _buildStatCard(
            icon: Icons.star,
            title: 'Reviews',
            value: stats.reviewsCount.toString(),
            color: Colors.amber,
            onTap: () {
              _tabController.animateTo(2);
            },
          ),
        ],
      ),
    );
  }

  /// Build individual stat card
  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.gray600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build tab section with bookings, wishlist, and reviews
  Widget _buildTabSection(ProfileProvider provider) {
    return Container(
      margin: const EdgeInsets.all(16),
      height: 500, // Fixed height for demonstration, adjust as needed
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Tab Bar
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppTheme.gray200),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AppTheme.emeraldGreen,
              unselectedLabelColor: AppTheme.gray600,
              indicatorColor: AppTheme.emeraldGreen,
              indicatorWeight: 3,
              tabs: const [
                Tab(text: 'BOOKINGS'),
                Tab(text: 'WISHLIST'),
                Tab(text: 'REVIEWS'),
              ],
            ),
          ),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBookingsTab(provider),
                _buildWishlistTab(provider),
                _buildReviewsTab(provider),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build bookings tab content
  Widget _buildBookingsTab(ProfileProvider provider) {
    final bookings = provider.userBookings;
    
    if (provider.isLoading) {
      return _buildLoadingList();
    }
    
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
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return _buildBookingCard(booking);
      },
    );
  }

  /// Build wishlist tab content
  Widget _buildWishlistTab(ProfileProvider provider) {
    final wishlistPGs = provider.wishlistPGs;
    
    if (provider.isLoading) {
      return _buildLoadingList();
    }
    
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
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: wishlistPGs.length,
      itemBuilder: (context, index) {
        final pg = wishlistPGs[index];
        return _buildWishlistCard(pg, provider);
      },
    );
  }

  /// Build reviews tab content
  Widget _buildReviewsTab(ProfileProvider provider) {
    // Placeholder for reviews tab
    if (provider.isLoading) {
      return _buildLoadingList();
    }
    
    // Assume no reviews for demo
    return _buildEmptyState(
      icon: Icons.rate_review_outlined,
      title: 'No Reviews Yet',
      message: 'Your reviews will appear here',
      buttonText: 'Write a Review',
      onButtonPressed: () {
        // Navigate to review screen or show message
      },
    );
  }

  /// Build booking card
  Widget _buildBookingCard(Booking booking) {
    final statusColor = _getStatusColor(booking.status);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.gray200),
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
                        booking.pgName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        booking.pgAddress,
                        style: TextStyle(
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
                            '₹${booking.amount}',
                            style: TextStyle(
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
                      Text(
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
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.emeraldGreen,
                    visualDensity: VisualDensity.compact,
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

  /// Build wishlist card
  Widget _buildWishlistCard(PGProperty pg, ProfileProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.gray200),
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
                    child: Icon(
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
                    color: _getGenderColor(pg.genderPreference).withOpacity(0.8),
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
                      '₹${pg.price}/mo',
                      style: TextStyle(
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
                    Icon(
                      Icons.location_on,
                      size: 14,
                      color: AppTheme.gray600,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        pg.address,
                        style: TextStyle(
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
                          _buildAmenityIcon(Icons.wifi, 'Wi-Fi'),
                          _buildAmenityIcon(Icons.ac_unit, 'AC'),
                          if (pg.amenities.contains(AmenityType.meals))
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
                          side: BorderSide(color: AppTheme.emeraldGreen),
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
                        onPressed: () {
                          // Navigate to booking
                          Navigator.pushNamed(
                            context,
                            AppConstants.bookingRoute,
                            arguments: pg.id,
                          );
                        },
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

  /// Build amenity icon
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

  /// Build empty state
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
    required String buttonText,
    required VoidCallback onButtonPressed,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
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

  /// Build loading list
  Widget _buildLoadingList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          height: 120,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 100,
                decoration: BoxDecoration(
                  color: AppTheme.gray200,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        height: 16,
                        width: 150,
                        decoration: BoxDecoration(
                          color: AppTheme.gray200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      Container(
                        height: 12,
                        width: 200,
                        decoration: BoxDecoration(
                          color: AppTheme.gray200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            height: 12,
                            width: 60,
                            decoration: BoxDecoration(
                              color: AppTheme.gray200,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            height: 12,
                            width: 60,
                            decoration: BoxDecoration(
                              color: AppTheme.gray200,
                              borderRadius: BorderRadius.circular(4),
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
        );
      },
    );
  }

  /// Build login prompt
  Widget _buildLoginPrompt() {
    return Center(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.account_circle, size: 80, color: AppTheme.gray400),
              const SizedBox(height: 20),
              Text(
                'Login Required',
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                'Please login to view your profile',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppTheme.gray600),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => NavigationService.navigateToLogin(),
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
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build loading state
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.emeraldGreen),
          ),
          SizedBox(height: 16),
          Text('Loading profile...'),
        ],
      ),
    );
  }

  /// Build avatar placeholder
  Widget _buildAvatarPlaceholder(String name) {
    final initials = name.isNotEmpty
        ? name.split(' ').map((part) => part.isNotEmpty ? part[0] : '').join().toUpperCase()
        : '?';
    
    return Container(
      color: AppTheme.emeraldGreen,
      child: Center(
        child: Text(
          initials.substring(0, initials.length > 2 ? 2 : initials.length),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 36,
          ),
        ),
      ),
    );
  }

  /// Show profile image options
  void _showProfileImageOptions(ProfileProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
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
              'Update Profile Picture',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.deepCharcoal,
              ),
            ),
            const SizedBox(height: 24),
            _buildImageOptionButton(
              icon: Icons.photo_camera,
              title: 'Take a Photo',
              onTap: () async {
                Navigator.pop(context);
                final XFile? photo = await _imagePicker.pickImage(
                  source: ImageSource.camera,
                  maxWidth: 800,
                  maxHeight: 800,
                  imageQuality: 85,
                );
                if (photo != null) {
                  provider.uploadProfileImage(File(photo.path));
                }
              },
            ),
            const SizedBox(height: 16),
            _buildImageOptionButton(
              icon: Icons.photo_library,
              title: 'Choose from Gallery',
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await _imagePicker.pickImage(
                  source: ImageSource.gallery,
                  maxWidth: 800,
                  maxHeight: 800,
                  imageQuality: 85,
                );
                if (image != null) {
                  provider.uploadProfileImage(File(image.path));
                }
              },
            ),
            if (provider.userProfile?.profilePicture != null) ...[
              const SizedBox(height: 16),
              _buildImageOptionButton(
                icon: Icons.delete,
                title: 'Remove Photo',
                onTap: () {
                  Navigator.pop(context);
                  provider.removeProfileImage();
                },
                color: Colors.red,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build image option button
  Widget _buildImageOptionButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.gray300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (color ?? AppTheme.emeraldGreen).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color ?? AppTheme.emeraldGreen),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: color ?? AppTheme.deepCharcoal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show settings sheet
  void _showSettingsSheet(ProfileProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20, left: 160),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
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
            _buildSettingsItem(
              icon: Icons.person,
              title: 'Account Settings',
              onTap: () {
                // Navigate to account settings
                Navigator.pop(context);
              },
            ),
            const Divider(),
            _buildSettingsItem(
              icon: Icons.notifications,
              title: 'Notifications',
              onTap: () {
                // Navigate to notifications settings
                Navigator.pop(context);
              },
            ),
            const Divider(),
            _buildSettingsItem(
              icon: Icons.security,
              title: 'Privacy & Security',
              onTap: () {
                // Navigate to privacy settings
                Navigator.pop(context);
              },
            ),
            const Divider(),
            _buildSettingsItem(
              icon: Icons.help_outline,
              title: 'Help & Support',
              onTap: () {
                // Navigate to help
                Navigator.pop(context);
              },
            ),
            const Divider(),
            _buildSettingsItem(
              icon: Icons.info_outline,
              title: 'About',
              onTap: () {
                // Navigate to about
                Navigator.pop(context);
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
                  provider.logout();
                  NavigationService.navigateToLogin();
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
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

  /// Build settings item
  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.emeraldGreen),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.gray400),
          ],
        ),
      ),
    );
  }

  /// Navigate to edit profile
  void _navigateToEditProfile(ProfileProvider provider) {
    // Navigate to edit profile screen
    Navigator.pushNamed(context, AppConstants.editProfileRoute);
  }

  /// Format date
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Get status text
  String _getStatusText(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.checkedIn:
        return 'Checked In';
      case BookingStatus.checkedOut:
        return 'Checked Out';
      case BookingStatus.cancelled:
        return 'Cancelled';
      case BookingStatus.refunded:
        return 'Refunded';
    }
  }

  /// Get status color
  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.confirmed:
        return AppTheme.emeraldGreen;
      case BookingStatus.checkedIn:
        return Colors.blue;
      case BookingStatus.checkedOut:
        return Colors.purple;
      case BookingStatus.cancelled:
        return Colors.red;
      case BookingStatus.refunded:
        return Colors.grey;
    }
  }

  /// Get gender text
  String _getGenderText(GenderPreference gender) {
    switch (gender) {
      case GenderPreference.male:
        return 'Male Only';
      case GenderPreference.female:
        return 'Female Only';
      case GenderPreference.any:
        return 'Any Gender';
      default:
        return 'Co-Ed';
    }
  }

  /// Get gender color
  Color _getGenderColor(GenderPreference gender) {
    switch (gender) {
      case GenderPreference.male:
        return Colors.blue;
      case GenderPreference.female:
        return Colors.pink;
      default:
        return Colors.purple;
    }
  }

  /// Get rating color
  Color _getRatingColor(double rating) {
    if (rating >= 4.5) return Colors.green;
    if (rating >= 3.5) return Colors.amber;
    if (rating >= 2.5) return Colors.orange;
    return Colors.red;
  }
}