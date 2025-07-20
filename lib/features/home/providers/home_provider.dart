import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

// Import models and services
import '../../../shared/models/app_models.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/cache_service.dart';

/// Home screen state management
class HomeProvider extends ChangeNotifier {
  // Services
  final ApiService _apiService = ApiService();
  final LocationService _locationService = LocationService();
  final CacheService _cacheService = CacheService();

  // State variables
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasError = false;
  String _errorMessage = '';

  // Location state
  Position? _currentPosition;
  String _currentLocationName = 'Getting location...';
  bool _isLocationLoading = false;

  // PG data
  List<PGProperty> _pgList = [];
  List<PGProperty> _featuredPGs = [];
  List<PGProperty> _nearbyPGs = [];

  // Pagination
  int _currentPage = 1;
  bool _hasMoreData = true;

  // Search and filters
  String _searchQuery = '';
  SearchFilter _appliedFilters = const SearchFilter();
  List<String> _recentSearches = [];

  // Promotional data
  List<PromotionalBanner> _banners = [];
  int _currentBannerIndex = 0;

  // Getters
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;

  Position? get currentPosition => _currentPosition;
  String get currentLocationName => _currentLocationName;
  bool get isLocationLoading => _isLocationLoading;

  List<PGProperty> get pgList => _pgList;
  List<PGProperty> get featuredPGs => _featuredPGs;
  List<PGProperty> get nearbyPGs => _nearbyPGs;

  bool get hasMoreData => _hasMoreData;
  String get searchQuery => _searchQuery;
  SearchFilter get appliedFilters => _appliedFilters;
  List<String> get recentSearches => _recentSearches;

  List<PromotionalBanner> get banners => _banners;
  int get currentBannerIndex => _currentBannerIndex;

  /// Initialize home screen data
  Future<void> initialize() async {
    _setLoading(true);
    _clearError();

    try {
      // Initialize services first
      await _apiService.initialize();
      await _locationService.initialize();
      await _cacheService.initialize();

      // Run initialization tasks concurrently
      await Future.wait([
        _initializeLocation(),
        _loadCachedData(),
        _loadRecentSearches(),
      ]);

      // Load fresh data
      await Future.wait([
        _loadFeaturedPGs(),
        _loadPromotionalBanners(),
        _loadNearbyPGs(),
      ]);
    } catch (e) {
      _setError('Failed to initialize: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Initialize location services
  Future<void> _initializeLocation() async {
    _setLocationLoading(true);

    try {
      final hasPermission = await _locationService.requestPermission();
      if (!hasPermission) {
        _currentLocationName = 'Location permission denied';
        return;
      }

      _currentPosition = await _locationService.getCurrentPosition();
      if (_currentPosition != null) {
        await _updateLocationName();
      }
    } catch (e) {
      _currentLocationName = 'Unable to get location';
      debugPrint('Location error: $e');
    } finally {
      _setLocationLoading(false);
    }
  }

  /// Update location name from coordinates
  Future<void> _updateLocationName() async {
    if (_currentPosition == null) return;

    try {
      final placemarks = await placemarkFromCoordinates(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        _currentLocationName = '${place.locality}, ${place.administrativeArea}';
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Geocoding error: $e');
    }
  }

  /// Load cached data for offline support
  Future<void> _loadCachedData() async {
    try {
      final cachedPGs = await _cacheService.getCachedPGs();
      if (cachedPGs.isNotEmpty) {
        _pgList = cachedPGs;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Cache loading error: $e');
    }
  }

  /// Load recent searches from local storage
  Future<void> _loadRecentSearches() async {
    try {
      _recentSearches = await _cacheService.getRecentSearches();
      notifyListeners();
    } catch (e) {
      debugPrint('Recent searches loading error: $e');
    }
  }

  /// Load featured PG properties
  Future<void> _loadFeaturedPGs() async {
    try {
      // For demo purposes, use sample data
      await Future.delayed(
        const Duration(milliseconds: 500),
      ); // Simulate API delay
      _featuredPGs = _getSamplePGs().where((pg) => pg.isFeatured).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Featured PGs loading error: $e');
    }
  }

  /// Load promotional banners
  Future<void> _loadPromotionalBanners() async {
    try {
      final response = await _apiService.get('/banners/active');

      _banners =
          (response['data'] as List)
              .map((json) => PromotionalBanner.fromJson(json))
              .toList();

      notifyListeners();
    } catch (e) {
      debugPrint('Banners loading error: $e');
      // Fallback to default banners
      _banners = _getDefaultBanners();
    }
  }

  /// Load nearby PG properties
  Future<void> _loadNearbyPGs() async {
    try {
      // For demo purposes, use sample data
      await Future.delayed(
        const Duration(milliseconds: 800),
      ); // Simulate API delay
      _nearbyPGs = _getSamplePGs();
      _pgList = _nearbyPGs;

      // Cache the nearby PGs
      await _cacheService.cachePGs(_nearbyPGs);
      notifyListeners();
    } catch (e) {
      debugPrint('Nearby PGs loading error: $e');
    }
  }

  /// Get sample PG data for demo
  List<PGProperty> _getSamplePGs() {
    return [
      PGProperty(
        id: '1',
        name: 'Green Valley PG',
        address: 'Sector 18, Noida, Near City Center Mall',
        city: 'Noida',
        state: 'Uttar Pradesh',
        pincode: '201301',
        latitude: 28.5706,
        longitude: 77.3261,
        monthlyRent: 12000,
        securityDeposit: 24000,
        availableRooms: 3,
        totalRooms: 20,
        rating: 4.5,
        reviewCount: 128,
        amenities: [
          AmenityType.wifi,
          AmenityType.ac,
          AmenityType.meals,
          AmenityType.laundry,
        ],
        images: [
          'https://images.unsplash.com/photo-1555854877-bab0e655b6f0?w=400',
        ],
        genderPreference: GenderPreference.any,
        mealsIncluded: true,
        roomTypes: [RoomType.single, RoomType.double],
        occupationType: OccupationType.any,
        ownerName: 'Mr. Sharma',
        contactPhone: '9876543210',
        checkInTime: '10:00 AM',
        checkOutTime: '11:00 AM',
        description: 'Premium PG with all modern amenities in prime location',
        houseRules: [
          'No smoking',
          'No loud music after 10 PM',
          'Visitors allowed till 9 PM',
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
      ),
      PGProperty(
        id: '2',
        name: 'Comfort Stay PG',
        address: 'Koramangala 4th Block, Bangalore',
        city: 'Bangalore',
        state: 'Karnataka',
        pincode: '560034',
        latitude: 12.9352,
        longitude: 77.6245,
        monthlyRent: 15000,
        securityDeposit: 30000,
        availableRooms: 1,
        totalRooms: 15,
        rating: 4.2,
        reviewCount: 89,
        amenities: [
          AmenityType.wifi,
          AmenityType.ac,
          AmenityType.gym,
          AmenityType.parking,
        ],
        images: [
          'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=400',
        ],
        genderPreference: GenderPreference.male,
        mealsIncluded: false,
        mealPrice: 3000,
        roomTypes: [RoomType.single],
        occupationType: OccupationType.workingProfessional,
        ownerName: 'Ms. Priya',
        contactPhone: '9876543211',
        checkInTime: '9:00 AM',
        checkOutTime: '12:00 PM',
        description: 'Modern PG for working professionals with gym facility',
        houseRules: [
          'No smoking',
          'Working professionals only',
          'No guests after 8 PM',
        ],
        nearbyLandmarks: [
          'IT Park - 1km',
          'Forum Mall - 2km',
          'Metro Station - 1.5km',
        ],
        isVerified: true,
        isFeatured: false,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now(),
      ),
      PGProperty(
        id: '3',
        name: 'Student Hub PG',
        address: 'Laxmi Nagar, New Delhi',
        city: 'New Delhi',
        state: 'Delhi',
        pincode: '110092',
        latitude: 28.6328,
        longitude: 77.2773,
        monthlyRent: 8000,
        securityDeposit: 16000,
        availableRooms: 8,
        totalRooms: 25,
        rating: 4.0,
        reviewCount: 56,
        amenities: [
          AmenityType.wifi,
          AmenityType.meals,
          AmenityType.studyRoom,
          AmenityType.laundry,
        ],
        images: [
          'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=400',
        ],
        genderPreference: GenderPreference.coEd,
        mealsIncluded: true,
        roomTypes: [RoomType.double, RoomType.triple],
        occupationType: OccupationType.student,
        ownerName: 'Mr. Kumar',
        contactPhone: '9876543212',
        checkInTime: '8:00 AM',
        checkOutTime: '11:00 AM',
        description: 'Affordable PG for students with study room facility',
        houseRules: ['Students only', 'No smoking', 'Study hours: 6-10 PM'],
        nearbyLandmarks: [
          'University - 3km',
          'Metro Station - 800m',
          'Library - 1km',
        ],
        isVerified: true,
        isFeatured: false,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now(),
      ),
      PGProperty(
        id: '4',
        name: 'Executive Heights PG',
        address: 'Cyber City, Gurgaon',
        city: 'Gurgaon',
        state: 'Haryana',
        pincode: '122002',
        latitude: 28.4595,
        longitude: 77.0266,
        monthlyRent: 18000,
        securityDeposit: 36000,
        availableRooms: 2,
        totalRooms: 12,
        rating: 4.8,
        reviewCount: 234,
        amenities: [
          AmenityType.wifi,
          AmenityType.ac,
          AmenityType.gym,
          AmenityType.parking,
          AmenityType.security,
        ],
        images: [
          'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=400',
        ],
        genderPreference: GenderPreference.any,
        mealsIncluded: false,
        mealPrice: 4000,
        roomTypes: [RoomType.single],
        occupationType: OccupationType.workingProfessional,
        ownerName: 'Mr. Singh',
        contactPhone: '9876543213',
        checkInTime: '10:00 AM',
        checkOutTime: '11:00 AM',
        description: 'Luxury PG for executives with premium amenities',
        houseRules: [
          'No smoking',
          'Executive dress code',
          'No visitors after 9 PM',
        ],
        nearbyLandmarks: [
          'Cyber Hub - 500m',
          'Metro Station - 1km',
          'Airport - 15km',
        ],
        isVerified: true,
        isFeatured: true,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  /// Search PG properties
  Future<void> searchPGs(String query) async {
    if (query.trim().isEmpty) {
      _searchQuery = '';
      await _loadNearbyPGs();
      return;
    }

    _searchQuery = query;
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.get(
        AppConstants.pgSearchEndpoint,
        queryParameters: {
          'query': query,
          'latitude': _currentPosition?.latitude,
          'longitude': _currentPosition?.longitude,
          'page': 1,
          'limit': AppConstants.defaultPageSize,
          ...(_appliedFilters.toJson()
            ..removeWhere((key, value) => value == null)),
        },
      );

      _pgList =
          (response['data'] as List)
              .map((json) => PGProperty.fromJson(json))
              .toList();

      _currentPage = 1;
      _hasMoreData = _pgList.length >= AppConstants.defaultPageSize;

      // Save to recent searches
      await _saveRecentSearch(query);

      notifyListeners();
    } catch (e) {
      _setError('Search failed: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Load more PG properties (pagination)
  Future<void> loadMorePGs() async {
    if (_isLoadingMore || !_hasMoreData) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final response = await _apiService.get(
        _searchQuery.isNotEmpty
            ? AppConstants.pgSearchEndpoint
            : AppConstants.pgNearbyEndpoint,
        queryParameters: {
          if (_searchQuery.isNotEmpty) 'query': _searchQuery,
          'latitude': _currentPosition?.latitude,
          'longitude': _currentPosition?.longitude,
          'page': _currentPage + 1,
          'limit': AppConstants.defaultPageSize,
          ...(_appliedFilters.toJson()
            ..removeWhere((key, value) => value == null)),
        },
      );

      final newPGs =
          (response['data'] as List)
              .map((json) => PGProperty.fromJson(json))
              .toList();

      if (newPGs.isNotEmpty) {
        _pgList.addAll(newPGs);
        _currentPage++;
        _hasMoreData = newPGs.length >= AppConstants.defaultPageSize;
      } else {
        _hasMoreData = false;
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Load more error: $e');
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Apply search filters
  Future<void> applyFilters(SearchFilter filters) async {
    _appliedFilters = filters;

    if (_searchQuery.isNotEmpty) {
      await searchPGs(_searchQuery);
    } else {
      await _loadNearbyPGs();
    }
  }

  /// Clear search and filters
  Future<void> clearSearch() async {
    _searchQuery = '';
    _appliedFilters = const SearchFilter();
    await _loadNearbyPGs();
  }

  /// Save search query to recent searches
  Future<void> _saveRecentSearch(String query) async {
    if (query.trim().isEmpty) return;

    _recentSearches.removeWhere(
      (search) => search.toLowerCase() == query.toLowerCase(),
    );
    _recentSearches.insert(0, query);

    if (_recentSearches.length > AppConstants.maxRecentSearches) {
      _recentSearches =
          _recentSearches.take(AppConstants.maxRecentSearches).toList();
    }

    await _cacheService.saveRecentSearches(_recentSearches);
  }

  /// Update current banner index
  void updateBannerIndex(int index) {
    _currentBannerIndex = index;
    notifyListeners();
  }

  /// Refresh all data
  Future<void> refresh() async {
    await initialize();
  }

  /// Toggle PG wishlist status
  Future<void> toggleWishlist(String pgId) async {
    try {
      // Find the PG in all lists and update
      final pgIndex = _pgList.indexWhere((pg) => pg.id == pgId);
      final featuredIndex = _featuredPGs.indexWhere((pg) => pg.id == pgId);
      final nearbyIndex = _nearbyPGs.indexWhere((pg) => pg.id == pgId);

      // TODO: Implement wishlist API call
      await _apiService.post('/wishlist/toggle', data: {'pgId': pgId});

      // Update local state (this will be properly implemented with wishlist provider)
      notifyListeners();
    } catch (e) {
      debugPrint('Wishlist toggle error: $e');
    }
  }

  /// Request location permission and update location
  Future<void> requestLocationPermission() async {
    await _initializeLocation();
    if (_currentPosition != null) {
      await _loadNearbyPGs();
    }
  }

  /// Change location manually
  Future<void> changeLocation(String locationName) async {
    _currentLocationName = locationName;
    notifyListeners();

    // TODO: Implement location search and coordinate lookup
    // For now, just reload data
    await _loadNearbyPGs();
  }

  /// Get default promotional banners
  List<PromotionalBanner> _getDefaultBanners() {
    return [
      const PromotionalBanner(
        id: '1',
        title: 'Only 2 rooms left at Heaven PG',
        subtitle: 'Book now and get 10% off',
        imageUrl: '',
        actionText: 'Book Now',
        backgroundColor: '#A5D6A7',
        textColor: '#2E7D32',
      ),
      const PromotionalBanner(
        id: '2',
        title: 'New PGs added in your area',
        subtitle: 'Explore premium accommodations',
        imageUrl: '',
        actionText: 'Explore',
        backgroundColor: '#FFEB3B',
        textColor: '#212121',
      ),
    ];
  }

  /// Helper methods for state management
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setLocationLoading(bool loading) {
    _isLocationLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _hasError = true;
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _hasError = false;
    _errorMessage = '';
  }

  @override
  void dispose() {
    // Clean up resources
    super.dispose();
  }
}

/// Promotional banner model
class PromotionalBanner {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String actionText;
  final String backgroundColor;
  final String textColor;
  final String? deepLink;
  final DateTime? expiryDate;

  const PromotionalBanner({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.actionText,
    required this.backgroundColor,
    required this.textColor,
    this.deepLink,
    this.expiryDate,
  });

  factory PromotionalBanner.fromJson(Map<String, dynamic> json) {
    return PromotionalBanner(
      id: json['id'],
      title: json['title'],
      subtitle: json['subtitle'],
      imageUrl: json['imageUrl'] ?? '',
      actionText: json['actionText'],
      backgroundColor: json['backgroundColor'],
      textColor: json['textColor'],
      deepLink: json['deepLink'],
      expiryDate:
          json['expiryDate'] != null
              ? DateTime.parse(json['expiryDate'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'imageUrl': imageUrl,
      'actionText': actionText,
      'backgroundColor': backgroundColor,
      'textColor': textColor,
      'deepLink': deepLink,
      'expiryDate': expiryDate?.toIso8601String(),
    };
  }

  bool get isExpired =>
      expiryDate != null && DateTime.now().isAfter(expiryDate!);
}
