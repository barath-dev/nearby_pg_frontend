// lib/features/pg/screens/pg_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../shared/models/app_models.dart';
import '../../../core/theme/app_theme.dart';

class PGDetailScreen extends StatefulWidget {
  final String pgId;

  const PGDetailScreen({super.key, required this.pgId});

  @override
  State<PGDetailScreen> createState() => _PGDetailScreenState();
}

class _PGDetailScreenState extends State<PGDetailScreen> {
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;
  bool _isWishlisted = false;

  // Sample PG data for demo (normally would come from provider)
  late PGProperty _pgProperty;

  @override
  void initState() {
    super.initState();
    // In a real app, this would load from a provider
    _loadPGDetails();
  }

  // Mock loading PG details
  void _loadPGDetails() {
    // This is sample data - in a real app, you'd fetch from API
    _pgProperty = PGProperty(
      id: widget.pgId,
      name: 'Green Valley PG',
      address: 'Sector 18, Noida, Near City Center Mall',
      latitude: 28.5706,
      longitude: 77.3261,
      price: 12000,
      securityDeposit: 24000,
      distanceFromCenter: 3.5,
      rating: 4.5,
      reviewCount: 128,
      amenities: [
        'WIFI',
        'AC',
        'MEALS',
        'LAUNDRY',
        'PARKING',
        'SECURITY',
        'HOT_WATER',
        'POWER_BACKUP'
      ],
      images: [
        'https://images.unsplash.com/photo-1555854877-bab0e655b6f0?w=400',
        'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=400',
        'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=400',
      ],
      genderPreference: 'ANY',
      mealsIncluded: true,
      roomTypes: ['SINGLE', 'DOUBLE'],
      occupationType: 'ANY',
      ownerName: 'Mr. Sharma',
      contactPhone: '9876543210',
      checkInTime: '10:00 AM',
      checkOutTime: '11:00 AM',
      description:
          'Premium PG with all modern amenities in prime location. This fully-furnished PG offers spacious rooms, nutritious meals, and a comfortable living environment with 24/7 security and power backup. Located in a prime location with easy access to public transportation, shopping malls, and restaurants.',
      houseRules: [
        'No smoking',
        'No loud music after 10 PM',
        'Visitors allowed till 9 PM',
        'Keep common areas clean',
        'Conserve electricity and water',
      ],
      nearbyLandmarks: [
        'Metro Station - 500m',
        'City Center Mall - 1km',
        'Hospital - 2km',
      ],
      isVerified: true,
      isFeatured: true,
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now(),
      availableRooms: 3,
      totalRooms: 20,
    );

    setState(() {});
  }

  void _toggleWishlist() {
    setState(() {
      _isWishlisted = !_isWishlisted;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isWishlisted ? 'Added to wishlist' : 'Removed from wishlist',
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.emeraldGreen,
      ),
    );
  }

  void _contactOwner() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Calling owner... (Feature coming soon)'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showBookingSheet() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Booking feature coming soon!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPGHeader(),
                _buildPriceSection(),
                _buildAmenitiesSection(),
                _buildDescriptionSection(),
                _buildRoomTypesSection(),
                _buildRulesSection(),
                _buildLocationSection(),
                _buildOwnerSection(),
                SizedBox(height: 100), // Space for bottom button
              ],
            ),
          ),
        ],
      ),
      bottomSheet: _buildBottomSheet(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      backgroundColor: AppTheme.emeraldGreen,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.emeraldGreen),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(
              _isWishlisted ? Icons.favorite : Icons.favorite_border,
              color: _isWishlisted ? Colors.red : AppTheme.emeraldGreen,
            ),
            onPressed: _toggleWishlist,
          ),
        ),
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.share, color: AppTheme.emeraldGreen),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Share feature coming soon!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(background: _buildImageCarousel()),
    );
  }

  Widget _buildImageCarousel() {
    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentImageIndex = index;
            });
          },
          itemCount: _pgProperty.images.length,
          itemBuilder: (context, index) {
            return CachedNetworkImage(
              imageUrl: _pgProperty.images[index],
              fit: BoxFit.cover,
              width: double.infinity,
              placeholder: (context, url) => Container(
                color: Colors.grey[300],
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[300],
                child: const Icon(
                  Icons.image_not_supported,
                  size: 50,
                  color: Colors.grey,
                ),
              ),
            );
          },
        ),

        // Image counter indicator
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Center(
            child: AnimatedSmoothIndicator(
              activeIndex: _currentImageIndex,
              count: _pgProperty.images.length,
              effect: ExpandingDotsEffect(
                dotHeight: 8,
                dotWidth: 8,
                activeDotColor: AppTheme.emeraldGreen,
                dotColor: Colors.white.withOpacity(0.5),
              ),
            ),
          ),
        ),

        // Verified badge
        if (_pgProperty.isVerified)
          Positioned(
            top: 20,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.success,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Verified',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Gradient overlay for better visibility
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.5)],
                stops: const [0.7, 1.0],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPGHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PG Name
          Text(
            _pgProperty.name,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.deepCharcoal,
                ),
          ),

          const SizedBox(height: 8),

          // Address
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: AppTheme.gray600),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  _pgProperty.address,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppTheme.gray600),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Rating and reviews
          Row(
            children: [
              RatingBarIndicator(
                rating: _pgProperty.rating,
                itemBuilder: (context, _) =>
                    const Icon(Icons.star_rounded, color: Colors.amber),
                itemCount: 5,
                itemSize: 18,
                unratedColor: Colors.grey[300],
              ),
              const SizedBox(width: 8),
              Text(
                '${_pgProperty.rating}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.deepCharcoal,
                    ),
              ),
              Text(
                ' (${_pgProperty.reviewCount} reviews)',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppTheme.gray600),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Gender preference and occupancy
          Row(
            children: [
              _buildInfoChip(
                _getGenderIcon(_pgProperty.genderPreference),
                _getGenderText(_pgProperty.genderPreference),
              ),
              const SizedBox(width: 8),
              _buildInfoChip(
                _getOccupancyIcon(_pgProperty.occupationType),
                _getOccupancyText(_pgProperty.occupationType),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSection() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pricing',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.deepCharcoal,
                ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildPriceCard(
                  'Monthly Rent',
                  '₹${_pgProperty.price.toInt()}',
                  Icons.calendar_month,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPriceCard(
                  'Security',
                  '₹${_pgProperty.securityDeposit.toInt()}',
                  Icons.security,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Availability info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.lightMint.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.lightMint),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppTheme.emeraldGreen),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Availability',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.deepCharcoal,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_pgProperty.availableRooms} out of ${_pgProperty.totalRooms} rooms available',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.deepCharcoal,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenitiesSection() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Amenities',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.deepCharcoal,
                ),
          ),
          const SizedBox(height: 16),
          Wrap(spacing: 16, runSpacing: 16, children: _buildAmenityWidgets()),
        ],
      ),
    );
  }

  List<Widget> _buildAmenityWidgets() {
    final amenityIcons = {
      'WIFI': Icons.wifi,
      'AC': Icons.ac_unit,
      'MEALS': Icons.restaurant,
      'LAUNDRY': Icons.local_laundry_service,
      'PARKING': Icons.local_parking,
      'GYM': Icons.fitness_center,
      'SECURITY': Icons.security,
      'HOUSEKEEPING': Icons.cleaning_services,
      'HOT_WATER': Icons.water_drop,
      'POWER_BACKUP': Icons.power,
      'CCTV': Icons.videocam,
      'STUDY_ROOM': Icons.book,
      'RECREATION_ROOM': Icons.sports_esports,
    };

    final amenityNames = {
      'WIFI': 'Wi-Fi',
      'AC': 'Air Conditioning',
      'MEALS': 'Meals Included',
      'LAUNDRY': 'Laundry',
      'PARKING': 'Parking',
      'GYM': 'Gym',
      'SECURITY': '24/7 Security',
      'HOUSEKEEPING': 'Housekeeping',
      'HOT_WATER': 'Hot Water',
      'POWER_BACKUP': 'Power Backup',
      'CCTV': 'CCTV',
      'STUDY_ROOM': 'Study Room',
      'RECREATION_ROOM': 'Recreation Room',
    };

    return _pgProperty.amenities.map((amenity) {
      return SizedBox(
        width: (MediaQuery.of(context).size.width - 48) / 3,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.emeraldGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                amenityIcons[amenity] ?? Icons.check_circle,
                color: AppTheme.emeraldGreen,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              amenityNames[amenity] ?? 'Other',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppTheme.deepCharcoal),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildDescriptionSection() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.deepCharcoal,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            _pgProperty.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.gray700,
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomTypesSection() {
    final roomTypeDetails = {
      'SINGLE': {
        'name': 'Single Room',
        'description': 'One single bed with study table and wardrobe.',
        'price': _pgProperty.price,
      },
      'DOUBLE': {
        'name': 'Double Sharing',
        'description': 'Two single beds with study tables and wardrobes.',
        'price': _pgProperty.price * 0.7,
      },
      'TRIPLE': {
        'name': 'Triple Sharing',
        'description':
            'Three single beds with shared study space and wardrobes.',
        'price': _pgProperty.price * 0.6,
      },
      'DORMITORY': {
        'name': 'Dormitory',
        'description': 'Multiple beds in a large hall with shared facilities.',
        'price': _pgProperty.price * 0.4,
      },
    };

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Room Types',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.deepCharcoal,
                ),
          ),
          const SizedBox(height: 16),
          Column(
            children: _pgProperty.roomTypes.map((roomType) {
              final details = roomTypeDetails[roomType] ??
                  {
                    'name': 'Room',
                    'description': 'Standard accommodation',
                    'price': _pgProperty.price,
                  };

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.gray200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppTheme.emeraldGreen.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.hotel,
                          color: AppTheme.emeraldGreen,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            details['name'] as String,
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.deepCharcoal,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            details['description'] as String,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppTheme.gray600),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '₹${(details['price'] as double).toInt()}',
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.emeraldGreen,
                          ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRulesSection() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'House Rules',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.deepCharcoal,
                ),
          ),
          const SizedBox(height: 16),
          Column(
            children: _pgProperty.houseRules.map((rule) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 20,
                      color: AppTheme.emeraldGreen,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        rule,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppTheme.gray700),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Location',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.deepCharcoal,
                ),
          ),

          const SizedBox(height: 12),

          // Map placeholder
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[200],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.map, size: 48, color: Colors.grey),
                  const SizedBox(height: 8),
                  Text(
                    'Map view coming soon!',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Nearby landmarks
          Text(
            'Nearby Landmarks',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.deepCharcoal,
                ),
          ),

          const SizedBox(height: 8),

          Column(
            children: _pgProperty.nearbyLandmarks.map((landmark) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.place,
                      size: 16,
                      color: AppTheme.gray600,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        landmark,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppTheme.gray700),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildOwnerSection() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Owner Details',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.deepCharcoal,
                ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.gray200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: AppTheme.emeraldGreen,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      _pgProperty.ownerName[0].toUpperCase(),
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _pgProperty.ownerName,
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.deepCharcoal,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Property Owner',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.gray600,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.phone,
                            size: 16,
                            color: AppTheme.emeraldGreen,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _pgProperty.contactPhone,
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.emeraldGreen,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: _contactOwner,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.emeraldGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Contact'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSheet() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '₹${_pgProperty.price.toInt()}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.emeraldGreen,
                        ),
                  ),
                  Text(
                    'per month',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppTheme.gray600),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: ElevatedButton(
                onPressed: _showBookingSheet,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.emeraldGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Book Now',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceCard(String title, String price, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.gray50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppTheme.emeraldGreen),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppTheme.gray600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            price,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.emeraldGreen,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.emeraldGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.emeraldGreen),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: AppTheme.emeraldGreen,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // Helper functions for gender and occupancy
  IconData _getGenderIcon(String gender) {
    switch (gender) {
      case 'MALE':
        return Icons.male;
      case 'FEMALE':
        return Icons.female;
      case 'ANY':
        return Icons.people;
      default:
        return Icons.people;
    }
  }

  String _getGenderText(String gender) {
    switch (gender) {
      case 'MALE':
        return 'Boys Only';
      case 'FEMALE':
        return 'Girls Only';
      case 'ANY':
        return 'Any Gender';
      default:
        return 'Co-ed';
    }
  }

  IconData _getOccupancyIcon(String type) {
    switch (type) {
      case 'STUDENT':
        return Icons.school;
      case 'PROFESSIONAL':
        return Icons.work;
      default:
        return Icons.person;
    }
  }

  String _getOccupancyText(String type) {
    switch (type) {
      case 'STUDENT':
        return 'Students';
      case 'PROFESSIONAL':
        return 'Professionals';
      default:
        return 'All Welcome';
    }
  }
}
