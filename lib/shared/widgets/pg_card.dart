import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../models/app_models.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';

/// Reusable PG card widget with different variants for different use cases
class PGCard extends StatelessWidget {
  final PGProperty pgProperty;
  final VoidCallback? onTap;
  final VoidCallback? onWishlistTap;
  final VoidCallback? onContactTap;
  final bool isWishlisted;
  final bool showDistance;
  final double? distance;
  final PGCardVariant variant;

  const PGCard({
    super.key,
    required this.pgProperty,
    this.onTap,
    this.onWishlistTap,
    this.onContactTap,
    this.isWishlisted = false,
    this.showDistance = false,
    this.distance,
    this.variant = PGCardVariant.standard,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppTheme.elevationSm,
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSection(context),
            Padding(
              padding: const EdgeInsets.all(12),
              child: _buildContentSection(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    return Stack(
      children: [
        // Image
        SizedBox(
          height: variant == PGCardVariant.compact ? 120 : 180,
          width: double.infinity,
          child:
              pgProperty.images.isNotEmpty
                  ? CachedNetworkImage(
                    imageUrl: pgProperty.images.first,
                    fit: BoxFit.cover,
                    placeholder:
                        (context, url) => Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ),
                    errorWidget:
                        (context, url, error) => Container(
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                          ),
                        ),
                  )
                  : Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(
                        Icons.home_work,
                        color: Colors.grey,
                        size: 40,
                      ),
                    ),
                  ),
        ),

        // Gradient overlay for better text visibility
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                stops: const [0.6, 1.0],
              ),
            ),
          ),
        ),

        // Wishlist button
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: onWishlistTap,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isWishlisted ? Icons.favorite : Icons.favorite_border,
                color: isWishlisted ? Colors.red : Colors.grey[600],
                size: 18,
              ),
            ),
          ),
        ),

        // Verified badge
        if (pgProperty.isVerified)
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.success,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified, color: Colors.white, size: 12),
                  const SizedBox(width: 4),
                  Text(
                    'Verified',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Price
        Positioned(
          bottom: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.emeraldGreen,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '₹${pgProperty.monthlyRent.toInt()}/mo',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),

        // Available rooms
        if (pgProperty.availableRooms > 0)
          Positioned(
            bottom: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color:
                    pgProperty.availableRooms <= 2
                        ? Colors.orange
                        : Colors.blue,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                pgProperty.availableRooms <= 2
                    ? 'Only ${pgProperty.availableRooms} left!'
                    : '${pgProperty.availableRooms} available',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildContentSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title and rating
        Row(
          children: [
            Expanded(
              child: Text(
                pgProperty.name,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text(
                  pgProperty.rating.toString(),
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 4),

        // Location
        Row(
          children: [
            const Icon(Icons.location_on, size: 14, color: Colors.grey),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                pgProperty.address,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (showDistance && distance != null) ...[
              const SizedBox(width: 4),
              Text(
                '${distance!.toStringAsFixed(1)} km',
                style: TextStyle(
                  color: AppTheme.emeraldGreen,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),

        const SizedBox(height: 8),

        // Amenities
        if (variant != PGCardVariant.compact)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _buildAmenityChips(pgProperty.amenities),
          ),

        if (variant == PGCardVariant.detailed) ...[
          const SizedBox(height: 12),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onContactTap,
                  icon: const Icon(Icons.phone, size: 16),
                  label: const Text('Contact'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.emeraldGreen,
                    side: BorderSide(color: AppTheme.emeraldGreen),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onTap,
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('View'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.emeraldGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  List<Widget> _buildAmenityChips(List<AmenityType> amenities) {
    // Map of amenities to icons and display names
    final amenityIcons = {
      AmenityType.wifi: Icons.wifi,
      AmenityType.ac: Icons.ac_unit,
      AmenityType.meals: Icons.restaurant,
      AmenityType.laundry: Icons.local_laundry_service,
      AmenityType.parking: Icons.local_parking,
      AmenityType.gym: Icons.fitness_center,
      AmenityType.security: Icons.security,
      AmenityType.housekeeping: Icons.cleaning_services,
      AmenityType.hotWater: Icons.water_drop,
      AmenityType.powerBackup: Icons.power,
      AmenityType.cctv: Icons.videocam,
      AmenityType.studyRoom: Icons.book,
      AmenityType.recreationRoom: Icons.sports_esports,
    };

    final amenityNames = {
      AmenityType.wifi: 'Wi-Fi',
      AmenityType.ac: 'AC',
      AmenityType.meals: 'Meals',
      AmenityType.laundry: 'Laundry',
      AmenityType.parking: 'Parking',
      AmenityType.gym: 'Gym',
      AmenityType.security: 'Security',
      AmenityType.housekeeping: 'Cleaning',
      AmenityType.hotWater: 'Hot Water',
      AmenityType.powerBackup: 'Power Backup',
      AmenityType.cctv: 'CCTV',
      AmenityType.studyRoom: 'Study Room',
      AmenityType.recreationRoom: 'Recreation',
    };

    // Display top 3 amenities + more if needed
    final displayAmenities = amenities.take(3).toList();

    return displayAmenities.map((amenity) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.lightMint.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                amenityIcons[amenity] ?? Icons.check,
                size: 12,
                color: AppTheme.emeraldGreen,
              ),
              const SizedBox(width: 4),
              Text(
                amenityNames[amenity] ?? 'Other',
                style: TextStyle(
                  fontSize: 10,
                  color: AppTheme.emeraldGreen,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList()
      ..addAll([
        if (amenities.length > 3)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '+${amenities.length - 3} more',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ]);
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
