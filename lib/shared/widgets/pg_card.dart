// lib/shared/widgets/pg_card.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

import '../models/app_models.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../features/profile/providers/profile_provider.dart';
import '../../features/search/providers/search_provider.dart';

/// PG Card variants for different layouts
enum PGCardVariant {
  /// Regular full-width card
  regular,

  /// Compact card for horizontal scrolling
  compact
}

class PGCard extends StatelessWidget {
  final PGProperty pgProperty;
  final PGCardVariant variant;
  final Function()? onTap;
  final Function()? onWishlistTap;
  final bool isWishlisted;
  final bool showDistance;

  const PGCard({
    super.key,
    required this.pgProperty,
    this.variant = PGCardVariant.regular,
    this.onTap,
    this.onWishlistTap,
    this.isWishlisted = false,
    this.showDistance = true,
  });

  @override
  Widget build(BuildContext context) {
    if (variant == PGCardVariant.compact) {
      return _buildCompactCard(context);
    } else {
      return _buildRegularCard(context);
    }
  }

  Widget _buildRegularCard(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: _buildImage(height: 180),
                ),
                _buildLabels(),
                _buildWishlistButton(context),
              ],
            ),

            // Content section
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // PG Name and rating
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          pgProperty.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.deepCharcoal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      _buildRatingBadge(),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Location
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: AppTheme.gray600,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          pgProperty.address,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.gray700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (showDistance) ...[
                        const SizedBox(width: 4),
                        Text(
                          _getDistanceText(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.gray600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Amenities
                  SizedBox(
                    height: 26,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: pgProperty.amenities.length.clamp(0, 4),
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        if (index == 3 && pgProperty.amenities.length > 4) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.emeraldGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              '+${pgProperty.amenities.length - 3}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.emeraldGreen,
                              ),
                            ),
                          );
                        }

                        final amenity = pgProperty.amenities[index];
                        return _buildAmenityChip(amenity);
                      },
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Price and details
                  Row(
                    children: [
                      // Price
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '₹${pgProperty.price.toInt()}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.deepCharcoal,
                                ),
                              ),
                              const Text(
                                '/month',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.gray700,
                                ),
                              ),
                            ],
                          ),
                          if (pgProperty.securityDeposit > 0)
                            Text(
                              'Security: ₹${pgProperty.securityDeposit.toInt()}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.gray600,
                              ),
                            ),
                        ],
                      ),
                      const Spacer(),

                      // Details button
                      ElevatedButton(
                        onPressed: onTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.emeraldGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'View Details',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
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

  Widget _buildCompactCard(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: _buildImage(height: 120),
                ),
                _buildCompactLabels(),
                _buildWishlistButton(context, isCompact: true),
              ],
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and ratings
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            pgProperty.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.deepCharcoal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${pgProperty.rating}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.gray700,
                          ),
                        ),
                        const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 14,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Location
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 12,
                          color: AppTheme.gray600,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            pgProperty.address,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.gray700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),

                    // Price row - WITH OVERFLOW FIX
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '₹${pgProperty.price.toInt()}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.deepCharcoal,
                          ),
                        ),
                        // Wrap the inner Row with Flexible to prevent overflow
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min, // Use minimum space
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 16,
                              ),
                              Text(
                                ' ${pgProperty.rating}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.gray700,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Flexible(
                                child: Text(
                                  ' (${pgProperty.reviewCount})',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.gray600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
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
      ),
    );
  }

  Widget _buildImage({required double height}) {
    if (pgProperty.images.isEmpty) {
      return Container(
        height: height,
        color: Colors.grey[300],
        child: Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            color: Colors.grey[500],
            size: 32,
          ),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: pgProperty.images.first,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: Colors.grey[300],
        child: const Center(
          child: CircularProgressIndicator(
            color: AppTheme.emeraldGreen,
            strokeWidth: 2,
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[300],
        child: Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            color: Colors.grey[500],
            size: 32,
          ),
        ),
      ),
    );
  }

  Widget _buildLabels() {
    return Positioned(
      top: 12,
      left: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (pgProperty.isVerified)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.verified_outlined,
                    color: Colors.white,
                    size: 12,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'VERIFIED',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          if (pgProperty.genderPreference != 'ANY')
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: _getGenderColor(pgProperty.genderPreference),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _getGenderText(pgProperty.genderPreference),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCompactLabels() {
    final labels = <Widget>[];

    if (pgProperty.isVerified) {
      labels.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            'VERIFIED',
            style: TextStyle(
              color: Colors.white,
              fontSize: 8,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    if (pgProperty.genderPreference != 'ANY') {
      labels.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: _getGenderColor(pgProperty.genderPreference),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            _getGenderText(pgProperty.genderPreference),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 8,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    if (labels.isEmpty) return const SizedBox.shrink();

    return Positioned(
      top: 8,
      left: 8,
      child: Row(
        children: [
          for (int i = 0; i < labels.length; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            labels[i],
          ],
        ],
      ),
    );
  }

  Widget _buildWishlistButton(BuildContext context, {bool isCompact = false}) {
    return Positioned(
      top: isCompact ? 8 : 12,
      right: isCompact ? 8 : 12,
      child: GestureDetector(
        onTap: onWishlistTap,
        child: Container(
          padding: const EdgeInsets.all(6),
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
          child: Icon(
            isWishlisted ? Icons.favorite : Icons.favorite_border,
            color: isWishlisted ? Colors.red : AppTheme.gray400,
            size: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildRatingBadge() {
    if (pgProperty.rating == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getRatingColor(pgProperty.rating),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.star,
            color: Colors.white,
            size: 12,
          ),
          Text(
            ' ${pgProperty.rating}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenityChip(String amenity) {
    IconData icon;
    String label;

    switch (amenity.toUpperCase()) {
      case 'WIFI':
        icon = Icons.wifi;
        label = 'WiFi';
        break;
      case 'AC':
        icon = Icons.ac_unit;
        label = 'AC';
        break;
      case 'MEALS':
        icon = Icons.restaurant;
        label = 'Meals';
        break;
      case 'PARKING':
        icon = Icons.local_parking;
        label = 'Parking';
        break;
      case 'GYM':
        icon = Icons.fitness_center;
        label = 'Gym';
        break;
      case 'LAUNDRY':
        icon = Icons.local_laundry_service;
        label = 'Laundry';
        break;
      case 'RECREATION_ROOM':
        icon = Icons.sports_esports;
        label = 'Rec Room';
        break;
      case 'SECURITY':
        icon = Icons.security;
        label = 'Security';
        break;
      default:
        icon = Icons.check_circle;
        label = amenity;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.emeraldGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: AppTheme.emeraldGreen,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.emeraldGreen,
            ),
          ),
        ],
      ),
    );
  }

  String _getDistanceText() {
    // In a real app, this would calculate distance based on user's location
    // For now, just return a placeholder
    return '2.3 km';
  }

  Color _getRatingColor(double rating) {
    if (rating >= 4.5) return Colors.green[700]!;
    if (rating >= 4.0) return Colors.green;
    if (rating >= 3.5) return Colors.lightGreen;
    if (rating >= 3.0) return Colors.amber;
    return Colors.orange;
  }

  Color _getGenderColor(String gender) {
    switch (gender.toUpperCase()) {
      case 'MALE':
        return Colors.blue;
      case 'FEMALE':
        return Colors.pink;
      case 'CO_ED':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getGenderText(String gender) {
    switch (gender.toUpperCase()) {
      case 'MALE':
        return 'MALE ONLY';
      case 'FEMALE':
        return 'FEMALE ONLY';
      case 'CO_ED':
        return 'CO-ED';
      default:
        return 'ANY';
    }
  }
}

/// Shimmer loading placeholder for PG Cards
class PGCardShimmer extends StatelessWidget {
  /// Card variant (regular or compact)
  final PGCardVariant variant;

  /// Constructor
  const PGCardShimmer({
    super.key,
    this.variant = PGCardVariant.regular,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: variant == PGCardVariant.compact
          ? _buildCompactShimmer()
          : _buildRegularShimmer(),
    );
  }

  Widget _buildRegularShimmer() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          Container(
            height: 180,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
          ),

          // Content placeholder
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and rating
                Row(
                  children: [
                    Container(
                      width: 150,
                      height: 16,
                      color: Colors.white,
                    ),
                    const Spacer(),
                    Container(
                      width: 40,
                      height: 16,
                      color: Colors.white,
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Location
                Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 120,
                      height: 12,
                      color: Colors.white,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Amenities
                SizedBox(
                  height: 26,
                  child: Row(
                    children: List.generate(
                      3,
                      (index) => Container(
                        width: 60,
                        height: 26,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Price and button
                Row(
                  children: [
                    Container(
                      width: 70,
                      height: 16,
                      color: Colors.white,
                    ),
                    const Spacer(),
                    Container(
                      width: 100,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
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

  Widget _buildCompactShimmer() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          Container(
            height: 120,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
          ),

          // Content placeholder
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Container(
                    width: 120,
                    height: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),

                  // Location
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 100,
                        height: 10,
                        color: Colors.white,
                      ),
                    ],
                  ),
                  const Spacer(),

                  // Price
                  Container(
                    width: 70,
                    height: 16,
                    color: Colors.white,
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
