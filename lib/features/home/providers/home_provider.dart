// lib/features/home/providers/home_provider.dart
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
  bool _isLoading = true;
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

  // Wishlist data
  List<String> _wishlistedPGIds = [];

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

  List<PromotionalBanner> get banners => _banners;
  int get currentBannerIndex => _currentBannerIndex;

  /// Initialize home provider
  Future<void> initialize() async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();

    try {
      // Check for cached data first
      await _loadCachedData();

      // Load location in parallel with other data
      _loadLocationData();

      // Load all required data
      await Future.wait([
        _loadPromotionalBanners(),
        _loadFeaturedPGs(),
        _loadNearbyPGs(),
        _loadWishlistData(),
      ]);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _hasError = true;
      _errorMessage = 'Error loading data: ${e.toString()}';
      debugPrint('Error initializing home: $e');
      notifyListeners();
    }
  }

  /// Load cached data
  Future<void> _loadCachedData() async {
    try {
      // Load cached PGs
      if (_cacheService.isPGCacheValid()) {
        final cachedPGs = await _cacheService.getCachedPGs();
        if (cachedPGs.isNotEmpty) {
          _pgList = cachedPGs;
          // Extract featured and nearby PGs
          _featuredPGs = cachedPGs.where((pg) => pg.isFeatured).toList();
          _nearbyPGs = cachedPGs.take(5).toList(); // Simplification for now
          notifyListeners();
        }
      }

      // Load recent searches
      _recentSearches = await _cacheService.getRecentSearches();

      // Load wishlist
      _wishlistedPGIds = await _cacheService.getCachedWishlist();
    } catch (e) {
      debugPrint('Error loading cached data: $e');
    }
  }

  /// Load location data
  Future<void> _loadLocationData() async {
    _isLocationLoading = true;
    notifyListeners();

    try {
      final position = await _locationService.getCurrentPosition();
      if (position != null) {
        _currentPosition = position;
        _currentLocationName = _locationService.currentLocationName;
      } else {
        _currentLocationName = 'Location unavailable';
      }
    } catch (e) {
      _currentLocationName = 'Location error';
      debugPrint('Error loading location: $e');
    } finally {
      _isLocationLoading = false;
      notifyListeners();
    }
  }

  /// Load promotional banners
  Future<void> _loadPromotionalBanners() async {
    try {
      final response = await _apiService.getMockPromotionalBanners();

      _banners =
          response.map((json) {
            return PromotionalBanner(
              id: json['id'] as String,
              imageUrl: json['imageUrl'] as String,
              title: json['title'] as String,
              description: json['description'] as String,
              actionUrl: json['actionUrl'] as String,
            );
          }).toList();

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading promotional banners: $e');
    }
  }

  /// Load featured PGs
  Future<void> _loadFeaturedPGs() async {
    try {
      final response = await _apiService.getMockFeaturedPGs();

      _featuredPGs = response.map((json) => PGProperty.fromJson(json)).toList();

      // Update main PG list
      final existingIds = _pgList.map((pg) => pg.id).toSet();
      for (final pg in _featuredPGs) {
        if (!existingIds.contains(pg.id)) {
          _pgList.add(pg);
          existingIds.add(pg.id);
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading featured PGs: $e');
    }
  }

  /// Load nearby PGs
  Future<void> _loadNearbyPGs() async {
    try {
      final response = await _apiService.getMockNearbyPGs();

      _nearbyPGs = response.map((json) => PGProperty.fromJson(json)).toList();

      // Update main PG list
      final existingIds = _pgList.map((pg) => pg.id).toSet();
      for (final pg in _nearbyPGs) {
        if (!existingIds.contains(pg.id)) {
          _pgList.add(pg);
          existingIds.add(pg.id);
        }
      }

      // Cache PGs for offline access
      await _cacheService.cachePGs(_pgList);

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading nearby PGs: $e');
    }
  }

  /// Load more PGs (pagination)
  Future<void> loadMorePGs() async {
    if (_isLoadingMore || !_hasMoreData) {
      return;
    }

    _isLoadingMore = true;
    notifyListeners();

    try {
      // Simulate API delay
      await Future.delayed(const Duration(seconds: 1));

      // In a real app, would use _currentPage to fetch next page
      _currentPage++;

      // For demo, just duplicate some existing items with modified IDs
      final moreItems =
          _pgList.take(5).map((pg) {
            return pg.copyWith(
              id: '${pg.id}_page_$_currentPage',
              name: '${pg.name} ${_currentPage}',
            );
          }).toList();

      _pgList.addAll(moreItems);

      // Simulating end of data after page 3
      _hasMoreData = _currentPage < 3;

      _isLoadingMore = false;
      notifyListeners();
    } catch (e) {
      _isLoadingMore = false;
      debugPrint('Error loading more PGs: $e');
      notifyListeners();
    }
  }

  /// Update banner index
  void updateBannerIndex(int index) {
    _currentBannerIndex = index;
    notifyListeners();
  }

  /// Load wishlist data
  Future<void> _loadWishlistData() async {
    try {
      _wishlistedPGIds = await _cacheService.getCachedWishlist();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading wishlist data: $e');
    }
  }

  /// Toggle wishlist status for a PG
  Future<void> toggleWishlist(String pgId) async {
    try {
      if (_wishlistedPGIds.contains(pgId)) {
        _wishlistedPGIds.remove(pgId);
      } else {
        _wishlistedPGIds.add(pgId);
      }

      await _cacheService.cacheWishlist(_wishlistedPGIds);
      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling wishlist: $e');
    }
  }

  /// Check if a PG is wishlisted
  bool isWishlisted(String pgId) {
    return _wishlistedPGIds.contains(pgId);
  }

  /// Refresh all data
  Future<void> refreshData() async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();

    try {
      // Reset pagination
      _currentPage = 1;
      _hasMoreData = true;

      // Clear existing data
      _pgList = [];
      _featuredPGs = [];
      _nearbyPGs = [];
      _banners = [];

      // Load fresh data
      await Future.wait([
        _loadPromotionalBanners(),
        _loadFeaturedPGs(),
        _loadNearbyPGs(),
        _loadWishlistData(),
      ]);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _hasError = true;
      _errorMessage = 'Error refreshing data: ${e.toString()}';
      debugPrint('Error refreshing home data: $e');
      notifyListeners();
    }
  }
}
