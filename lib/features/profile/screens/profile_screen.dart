import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Initialize profile data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
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
            child: CustomScrollView(
              slivers: [
                _buildSliverAppBar(provider),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      _buildProfileHeader(provider),
                      _buildStatsCards(provider),
                      _buildTabSection(provider),
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
          // Profile Picture
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.emeraldGreen, width: 3),
                ),
                child: ClipOval(
                  child:
                      provider.selectedProfileImage != null
                          ? Image.file(
                            provider.selectedProfileImage!,
                            fit: BoxFit.cover,
                          )
                          : profile.profilePicture?.isNotEmpty == true
                          ? CachedNetworkImage(
                            imageUrl: profile.profilePicture!,
                            fit: BoxFit.cover,
                            placeholder:
                                (context, url) =>
                                    _buildAvatarPlaceholder(profile.name),
                            errorWidget:
                                (context, url, error) =>
                                    _buildAvatarPlaceholder(profile.name),
                          )
                          : _buildAvatarPlaceholder(profile.name),
                ),
              ),

              // Camera icon for image upload
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => _showImagePickerOptions(provider),
                  child: Container(
                    padding: const EdgeInsets.all(8),
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
              ),

              // Upload progress indicator
              if (provider.isUploadingImage)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Name and basic info
          Text(
            profile.name,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 4),

          Text(
            profile.email,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.gray600),
          ),

          const SizedBox(height: 8),

          // Verification status
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                profile.isVerified ? Icons.verified : Icons.info_outline,
                color: profile.isVerified ? AppTheme.success : AppTheme.warning,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                profile.isVerified
                    ? 'Verified Account'
                    : 'Verification Pending',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color:
                      profile.isVerified ? AppTheme.success : AppTheme.warning,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Profile completion bar
          _buildProfileCompletionBar(
            provider.profileStats.profileCompletionPercentage,
          ),
        ],
      ),
    );
  }

  /// Build stats cards
  Widget _buildStatsCards(ProfileProvider provider) {
    final stats = provider.profileStats;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Bookings',
              stats.totalBookings.toString(),
              Icons.home,
              AppTheme.emeraldGreen,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Wishlist',
              stats.wishlistCount.toString(),
              Icons.favorite,
              Colors.red,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Spent',
              stats.formattedTotalSpent,
              Icons.account_balance_wallet,
              AppTheme.warmYellow,
            ),
          ),
        ],
      ),
    );
  }

  /// Build individual stat card
  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppTheme.gray600),
          ),
        ],
      ),
    );
  }

  /// Build tab section
  Widget _buildTabSection(ProfileProvider provider) {
    return Container(
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
          // Tab bar
          Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppTheme.gray200, width: 1),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AppTheme.emeraldGreen,
              unselectedLabelColor: AppTheme.gray600,
              indicatorColor: AppTheme.emeraldGreen,
              indicatorWeight: 3,
              tabs: const [
                Tab(text: 'Bookings'),
                Tab(text: 'Wishlist'),
                Tab(text: 'Account'),
              ],
            ),
          ),

          // Tab content
          SizedBox(
            height: 400,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBookingsTab(provider),
                _buildWishlistTab(provider),
                _buildAccountTab(provider),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build bookings tab
  Widget _buildBookingsTab(ProfileProvider provider) {
    final bookings = provider.userBookings;

    if (bookings.isEmpty) {
      return _buildEmptyState(
        'No Bookings Yet',
        'Start exploring PGs to make your first booking',
        Icons.home_outlined,
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

  /// Build booking card
  Widget _buildBookingCard(Booking booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.gray50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Booking #${booking.bookingId.substring(0, 8)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getBookingStatusColor(
                    booking.status,
                  ).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  booking.formattedStatus,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _getBookingStatusColor(booking.status),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16, color: AppTheme.gray600),
              const SizedBox(width: 8),
              Text(
                'Check-in: ${_formatDate(booking.checkInDate)}',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppTheme.gray600),
              ),
            ],
          ),

          const SizedBox(height: 4),

          Row(
            children: [
              const Icon(
                Icons.account_balance_wallet,
                size: 16,
                color: AppTheme.gray600,
              ),
              const SizedBox(width: 8),
              Text(
                'Amount: ${AppConstants.currency}${booking.totalAmount.toInt()}',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppTheme.gray600),
              ),
            ],
          ),

          if (booking.canBeCancelled) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _cancelBooking(booking),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.error,
                      side: const BorderSide(color: AppTheme.error),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _viewBookingDetails(booking),
                    child: const Text('View Details'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Build wishlist tab
  Widget _buildWishlistTab(ProfileProvider provider) {
    final wishlistPGs = provider.wishlistPGs;

    if (wishlistPGs.isEmpty) {
      return _buildEmptyState(
        'No Saved PGs',
        'Add PGs to your wishlist to view them here',
        Icons.favorite_border,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: wishlistPGs.length,
      itemBuilder: (context, index) {
        final pg = wishlistPGs[index];
        return _buildWishlistPGCard(pg, provider);
      },
    );
  }

  /// Build wishlist PG card
  Widget _buildWishlistPGCard(PGProperty pg, ProfileProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.gray50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.gray200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 60,
            height: 60,
            color: AppTheme.gray200,
            child:
                pg.images.isNotEmpty
                    ? CachedNetworkImage(
                      imageUrl: pg.images.first,
                      fit: BoxFit.cover,
                    )
                    : const Icon(Icons.home, color: AppTheme.gray400),
          ),
        ),
        title: Text(
          pg.name,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              pg.address,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppTheme.gray600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '${AppConstants.currency}${pg.monthlyRent.toInt()}/month',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppTheme.emeraldGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.favorite, color: Colors.red),
          onPressed: () => provider.toggleWishlist(pg.id),
        ),
        onTap: () => _navigateToPGDetail(pg.id),
      ),
    );
  }

  /// Build account tab
  Widget _buildAccountTab(ProfileProvider provider) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildAccountOption(
          'Edit Profile',
          'Update your personal information',
          Icons.person_outline,
          () => _navigateToEditProfile(provider),
        ),
        _buildAccountOption(
          'Preferences',
          'Budget, location, and amenity preferences',
          Icons.tune,
          () => _showPreferencesSheet(provider),
        ),
        _buildAccountOption(
          'Notifications',
          'Manage notification settings',
          Icons.notifications_outlined,
          () => _showNotificationSettings(provider),
        ),
        _buildAccountOption(
          'Privacy & Security',
          'Account security and privacy settings',
          Icons.security,
          () => _showPrivacySettings(),
        ),
        _buildAccountOption(
          'Help & Support',
          'Get help and contact support',
          Icons.help_outline,
          () => _showHelpSupport(),
        ),
        _buildAccountOption(
          'About',
          'App information and terms',
          Icons.info_outline,
          () => _showAbout(),
        ),
        const SizedBox(height: 20),
        _buildLogoutButton(provider),
      ],
    );
  }

  /// Build account option
  Widget _buildAccountOption(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.emeraldGreen),
        title: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppTheme.gray600),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppTheme.gray400),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: AppTheme.gray50,
      ),
    );
  }

  /// Build logout button
  Widget _buildLogoutButton(ProfileProvider provider) {
    return ElevatedButton(
      onPressed: () => _showLogoutConfirmation(provider),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.error,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        'Logout',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Build empty state
  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppTheme.gray400),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: AppTheme.gray600),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.gray500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Build login prompt
  Widget _buildLoginPrompt() {
    return Center(
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
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  /// Build loading state
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading profile...'),
        ],
      ),
    );
  }

  /// Build avatar placeholder
  Widget _buildAvatarPlaceholder(String name) {
    return Container(
      color: AppTheme.emeraldGreen,
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'U',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// Build profile completion bar
  Widget _buildProfileCompletionBar(int percentage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Profile Completion',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
            Text(
              '$percentage%',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.emeraldGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: AppTheme.gray200,
          valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.emeraldGreen),
        ),
      ],
    );
  }

  // Helper methods and dialogs

  void _showImagePickerOptions(ProfileProvider provider) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Select Profile Picture',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Take Photo'),
                  onTap: () {
                    Navigator.pop(context);
                    provider.uploadProfilePicture(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Choose from Gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    provider.uploadProfilePicture(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _showSettingsSheet(ProfileProvider provider) {
    // Implementation for settings sheet
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings will be implemented')),
    );
  }

  void _showLogoutConfirmation(ProfileProvider provider) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await provider.logout();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.error,
                ),
                child: const Text('Logout'),
              ),
            ],
          ),
    );
  }

  void _navigateToEditProfile(ProfileProvider provider) {
    // TODO: Navigate to edit profile screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit profile screen will be implemented')),
    );
  }

  void _navigateToPGDetail(String pgId) {
    // TODO: Navigate to PG detail screen
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Opening PG details for $pgId')));
  }

  void _cancelBooking(Booking booking) {
    // TODO: Implement booking cancellation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Cancelling booking ${booking.bookingId}')),
    );
  }

  void _viewBookingDetails(Booking booking) {
    // TODO: Navigate to booking details
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Viewing booking ${booking.bookingId}')),
    );
  }

  void _showPreferencesSheet(ProfileProvider provider) {
    // TODO: Implement preferences sheet
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Preferences will be implemented')),
    );
  }

  void _showNotificationSettings(ProfileProvider provider) {
    // TODO: Implement notification settings
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notification settings will be implemented'),
      ),
    );
  }

  void _showPrivacySettings() {
    // TODO: Implement privacy settings
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Privacy settings will be implemented')),
    );
  }

  void _showHelpSupport() {
    // TODO: Implement help support
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Help & Support will be implemented')),
    );
  }

  void _showAbout() {
    // TODO: Implement about screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('About screen will be implemented')),
    );
  }

  Color _getBookingStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return AppTheme.success;
      case BookingStatus.pending:
        return AppTheme.warning;
      case BookingStatus.cancelled:
        return AppTheme.error;
      case BookingStatus.checkedIn:
        return AppTheme.info;
      default:
        return AppTheme.gray600;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
