// lib/core/services/cache_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import '../../shared/models/app_models.dart';

/// Service for caching data and user preferences
class CacheService {
  late final Box _cacheBox;
  late final Box _userPreferencesBox;
  late final Box _searchHistoryBox;
  late final Box _pgDataCache;
  late final Box _bookingCacheBox;
  late SharedPreferences _prefs;

  /// Initialize the cache service
  Future<void> initialize() async {
    try {
      _cacheBox = Hive.box(AppConstants.cacheBox);
      _userPreferencesBox = Hive.box(AppConstants.userPreferencesBox);
      _searchHistoryBox = Hive.box(AppConstants.searchHistoryBox);
      _pgDataCache = Hive.box('pg_data_cache');
      _bookingCacheBox = Hive.box(AppConstants.bookingCacheBox);
      _prefs = await SharedPreferences.getInstance();

      debugPrint('✅ Cache service initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing cache service: $e');
    }
  }

  /// Clear all cached data
  Future<void> clearCache() async {
    try {
      await _cacheBox.clear();
      await _pgDataCache.clear();
      await _bookingCacheBox.clear();
      debugPrint('✅ Cache cleared successfully');
    } catch (e) {
      debugPrint('❌ Error clearing cache: $e');
    }
  }

  /// Clear user data (for logout)
  Future<void> clearUserData() async {
    try {
      await _userPreferencesBox.clear();
      await _prefs.remove('auth_token');
      await _prefs.remove('user_id');
      debugPrint('✅ User data cleared successfully');
    } catch (e) {
      debugPrint('❌ Error clearing user data: $e');
    }
  }

  // PG Caching Methods

  /// Cache a list of PG properties
  Future<void> cachePGs(List<PGProperty> pgs) async {
    try {
      // Store in Hive box
      await _pgDataCache.put('pg_list', pgs.map((pg) => pg.toJson()).toList());

      // Cache individual PGs for quick access
      for (final pg in pgs) {
        await cachePG(pg);
      }

      // Update cache timestamp
      await _cacheBox.put(
        'pg_list_timestamp',
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      debugPrint('❌ Error caching PGs: $e');
    }
  }

  /// Cache a single PG property
  Future<void> cachePG(PGProperty pg) async {
    try {
      await _pgDataCache.put('pg_${pg.id}', pg.toJson());
    } catch (e) {
      debugPrint('❌ Error caching PG: $e');
    }
  }

  /// Get cached PG list
  Future<List<PGProperty>> getCachedPGs() async {
    try {
      final cached = _pgDataCache.get('pg_list');
      if (cached == null) {
        return [];
      }

      return (cached as List).map((json) => PGProperty.fromJson(json)).toList();
    } catch (e) {
      debugPrint('❌ Error getting cached PGs: $e');
      return [];
    }
  }

  /// Get a cached PG by ID
  Future<PGProperty?> getCachedPG(String pgId) async {
    try {
      final cached = _pgDataCache.get('pg_$pgId');
      if (cached == null) {
        return null;
      }

      return PGProperty.fromJson(cached);
    } catch (e) {
      debugPrint('❌ Error getting cached PG: $e');
      return null;
    }
  }

  /// Check if PG list cache is valid (not expired)
  bool isPGCacheValid() {
    final timestamp = _cacheBox.get('pg_list_timestamp');
    if (timestamp == null) {
      return false;
    }

    final cacheDuration = DateTime.now().millisecondsSinceEpoch - timestamp;
    return cacheDuration < AppConstants.pgCacheValidityDuration.inMilliseconds;
  }

  // Search History Methods

  /// Save a search query to history
  Future<void> saveSearchQuery(String query) async {
    try {
      if (query.trim().isEmpty) {
        return;
      }

      List<String> searches = await getRecentSearches();

      // Remove if already exists
      searches.removeWhere((item) => item.toLowerCase() == query.toLowerCase());

      // Add to the beginning
      searches.insert(0, query);

      // Keep only the latest N searches
      if (searches.length > AppConstants.maxRecentSearches) {
        searches = searches.sublist(0, AppConstants.maxRecentSearches);
      }

      await _searchHistoryBox.put('recent_searches', searches);
    } catch (e) {
      debugPrint('❌ Error saving search query: $e');
    }
  }

  /// Get recent search queries
  Future<List<String>> getRecentSearches() async {
    try {
      final searches = _searchHistoryBox.get('recent_searches');
      if (searches == null) {
        return [];
      }

      return List<String>.from(searches);
    } catch (e) {
      debugPrint('❌ Error getting recent searches: $e');
      return [];
    }
  }

  /// Clear search history
  Future<void> clearSearchHistory() async {
    try {
      await _searchHistoryBox.put('recent_searches', []);
    } catch (e) {
      debugPrint('❌ Error clearing search history: $e');
    }
  }

  /// Save search filters
  Future<void> saveSearchFilters(SearchFilter filters) async {
    try {
      await _userPreferencesBox.put('search_filters', filters.toJson());
    } catch (e) {
      debugPrint('❌ Error saving search filters: $e');
    }
  }

  /// Get saved search filters
  Future<SearchFilter?> getSavedSearchFilters() async {
    try {
      final filters = _userPreferencesBox.get('search_filters');
      if (filters != null) {
        return SearchFilter.fromJson(Map<String, dynamic>.from(filters));
      }
    } catch (e) {
      debugPrint('❌ Error getting saved search filters: $e');
    }
    return null;
  }

  /// Cache data with expiry
  Future<void> setCache<T>(
    String key,
    T data, {
    Duration? expiry,
    String? category,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final expiryTimestamp =
          expiry != null ? timestamp + expiry.inMilliseconds : null;

      await _cacheBox.put(key, {
        'data': data,
        'timestamp': timestamp,
        'expiry': expiryTimestamp,
        'category': category,
      });
    } catch (e) {
      debugPrint('❌ Error setting cache: $e');
    }
  }

  /// Get cached data
  Future<T?> getCache<T>(String key) async {
    try {
      final cached = _cacheBox.get(key);
      if (cached == null) return null;

      final expiryTimestamp = cached['expiry'];
      if (expiryTimestamp != null) {
        final now = DateTime.now().millisecondsSinceEpoch;
        if (now > expiryTimestamp) {
          // Cache expired
          await _cacheBox.delete(key);
          return null;
        }
      }

      return cached['data'] as T;
    } catch (e) {
      debugPrint('❌ Error getting cache: $e');
      return null;
    }
  }

  // User Preferences Methods

  /// Save a user preference
  Future<void> saveUserPreference<T>(String key, T value) async {
    try {
      await _userPreferencesBox.put(key, value);
    } catch (e) {
      debugPrint('❌ Error saving user preference: $e');
    }
  }

  /// Get a user preference
  Future<T?> getUserPreference<T>(String key) async {
    try {
      return _userPreferencesBox.get(key) as T?;
    } catch (e) {
      debugPrint('❌ Error getting user preference: $e');
      return null;
    }
  }

  // Authentication Methods

  /// Save authentication token
  Future<void> saveAuthToken(String token) async {
    try {
      await _prefs.setString('auth_token', token);
    } catch (e) {
      debugPrint('❌ Error saving auth token: $e');
    }
  }

  /// Get authentication token
  Future<String?> getAuthToken() async {
    try {
      return _prefs.getString('auth_token');
    } catch (e) {
      debugPrint('❌ Error getting auth token: $e');
      return null;
    }
  }

  /// Save user ID
  Future<void> saveUserId(String userId) async {
    try {
      await _prefs.setString('user_id', userId);
    } catch (e) {
      debugPrint('❌ Error saving user ID: $e');
    }
  }

  /// Get user ID
  Future<String?> getUserId() async {
    try {
      return _prefs.getString('user_id');
    } catch (e) {
      debugPrint('❌ Error getting user ID: $e');
      return null;
    }
  }

  // Booking Methods

  /// Cache user bookings
  Future<void> cacheBookings(List<Booking> bookings) async {
    try {
      await _bookingCacheBox.put(
        'user_bookings',
        bookings.map((booking) => booking.toJson()).toList(),
      );
      await _bookingCacheBox.put(
        'bookings_timestamp',
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      debugPrint('❌ Error caching bookings: $e');
    }
  }

  /// Get cached bookings
  Future<List<Booking>> getCachedBookings() async {
    try {
      final cached = _bookingCacheBox.get('user_bookings');
      if (cached == null) {
        return [];
      }

      return (cached as List).map((json) => Booking.fromJson(json)).toList();
    } catch (e) {
      debugPrint('❌ Error getting cached bookings: $e');
      return [];
    }
  }

  // Wishlist Methods

  /// Cache wishlist
  Future<void> cacheWishlist(List<String> pgIds) async {
    try {
      await _userPreferencesBox.put('wishlist', pgIds);
    } catch (e) {
      debugPrint('❌ Error caching wishlist: $e');
    }
  }

  /// Get cached wishlist
  Future<List<String>> getCachedWishlist() async {
    try {
      final cached = _userPreferencesBox.get('wishlist');
      if (cached == null) {
        return [];
      }

      return List<String>.from(cached);
    } catch (e) {
      debugPrint('❌ Error getting cached wishlist: $e');
      return [];
    }
  }

  Future<void> saveRecentSearches(List<String> recentSearches) async {
    try {
      await _userPreferencesBox.put('recent_searches', recentSearches);
    } catch (e) {
      debugPrint('❌ Error saving recent searches: $e');
    }
  }
}
