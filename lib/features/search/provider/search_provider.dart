import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

// Import models and services
import '../../../shared/models/app_models.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/cache_service.dart';

/// Search screen state management with advanced filtering and search capabilities
class SearchProvider extends ChangeNotifier {
  // Services
  final ApiService _apiService = ApiService();
  final LocationService _locationService = LocationService();
  final CacheService _cacheService = CacheService();

  // State variables
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasError = false;
  String _errorMessage = '';

  // Search data
  String _searchQuery = '';
  List<PGProperty> _searchResults = [];
  List<PGProperty> _filteredResults = [];
  List<String> _recentSearches = [];
  List<String> _searchSuggestions = [];

  // Pagination
  int _currentPage = 1;
  bool _hasMoreResults = true;
  int _totalResults = 0;

  // Filters and sorting
  SearchFilter _activeFilters = const SearchFilter();
  SearchFilter _tempFilters = const SearchFilter(); // For filter sheet
  String _sortBy = 'distance'; // distance, price, rating, newest
  String _sortOrder = 'asc'; // asc, desc

  // Location and map
  Position? _currentPosition;
  bool _isMapView = false;
  List<PGProperty> _mapMarkers = [];

  // Search performance
  Timer? _debounceTimer;
  String? _lastSearchQuery;
  DateTime? _lastSearchTime;

  // Filter state
  bool _showFilters = false;
  int _activeFilterCount = 0;

  // Getters
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;

  String get searchQuery => _searchQuery;
  List<PGProperty> get searchResults =>
      _filteredResults.isNotEmpty ? _filteredResults : _searchResults;
  List<String> get recentSearches => _recentSearches;
  List<String> get searchSuggestions => _searchSuggestions;

  int get currentPage => _currentPage;
  bool get hasMoreResults => _hasMoreResults;
  int get totalResults => _totalResults;

  SearchFilter get activeFilters => _activeFilters;
  SearchFilter get tempFilters => _tempFilters;
  String get sortBy => _sortBy;
  String get sortOrder => _sortOrder;

  Position? get currentPosition => _currentPosition;
  bool get isMapView => _isMapView;
  List<PGProperty> get mapMarkers => _mapMarkers;

  bool get showFilters => _showFilters;
  int get activeFilterCount => _activeFilterCount;
  bool get hasFiltersApplied => _activeFilterCount > 0;
  bool get hasSearchResults => searchResults.isNotEmpty;

  /// Initialize search provider
  Future<void> initialize() async {
    try {
      // Initialize services
      await _apiService.initialize();
      await _locationService.initialize();
      await _cacheService.initialize();

      // Load cached data
      await _loadCachedData();

      // Get current location
      await _getCurrentLocation();

      // Load initial suggestions
      await _loadSearchSuggestions();
    } catch (e) {
      debugPrint('Search provider initialization error: $e');
    }
  }

  /// Load cached search data
  Future<void> _loadCachedData() async {
    try {
      // Load recent searches
      _recentSearches = await _cacheService.getRecentSearches();

      // Load saved filters
      final savedFilters = await _cacheService.getSavedSearchFilters();
      if (savedFilters != null) {
        _activeFilters = savedFilters;
        _tempFilters = savedFilters;
        _calculateActiveFilterCount();
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading cached search data: $e');
    }
  }

  /// Get current location
  Future<void> _getCurrentLocation() async {
    try {
      _currentPosition = await _locationService.getCurrentPosition();
      notifyListeners();
    } catch (e) {
      debugPrint('Error getting current location: $e');
    }
  }

  /// Load search suggestions
  Future<void> _loadSearchSuggestions() async {
    try {
      final response = await _apiService.get('/search/suggestions');
      _searchSuggestions = List<String>.from(response['data'] ?? []);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading search suggestions: $e');
      // Fallback to default suggestions
      _searchSuggestions = [
        'PG near me',
        'Budget PG',
        'PG with meals',
        'Single room PG',
        'AC PG',
        'PG for students',
        'Executive PG',
        'PG with gym',
      ];
    }
  }

  /// Search PGs with debouncing
  Future<void> searchPGs(String query, {bool isNewSearch = true}) async {
    if (query.trim().isEmpty) {
      clearSearch();
      return;
    }

    _searchQuery = query;

    // Cancel previous timer
    _debounceTimer?.cancel();

    // Debounce search requests
    _debounceTimer = Timer(AppConstants.debounceDelay, () {
      _performSearch(query, isNewSearch: isNewSearch);
    });
  }

  /// Perform actual search
  Future<void> _performSearch(String query, {bool isNewSearch = true}) async {
    if (isNewSearch) {
      _setLoading(true);
      _currentPage = 1;
      _searchResults.clear();
      _filteredResults.clear();
    } else {
      _isLoadingMore = true;
      notifyListeners();
    }

    _clearError();

    try {
      final queryParams = {
        'query': query,
        'page': _currentPage,
        'limit': AppConstants.defaultPageSize,
        'sortBy': _sortBy,
        'sortOrder': _sortOrder,

        // Add location if available
        if (_currentPosition != null) ...{
          'latitude': _currentPosition!.latitude,
          'longitude': _currentPosition!.longitude,
        },

        // Add active filters
        ...(_activeFilters.toJson()
          ..removeWhere((key, value) => value == null)),
      };

      final response = await _apiService.get(
        AppConstants.pgSearchEndpoint,
        queryParameters: queryParams,
      );

      final results =
          (response['data'] as List)
              .map((json) => PGProperty.fromJson(json))
              .toList();

      if (isNewSearch) {
        _searchResults = results;
      } else {
        _searchResults.addAll(results);
      }

      _totalResults = response['total'] ?? _searchResults.length;
      _hasMoreResults = results.length >= AppConstants.defaultPageSize;

      // Update map markers
      _updateMapMarkers();

      // Save to recent searches
      if (isNewSearch) {
        await _saveToRecentSearches(query);
      }

      // Cache results
      await _cacheSearchResults(query, _searchResults);

      _lastSearchQuery = query;
      _lastSearchTime = DateTime.now();
    } catch (e) {
      _setError('Search failed: ${e.toString()}');

      // Try to load cached results
      final cachedResults = await _getCachedSearchResults(query);
      if (cachedResults.isNotEmpty) {
        _searchResults = cachedResults;
        _updateMapMarkers();
      }
    } finally {
      _setLoading(false);
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Load more search results (pagination)
  Future<void> loadMoreResults() async {
    if (_isLoadingMore || !_hasMoreResults || _searchQuery.isEmpty) return;

    _currentPage++;
    await _performSearch(_searchQuery, isNewSearch: false);
  }

  /// Apply filters to search results
  Future<void> applyFilters(SearchFilter filters) async {
    _activeFilters = filters;
    _tempFilters = filters;
    _calculateActiveFilterCount();

    // Save filters
    await _cacheService.saveSearchFilters(filters);

    // Re-search with new filters
    if (_searchQuery.isNotEmpty) {
      await _performSearch(_searchQuery, isNewSearch: true);
    }

    notifyListeners();
  }

  /// Update temporary filters (for filter sheet)
  void updateTempFilters(SearchFilter filters) {
    _tempFilters = filters;
    notifyListeners();
  }

  /// Reset temporary filters
  void resetTempFilters() {
    _tempFilters = _activeFilters;
    notifyListeners();
  }

  /// Clear all filters
  Future<void> clearFilters() async {
    _activeFilters = const SearchFilter();
    _tempFilters = const SearchFilter();
    _activeFilterCount = 0;

    await _cacheService.saveSearchFilters(_activeFilters);

    // Re-search without filters
    if (_searchQuery.isNotEmpty) {
      await _performSearch(_searchQuery, isNewSearch: true);
    }

    notifyListeners();
  }

  /// Update sort options
  Future<void> updateSort(String sortBy, String sortOrder) async {
    _sortBy = sortBy;
    _sortOrder = sortOrder;

    // Re-search with new sort
    if (_searchQuery.isNotEmpty) {
      await _performSearch(_searchQuery, isNewSearch: true);
    }

    notifyListeners();
  }

  /// Toggle map view
  void toggleMapView() {
    _isMapView = !_isMapView;
    notifyListeners();
  }

  /// Toggle filter panel
  void toggleFilters() {
    _showFilters = !_showFilters;
    notifyListeners();
  }

  /// Clear search
  void clearSearch() {
    _searchQuery = '';
    _searchResults.clear();
    _filteredResults.clear();
    _mapMarkers.clear();
    _totalResults = 0;
    _currentPage = 1;
    _hasMoreResults = true;
    _clearError();
    notifyListeners();
  }

  /// Refresh search results
  Future<void> refresh() async {
    if (_searchQuery.isNotEmpty) {
      await _performSearch(_searchQuery, isNewSearch: true);
    }
  }

  /// Get search suggestions based on query
  List<String> getSearchSuggestions(String query) {
    if (query.isEmpty) return _searchSuggestions.take(5).toList();

    final suggestions = <String>[];

    // Add recent searches that match
    suggestions.addAll(
      _recentSearches
          .where((search) => search.toLowerCase().contains(query.toLowerCase()))
          .take(3),
    );

    // Add general suggestions that match
    suggestions.addAll(
      _searchSuggestions
          .where(
            (suggestion) =>
                suggestion.toLowerCase().contains(query.toLowerCase()),
          )
          .take(5 - suggestions.length),
    );

    return suggestions;
  }

  /// Filter results locally (for quick filtering)
  void filterResultsLocally(SearchFilter filters) {
    if (_searchResults.isEmpty) return;

    _filteredResults =
        _searchResults.where((pg) {
          // Budget filter
          if (filters.minBudget != null &&
              pg.monthlyRent < filters.minBudget!) {
            return false;
          }
          if (filters.maxBudget != null &&
              pg.monthlyRent > filters.maxBudget!) {
            return false;
          }

          // Gender preference filter
          if (filters.genderPreference != null &&
              filters.genderPreference != GenderPreference.any &&
              pg.genderPreference != filters.genderPreference &&
              pg.genderPreference != GenderPreference.any) {
            return false;
          }

          // Room type filter
          if (filters.roomTypes?.isNotEmpty == true) {
            final hasMatchingRoomType = filters.roomTypes!.any(
              (roomType) => pg.roomTypes.contains(roomType),
            );
            if (!hasMatchingRoomType) return false;
          }

          // Amenities filter
          if (filters.requiredAmenities?.isNotEmpty == true) {
            final hasAllAmenities = filters.requiredAmenities!.every(
              (amenity) => pg.amenities.contains(amenity),
            );
            if (!hasAllAmenities) return false;
          }

          // Meals filter
          if (filters.mealsIncluded != null &&
              pg.mealsIncluded != filters.mealsIncluded) {
            return false;
          }

          // Rating filter
          if (filters.minRating != null && pg.rating < filters.minRating!) {
            return false;
          }

          // Distance filter
          if (filters.maxDistance != null && _currentPosition != null) {
            final distance = _locationService.calculateDistance(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
              pg.latitude,
              pg.longitude,
            );
            if (distance > filters.maxDistance!) return false;
          }

          return true;
        }).toList();

    // Sort filtered results
    _sortResults(_filteredResults);

    notifyListeners();
  }

  /// Sort search results
  void _sortResults(List<PGProperty> results) {
    results.sort((a, b) {
      int comparison = 0;

      switch (_sortBy) {
        case 'price':
          comparison = a.monthlyRent.compareTo(b.monthlyRent);
          break;
        case 'rating':
          comparison = a.rating.compareTo(b.rating);
          break;
        case 'distance':
          if (_currentPosition != null) {
            final distanceA = _locationService.calculateDistance(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
              a.latitude,
              a.longitude,
            );
            final distanceB = _locationService.calculateDistance(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
              b.latitude,
              b.longitude,
            );
            comparison = distanceA.compareTo(distanceB);
          }
          break;
        case 'newest':
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
        default:
          comparison = 0;
      }

      return _sortOrder == 'desc' ? -comparison : comparison;
    });
  }

  /// Update map markers
  void _updateMapMarkers() {
    _mapMarkers = List.from(_searchResults);

    // Limit markers for performance
    if (_mapMarkers.length > 100) {
      _mapMarkers = _mapMarkers.take(100).toList();
    }
  }

  /// Save search to recent searches
  Future<void> _saveToRecentSearches(String query) async {
    if (query.trim().isEmpty) return;

    // Remove if already exists
    _recentSearches.removeWhere(
      (search) => search.toLowerCase() == query.toLowerCase(),
    );

    // Add to beginning
    _recentSearches.insert(0, query);

    // Limit to max recent searches
    if (_recentSearches.length > AppConstants.maxRecentSearches) {
      _recentSearches =
          _recentSearches.take(AppConstants.maxRecentSearches).toList();
    }

    // Save to cache
    await _cacheService.saveRecentSearches(_recentSearches);
  }

  /// Cache search results
  Future<void> _cacheSearchResults(
    String query,
    List<PGProperty> results,
  ) async {
    try {
      final cacheKey = 'search_${query.toLowerCase().replaceAll(' ', '_')}';
      await _cacheService.setCache(
        cacheKey,
        results.map((pg) => pg.toJson()).toList(),
        expiry: AppConstants.shortCacheExpiry,
        category: 'search',
      );
    } catch (e) {
      debugPrint('Error caching search results: $e');
    }
  }

  /// Get cached search results
  Future<List<PGProperty>> _getCachedSearchResults(String query) async {
    try {
      final cacheKey = 'search_${query.toLowerCase().replaceAll(' ', '_')}';
      final cached = await _cacheService.getCache<List>(cacheKey);

      if (cached != null) {
        return cached
            .map((json) => PGProperty.fromJson(Map<String, dynamic>.from(json)))
            .toList();
      }
    } catch (e) {
      debugPrint('Error getting cached search results: $e');
    }

    return [];
  }

  /// Calculate active filter count
  void _calculateActiveFilterCount() {
    int count = 0;

    if (_activeFilters.minBudget != null || _activeFilters.maxBudget != null) {
      count++;
    }
    if (_activeFilters.genderPreference != null) count++;
    if (_activeFilters.roomTypes?.isNotEmpty == true) count++;
    if (_activeFilters.requiredAmenities?.isNotEmpty == true) count++;
    if (_activeFilters.mealsIncluded != null) count++;
    if (_activeFilters.occupationType != null) count++;
    if (_activeFilters.minRating != null) count++;
    if (_activeFilters.maxDistance != null) count++;

    _activeFilterCount = count;
  }

  /// Get filter summary text
  String getFilterSummary() {
    final filters = <String>[];

    if (_activeFilters.minBudget != null || _activeFilters.maxBudget != null) {
      final min = _activeFilters.minBudget ?? 0;
      final max = _activeFilters.maxBudget ?? double.infinity;
      if (max == double.infinity) {
        filters.add('₹${min.toInt()}+');
      } else {
        filters.add('₹${min.toInt()}-₹${max.toInt()}');
      }
    }

    if (_activeFilters.genderPreference != null) {
      filters.add(_getGenderDisplayName(_activeFilters.genderPreference!));
    }

    if (_activeFilters.roomTypes?.isNotEmpty == true) {
      filters.add('${_activeFilters.roomTypes!.length} room types');
    }

    if (_activeFilters.requiredAmenities?.isNotEmpty == true) {
      filters.add('${_activeFilters.requiredAmenities!.length} amenities');
    }

    if (_activeFilters.mealsIncluded == true) {
      filters.add('Meals included');
    }

    return filters.join(' • ');
  }

  /// Get gender display name
  String _getGenderDisplayName(GenderPreference gender) {
    switch (gender) {
      case GenderPreference.male:
        return 'Male';
      case GenderPreference.female:
        return 'Female';
      case GenderPreference.coEd:
        return 'Co-ed';
      case GenderPreference.any:
        return 'Any';
    }
  }

  /// Clear search history
  Future<void> clearSearchHistory() async {
    _recentSearches.clear();
    await _cacheService.saveRecentSearches(_recentSearches);
    notifyListeners();
  }

  /// Remove search from history
  Future<void> removeFromSearchHistory(String query) async {
    _recentSearches.remove(query);
    await _cacheService.saveRecentSearches(_recentSearches);
    notifyListeners();
  }

  /// Get search performance metrics
  Map<String, dynamic> getSearchMetrics() {
    return {
      'lastSearchQuery': _lastSearchQuery,
      'lastSearchTime': _lastSearchTime?.toIso8601String(),
      'totalResults': _totalResults,
      'currentPage': _currentPage,
      'hasMoreResults': _hasMoreResults,
      'activeFilterCount': _activeFilterCount,
      'recentSearchesCount': _recentSearches.length,
    };
  }

  /// Calculate distance between two points
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return _locationService.calculateDistance(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Helper methods for state management
  void _setLoading(bool loading) {
    _isLoading = loading;
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
    _debounceTimer?.cancel();
    super.dispose();
  }
}
