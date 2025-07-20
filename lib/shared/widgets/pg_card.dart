import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

// Import models and theme
import '../models/app_models.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';

/// Reusable PG card widget following brand design specifications
class PGCard extends StatelessWidget {
  final PGProperty pgProperty;
  final VoidCallback? onTap;
  final VoidCallback? onWishlistTap;
  final VoidCallback? onContactTap;
  final bool isWishlisted;
  final bool showDistance;
  final double? distance;
  final PGCardVariant variant;
  final bool isShimmerLoading;

  const PGCard({
    super.key,
    required this.pgProperty,
    this.onTap,
    this.onWishlistTap,
    this.onContactTap,
    this.isWishlisted = false,
    this.showDistance = true,
    this.distance,
    this.variant = PGCardVariant.standard,
    this.isShimmerLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isShimmerLoading) {
      return _buildShimmerCard();
    }

    return Card(
      elevation: AppTheme.elevationSm,
      margin: EdgeInsets.symmetric(
        horizontal: variant == PGCardVariant.compact ? 8 : 16,
        vertical: 8,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: Container(
          constraints: BoxConstraints(
            minHeight: variant == PGCardVariant.compact ? 140 : 180,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageSection(context),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingMd),
                  child: _buildContentSection(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build image section with hero image and overlay elements
  Widget _buildImageSection(BuildContext context) {
    return SizedBox(
      height: variant == PGCardVariant.compact ? 100 : 120,
      width: double.infinity,
      child: Stack(
        children: [
          // Hero Image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppTheme.radiusMd),
              topRight: Radius.circular(AppTheme.radiusMd),
            ),
            child: CachedNetworkImage(
              imageUrl: pgProperty.images.isNotEmpty 
                  ? pgProperty.images.first 
                  : '',
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => _buildImagePlaceholder(),
              errorWidget: (context, url, error) => _buildImageError(),
            ),
          ),
          
          // Gradient overlay for better text readability
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppTheme.radiusMd),
                topRight: Radius.circular(AppTheme.radiusMd),
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.3),
                ],
              ),
            ),
          ),
          
          // Top row with verification badge and wishlist
          Positioned(
            top: 8,
            left: 8,
            right: 8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Verification badge
                if (pgProperty.isVerified)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.success,
                      borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.verified,
                          color: Colors.white,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Verified',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                
                // Wishlist button
                GestureDetector(
                  onTap: onWishlistTap,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isWishlisted ? Icons.favorite : Icons.favorite_border,
                      color: isWishlisted ? Colors.red : AppTheme.gray600,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Bottom row with urgency badge and featured badge
          Positioned(
            bottom: 8,
            left: 8,
            right: 8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Urgency badge
                if (pgProperty.urgencyMessage != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.warmYellow,
                      borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                    ),
                    child: Text(
                      pgProperty.urgencyMessage!,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.deepCharcoal,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ),
                
                // Featured badge
                if (pgProperty.isFeatured)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.emeraldGreen,
                      borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                    ),
                    child: Text(
                      'Featured',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build content section with PG details
  Widget _buildContentSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // PG name and rating row
        Row(
          children: [
            Expanded(
              child: Text(
                pgProperty.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            _buildRatingWidget(context),
          ],
        ),
        
        const SizedBox(height: 4),
        
        // Location and distance
        Row(
          children: [
            const Icon(
              Icons.location_on,
              size: 14,
              color: AppTheme.gray500,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                pgProperty.address,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.gray600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (showDistance && distance != null) ...[
              const SizedBox(width: 8),
              Text(
                '${distance!.toStringAsFixed(1)} km',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.emeraldGreen,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
        
        const SizedBox(height: 8),
        
        // Amenities row
        if (variant != PGCardVariant.compact)
          _buildAmenitiesRow(context),
        
        const SizedBox(height: 8),
        
        // Pricing and availability row
        Row(
          children: [
            Expanded(
              child: _buildPricingSection(context),
            ),
            _buildAvailabilityPill(context),
          ],
        ),
        
        if (variant == PGCardVariant.detailed) ...[
          const SizedBox(height: 12),
          _buildActionButtons(context),
        ],
      ],
    );
  }

  /// Build rating widget with stars
  Widget _buildRatingWidget(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        RatingBarIndicator(
          rating: pgProperty.rating,
          itemBuilder: (context, index) => const Icon(
            Icons.star,
            color: AppTheme.warmYellow,
          ),
          itemCount: 5,
          itemSize: 12,
          unratedColor: AppTheme.gray300,
        ),
        const SizedBox(width: 4),
        Text(
          pgProperty.formattedRating,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.gray600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Build amenities row with icons
  Widget _buildAmenitiesRow(BuildContext context) {
    final displayAmenities = pgProperty.amenities.take(4).toList();
    
    return Row(
      children: [
        ...displayAmenities.map((amenity) {
          final iconName = AppConstants.amenityIcons[amenity.name.toLowerCase()];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Tooltip(
              message: _getAmenityDisplayName(amenity),
              child: Icon(
                _getAmenityIcon(iconName),
                size: 16,
                color: AppTheme.emeraldGreen,
              ),
            ),
          );
        }),
        
        if (pgProperty.amenities.length > 4)
          Text(
            '+${pgProperty.amenities.length - 4}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.gray500,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }

  /// Build pricing section
  Widget _buildPricingSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '${AppConstants.currency}${pgProperty.monthlyRent.toInt()}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.emeraldGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '/month',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.gray600,
              ),
            ),
          ],
        ),
        if (variant == PGCardVariant.detailed)
          Text(
            'Security: ${AppConstants.currency}${pgProperty.securityDeposit.toInt()}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.gray600,
            ),
          ),
      ],
    );
  }

  /// Build availability pill
  Widget _buildAvailabilityPill(BuildContext context) {
    final isAvailable = pgProperty.isAvailable;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isAvailable ? AppTheme.lightMint : AppTheme.gray200,
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
      ),
      child: Text(
        isAvailable 
            ? '${pgProperty.availableRooms} rooms available'
            : 'Fully booked',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: isAvailable ? AppTheme.emeraldGreen : AppTheme.gray600,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Build action buttons for detailed variant
  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onContactTap,
            icon: const Icon(Icons.phone, size: 16),
            label: const Text('Contact'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
            child: const Text('View Details'),
          ),
        ),
      ],
    );
  }

  /// Build shimmer loading card
  Widget _buildShimmerCard() {
    return Card(
      elevation: AppTheme.elevationSm,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppTheme.radiusMd),
                  topRight: Radius.circular(AppTheme.radiusMd),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    width: double.infinity,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 12,
                    width: 200,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        height: 12,
                        width: 80,
                        color: Colors.white,
                      ),
                      const Spacer(),
                      Container(
                        height: 20,
                        width: 100,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build image placeholder
  Widget _buildImagePlaceholder() {
    return Container(
      color: AppTheme.gray200,
      child: const Center(
        child: Icon(
          Icons.image,
          color: AppTheme.gray400,
          size: 32,
        ),
      ),
    );
  }

  /// Build image error widget
  Widget _buildImageError() {
    return Container(
      color: AppTheme.gray200,
      child: const Center(
        child: Icon(
          Icons.broken_image,
          color: AppTheme.gray400,
          size: 32,
        ),
      ),
    );
  }

  /// Get amenity icon from name
  IconData _getAmenityIcon(String? iconName) {
    switch (iconName) {
      case 'wifi':
        return Icons.wifi;
      case 'ac_unit':
        return Icons.ac_unit;
      case 'restaurant':
        return Icons.restaurant;
      case 'local_laundry_service':
        return Icons.local_laundry_service;
      case 'local_parking':
        return Icons.local_parking;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'security':
        return Icons.security;
      case 'cleaning_services':
        return Icons.cleaning_services;
      case 'water_drop':
        return Icons.water_drop;
      case 'power':
        return Icons.power;
      case 'videocam':
        return Icons.videocam;
      case 'book':
        return Icons.book;
      case 'sports_esports':
        return Icons.sports_esports;
      default:
        return Icons.check_circle;
    }
  }

  /// Get amenity display name
  String _getAmenityDisplayName(AmenityType amenity) {
    switch (amenity) {
      case AmenityType.wifi:
        return 'Wi-Fi';
      case AmenityType.ac:
        return 'Air Conditioning';
      case AmenityType.meals:
        return 'Meals Included';
      case AmenityType.laundry:
        return 'Laundry Service';
      case AmenityType.parking:
        return 'Parking';
      case AmenityType.gym:
        return 'Gym/Fitness';
      case AmenityType.security:
        return 'Security';
      case AmenityType.housekeeping:
        return 'Housekeeping';
      case AmenityType.hotWater:
        return 'Hot Water';
      case AmenityType.powerBackup:
        return 'Power Backup';
      case AmenityType.cctv:
        return 'CCTV Security';
      case AmenityType.studyRoom:
        return 'Study Room';
      case AmenityType.recreationRoom:
        return 'Recreation Room';
      case AmenityType.other:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }
}

/// PG card variants for different use cases
enum PGCardVariant {
  /// Standard card with all basic information
  standard,
  
  /// Compact card for grid layouts
  compact,
  
  /// Detailed card with action buttons
  detailed,
}

/// Static method to build shimmer loading list
class PGCardShimmer extends StatelessWidget {
  final int itemCount;
  final PGCardVariant variant;

  const PGCardShimmer({
    super.key,
    this.itemCount = 5,
    this.variant = PGCardVariant.standard,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, index) => PGCard(
        pgProperty: _dummyPGProperty,
        isShimmerLoading: true,
        variant: variant,
      ),
    );
  }

  /// Dummy PG property for shimmer
  static final PGProperty _dummyPGProperty = PGProperty(
    id: '',
    name: '',
    address: '',
    city: '',
    state: '',
    pincode: '',
    latitude: 0,
    longitude: 0,
    monthlyRent: 0,
    securityDeposit: 0,
    availableRooms: 0,
    totalRooms: 0,
    rating: 0,
    reviewCount: 0,
    amenities: const [],
    images: const [],
    genderPreference: GenderPreference.any,
    mealsIncluded: false,
    roomTypes: const [],
    occupationType: OccupationType.any,
    ownerName: '',
    contactPhone: '',
    checkInTime: '',
    checkOutTime: '',
    description: '',
    houseRules: const [],
    nearbyLandmarks: const [],
    isVerified: false,
    isFeatured: false,
    isActive: false,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}