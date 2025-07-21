// lib/core/services/cache_service.dart

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nearby_pg/shared/models/app_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for caching data locally
class CacheService {
  // Using Hive for complex data structures
  late Box<dynamic> _userPreferencesBox;
  late Box<dynamic> _cachedDataBox;
  late Box<dynamic> _authBox;

  // Using SharedPreferences for simple key-value pairs
  late SharedPreferences _prefs;

  // Constants
  static const String _authTokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';

  // Initialization flag
  bool _isInitialized = false;

  /// Initialize cache service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize Hive
      await Hive.initFlutter();

      // Open Hive boxes
      _userPreferencesBox = await Hive.openBox('userPreferences');
      _cachedDataBox = await Hive.openBox('cachedData');
      _authBox = await Hive.openBox('auth');

      // Initialize SharedPreferences
      _prefs = await SharedPreferences.getInstance();

      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing cache service: $e');
      // Create fallback boxes for testing/development
      _handleInitializationError();
    }
  }

  /// Handle initialization errors by creating empty boxes
  void _handleInitializationError() {
    try {
      if (Hive.isBoxOpen('userPreferences')) {
        _userPreferencesBox = Hive.box('userPreferences');
      }
      if (Hive.isBoxOpen('cachedData')) {
        _cachedDataBox = Hive.box('cachedData');
      }
      if (Hive.isBoxOpen('auth')) {
        _authBox = Hive.box('auth');
      }
    } catch (e) {
      debugPrint('Error creating fallback boxes: $e');
    }
  }

  /// Ensure the cache service is initialized before any operation
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  /// Get recent searches
  Future<List<String>> getRecentSearches() async {
    await _ensureInitialized();

    try {
      final recentSearches = _userPreferencesBox.get('recentSearches');
      if (recentSearches != null && recentSearches is List) {
        return recentSearches.cast<String>();
      }
    } catch (e) {
      debugPrint('Error getting recent searches: $e');
    }

    return [];
  }

  /// Save recent searches
  Future<void> saveRecentSearches(List<String> searches) async {
    await _ensureInitialized();

    try {
      await _userPreferencesBox.put('recentSearches', searches);
    } catch (e) {
      debugPrint('Error saving recent searches: $e');
    }
  }

  /// Get saved search filters
  Future<dynamic> getSavedSearchFilters() async {
    await _ensureInitialized();

    try {
      return _userPreferencesBox.get('searchFilters');
    } catch (e) {
      debugPrint('Error getting saved search filters: $e');
    }

    return null;
  }

  /// Save search filters
  Future<void> saveSearchFilters(dynamic filters) async {
    await _ensureInitialized();

    try {
      await _userPreferencesBox.put('searchFilters', filters);
    } catch (e) {
      debugPrint('Error saving search filters: $e');
    }
  }

  /// Get wishlist
  Future<List<String>> getWishlist() async {
    await _ensureInitialized();

    try {
      final wishlist = _userPreferencesBox.get('wishlist');
      if (wishlist != null && wishlist is List) {
        return wishlist.cast<String>();
      }
    } catch (e) {
      debugPrint('Error getting cached wishlist: $e');
    }

    return [];
  }

  /// Save wishlist
  Future<void> saveWishlist(List<String> wishlist) async {
    await _ensureInitialized();

    try {
      await _userPreferencesBox.put('wishlist', wishlist);
    } catch (e) {
      debugPrint('Error saving wishlist: $e');
    }
  }

  /// Get user preference with generic type
  Future<T?> getUserPreference<T>(String key) async {
    await _ensureInitialized();

    try {
      final value = _userPreferencesBox.get(key);
      if (value != null) {
        return value as T?;
      }

      // Fallback to SharedPreferences
      if (_prefs.containsKey(key)) {
        final value = _prefs.get(key);
        if (value is T) {
          return value;
        }
      }
    } catch (e) {
      debugPrint('Error getting user preference: $e');
    }

    return null;
  }

  /// Save user preference with generic type
  Future<void> saveUserPreference<T>(String key, T value) async {
    await _ensureInitialized();

    try {
      await _userPreferencesBox.put(key, value);
    } catch (e) {
      debugPrint('Error saving user preference: $e');

      // Fallback to SharedPreferences
      try {
        if (value is String) {
          await _prefs.setString(key, value);
        } else if (value is int) {
          await _prefs.setInt(key, value);
        } else if (value is double) {
          await _prefs.setDouble(key, value);
        } else if (value is bool) {
          await _prefs.setBool(key, value);
        } else if (value is List<String>) {
          await _prefs.setStringList(key, value);
        }
      } catch (e) {
        debugPrint('Error saving to SharedPreferences: $e');
      }
    }
  }

  /// Get authentication token
  Future<String?> getAuthToken() async {
    await _ensureInitialized();

    try {
      final token = _authBox.get(_authTokenKey);
      if (token != null && token is String) {
        return token;
      }

      // Fallback to SharedPreferences
      return _prefs.getString(_authTokenKey);
    } catch (e) {
      debugPrint('Error getting auth token: $e');
    }

    return null;
  }

  /// Save authentication token
  Future<void> saveAuthToken(String token) async {
    await _ensureInitialized();

    try {
      await _authBox.put(_authTokenKey, token);

      // Also save to SharedPreferences as backup
      await _prefs.setString(_authTokenKey, token);
    } catch (e) {
      debugPrint('Error saving auth token: $e');
    }
  }

  /// Get user ID
  Future<String?> getUserId() async {
    await _ensureInitialized();

    try {
      final userId = _authBox.get(_userIdKey);
      if (userId != null && userId is String) {
        return userId;
      }

      // Fallback to SharedPreferences
      return _prefs.getString(_userIdKey);
    } catch (e) {
      debugPrint('Error getting user ID: $e');
    }

    return null;
  }

  /// Save user ID
  Future<void> saveUserId(String userId) async {
    await _ensureInitialized();

    try {
      await _authBox.put(_userIdKey, userId);

      // Also save to SharedPreferences as backup
      await _prefs.setString(_userIdKey, userId);
    } catch (e) {
      debugPrint('Error saving user ID: $e');
    }
  }

  /// Clear user data (used during logout)
  Future<void> clearUserData() async {
    await _ensureInitialized();

    try {
      // Clear auth data
      await _authBox.clear();

      // Clear auth data from SharedPreferences
      await _prefs.remove(_authTokenKey);
      await _prefs.remove(_userIdKey);

      // Optionally clear wishlist and other user-specific data
      // but keep app settings like theme, language, etc.
      await _userPreferencesBox.delete('wishlist');

      // Don't clear everything as some preferences should persist across logins
      // e.g., theme, language, onboarding status, etc.
    } catch (e) {
      debugPrint('Error clearing user data: $e');
    }
  }

  /// Set cached data
  Future<void> setCache<T>(
    String key,
    T data, {
    Duration? expiry,
    String? category,
  }) async {
    await _ensureInitialized();

    try {
      final cacheEntry = {
        'data': data,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'expiry': expiry?.inMilliseconds,
        'category': category,
      };

      await _cachedDataBox.put(key, cacheEntry);
    } catch (e) {
      debugPrint('Error setting cache: $e');
    }
  }

  /// Get cached data
  Future<T?> getCache<T>(String key) async {
    await _ensureInitialized();

    try {
      final cacheEntry = _cachedDataBox.get(key);
      if (cacheEntry == null) return null;

      // Check expiry
      final timestamp = cacheEntry['timestamp'] as int;
      final expiryMs = cacheEntry['expiry'] as int?;

      if (expiryMs != null) {
        final now = DateTime.now().millisecondsSinceEpoch;
        if (now - timestamp > expiryMs) {
          // Cache expired
          await _cachedDataBox.delete(key);
          return null;
        }
      }

      return cacheEntry['data'] as T?;
    } catch (e) {
      debugPrint('Error getting cache: $e');
    }

    return null;
  }

  /// Clear cache by category
  Future<void> clearCacheByCategory(String category) async {
    await _ensureInitialized();

    try {
      // Get all keys
      final keys = _cachedDataBox.keys.toList();

      // Filter and delete
      for (final key in keys) {
        final entry = _cachedDataBox.get(key);
        if (entry != null && entry['category'] == category) {
          await _cachedDataBox.delete(key);
        }
      }
    } catch (e) {
      debugPrint('Error clearing cache: $e');
    }
  }

  /// Clear all cache
  Future<void> clearAllCache() async {
    await _ensureInitialized();

    try {
      await _cachedDataBox.clear();
    } catch (e) {
      debugPrint('Error clearing all cache: $e');
    }
  }

  /// Clear expired cache entries
  Future<void> clearExpiredCache() async {
    await _ensureInitialized();

    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final keys = _cachedDataBox.keys.toList();

      for (final key in keys) {
        final entry = _cachedDataBox.get(key);
        if (entry != null && entry['expiry'] != null) {
          final timestamp = entry['timestamp'] as int;
          final expiryMs = entry['expiry'] as int;

          if (now - timestamp > expiryMs) {
            await _cachedDataBox.delete(key);
          }
        }
      }
    } catch (e) {
      debugPrint('Error clearing expired cache: $e');
    }
  }

  Future<List<String>> getCachedWishlist() async {
    await _ensureInitialized();

    try {
      final wishlist = _userPreferencesBox.get('wishlist');
      if (wishlist != null && wishlist is List<String>) {
        return wishlist;
      }

      return [];
    } catch (e) {
      debugPrint('Error getting cached wishlist: $e');
      return [];
    }
  }

  Future<void> cacheWishlist(List<String> wishlistedPGIds) async {
    await _ensureInitialized();

    try {
      await _userPreferencesBox.put('wishlist', wishlistedPGIds);
    } catch (e) {
      debugPrint('Error caching wishlist: $e');
    }
  }

  Future<void> cachePGs(List<PGProperty> pgList) async {
    await _ensureInitialized();

    try {
      await _cachedDataBox.put('pgList', pgList);
    } catch (e) {
      debugPrint('Error caching PGs: $e');
    }
  }

  bool isPGCacheValid() {
    try {
      final pgList = _cachedDataBox.get('pgList');
      if (pgList != null && pgList is List<PGProperty>) {
        return true;
      }
    } catch (e) {
      debugPrint('Error checking PG cache: $e');
    }

    return false;
  }

  Future getCachedPGs() async {
    await _ensureInitialized();

    try {
      final pgList = _cachedDataBox.get('pgList');
      if (pgList != null && pgList is List<PGProperty>) {
        return pgList;
      }
    } catch (e) {
      debugPrint('Error getting cached PGs: $e');
    }
  }

  Future<void> clearAllData() async {
    await _cachedDataBox.clear();
  }
}
