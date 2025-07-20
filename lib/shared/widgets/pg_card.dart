// lib/shared/widgets/pg_card.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shimmer/shimmer.dart';

import '../models/app_models.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';

/// Variant types for PG card display
enum PGCardVariant {
  /// Standard card with basic info
  standard,

  /// Compact card for horizontal lists
  compact,

  /// Detailed card with more information
  detailed,

  /// Map card for displaying in map callouts
  map,
}

/// Reusable PG card widget with different variants
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
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
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
                    placeholder: (context, url) => _buildImagePlaceholder(),
                    errorWidget: (context, url, error) => _buildImageError(),
                  )
                  : _buildImagePlaceholder(),
        ),

        // Tags
        Positioned(
          top: 12,
          left: 12,
          child: Row(
            children: [
              if (pgProperty.isVerified)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.emeraldGreen,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified, color: Colors.white, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        'Verified',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              if (pgProperty.isVerified && pgProperty.isFeatured)
                const SizedBox(width: 8),
              if (pgProperty.isFeatured)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.warmYellow,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.black87, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        'Featured',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),

        // Wishlist button
        if (onWishlistTap != null)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
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
              child: IconButton(
                icon: Icon(
                  isWishlisted ? Icons.favorite : Icons.favorite_border,
                  color: isWishlisted ? Colors.red : Colors.grey,
                ),
                onPressed: onWishlistTap,
                constraints: const BoxConstraints.tightFor(
                  width: 36,
                  height: 36,
                ),
                padding: EdgeInsets.zero,
                iconSize: 20,
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
        // Name and price row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name with gender indicator
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pgProperty.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildGenderIndicator(context),
                      if (pgProperty.mealsIncluded) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.lightMint,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Meals',
                            style: Theme.of(
                              context,
                            ).textTheme.labelSmall?.copyWith(
                              color: AppTheme.emeraldGreen,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Price
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.emeraldGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '₹${pgProperty.price.toStringAsFixed(0)}/mo',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppTheme.emeraldGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Address
        Text(
          pgProperty.address,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 12),

        // Rating and distance
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Rating
            Row(
              children: [
                RatingBar.builder(
                  initialRating: pgProperty.rating,
                  minRating: 0,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemSize: 16,
                  ignoreGestures: true,
                  itemBuilder:
                      (context, _) =>
                          const Icon(Icons.star, color: Colors.amber),
                  onRatingUpdate: (rating) {},
                ),
                const SizedBox(width: 4),
                Text(
                  '(${pgProperty.reviewCount})',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),

            // Distance
            if (showDistance && distance != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, size: 12, color: Colors.grey),
                    const SizedBox(width: 2),
                    Text(
                      '${distance!.toStringAsFixed(1)} km',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
          ],
        ),

        // Amenities (for detailed variant only)
        if (variant == PGCardVariant.detailed) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                pgProperty.amenities.take(4).map((amenity) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      amenity,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  );
                }).toList(),
          ),
        ],

        // Contact button (for detailed variant only)
        if (variant == PGCardVariant.detailed && onContactTap != null) ...[
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onContactTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.emeraldGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              minimumSize: const Size(double.infinity, 36),
            ),
            child: const Text('Contact'),
          ),
        ],
      ],
    );
  }

  Widget _buildGenderIndicator(BuildContext context) {
    Color color;
    IconData icon;
    String text;

    switch (pgProperty.genderPreference) {
      case 'MALE':
        color = Colors.blue;
        icon = Icons.male;
        text = 'Male';
        break;
      case 'FEMALE':
        color = Colors.pink;
        icon = Icons.female;
        text = 'Female';
        break;
      case 'ANY':
      default:
        color = Colors.purple;
        icon = Icons.people;
        text = 'Any';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Icon(Icons.home_work_rounded, color: Colors.grey[400], size: 40),
      ),
    );
  }

  Widget _buildImageError() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.broken_image_rounded,
          color: Colors.grey[400],
          size: 40,
        ),
      ),
    );
  }
}

/// Shimmer loading effect for PG cards
class PGCardShimmer extends StatelessWidget {
  final PGCardVariant variant;

  const PGCardShimmer({super.key, this.variant = PGCardVariant.standard});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Container(
              height: variant == PGCardVariant.compact ? 120 : 180,
              width: double.infinity,
              color: Colors.white,
            ),

            // Content placeholder
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Name
                      Container(width: 150, height: 20, color: Colors.white),

                      // Price
                      Container(width: 80, height: 24, color: Colors.white),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Address
                  Container(
                    width: double.infinity,
                    height: 16,
                    color: Colors.white,
                  ),

                  const SizedBox(height: 12),

                  // Bottom row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Rating
                      Container(width: 100, height: 16, color: Colors.white),

                      // Distance
                      Container(width: 60, height: 16, color: Colors.white),
                    ],
                  ),

                  // Extra for detailed variant
                  if (variant == PGCardVariant.detailed) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: List.generate(4, (index) {
                        return Container(
                          width: 60,
                          height: 24,
                          margin: const EdgeInsets.only(right: 8),
                          color: Colors.white,
                        );
                      }),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      height: 36,
                      color: Colors.white,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
