import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

// Import models and constants
import '../constants/app_constants.dart';
import '../../shared/models/app_models.dart';

/// Comprehensive caching service with Hive for local storage and offline support
class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  // Hive boxes
  Box? _cacheBox;
  Box? _userPreferencesBox;
  Box? _pgDataBox;
  Box? _searchHistoryBox;
  Box? _bookingCacheBox;
  Box? _imagesCacheBox;

  bool _isInitialized = false;

  /// Initialize cache service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize Hive if not already done
      if (!Hive.isAdapterRegistered(0)) {
        // Register adapters for custom types if needed
        _registerAdapters();
      }

      // Open boxes
      await _openBoxes();

      _isInitialized = true;
      debugPrint('CacheService initialized successfully');

      // Cleanup old cache entries
      await _cleanupExpiredEntries();
    } catch (e) {
      debugPrint('Failed to initialize CacheService: $e');
      rethrow;
    }
  }

  /// Register Hive adapters for custom types
  void _registerAdapters() {
    // TODO: Register adapters for custom models if needed
    // Hive.registerAdapter(PGPropertyAdapter());
    // For now, we'll use JSON serialization
  }

  /// Open all required Hive boxes
  Future<void> _openBoxes() async {
    _cacheBox = await Hive.openBox(AppConstants.cacheBox);
    _userPreferencesBox = await Hive.openBox(AppConstants.userPreferencesBox);
    _pgDataBox = await Hive.openBox('pg_data_cache');
    _searchHistoryBox = await Hive.openBox(AppConstants.searchHistoryBox);
    _bookingCacheBox = await Hive.openBox(AppConstants.bookingCacheBox);
    _imagesCacheBox = await Hive.openBox('images_cache');
  }

  /// Store cached data with expiry
  Future<void> setCache(
    String key,
    dynamic data, {
    Duration? expiry,
    String? category,
  }) async {
    await _ensureInitialized();

    final cacheEntry = CacheEntry(
      key: key,
      data: data,
      createdAt: DateTime.now(),
      expiresAt: expiry != null ? DateTime.now().add(expiry) : null,
      category: category,
    );

    await _cacheBox!.put(key, cacheEntry.toJson());
    debugPrint(
      'Cache stored: $key${expiry != null ? ' (expires in ${expiry.inMinutes}min)' : ''}',
    );
  }

  /// Get cached data
  Future<T?> getCache<T>(String key) async {
    await _ensureInitialized();

    final cacheData = _cacheBox!.get(key);
    if (cacheData == null) return null;

    final cacheEntry = CacheEntry.fromJson(
      Map<String, dynamic>.from(cacheData),
    );

    // Check if expired
    if (cacheEntry.isExpired) {
      await _cacheBox!.delete(key);
      debugPrint('Cache expired and removed: $key');
      return null;
    }

    return cacheEntry.data as T?;
  }

  /// Check if cache exists and is valid
  Future<bool> hasValidCache(String key) async {
    await _ensureInitialized();

    final cacheData = _cacheBox!.get(key);
    if (cacheData == null) return false;

    final cacheEntry = CacheEntry.fromJson(
      Map<String, dynamic>.from(cacheData),
    );
    return !cacheEntry.isExpired;
  }

  /// Remove cache entry
  Future<void> removeCache(String key) async {
    await _ensureInitialized();
    await _cacheBox!.delete(key);
    debugPrint('Cache removed: $key');
  }

  /// Clear all cache
  Future<void> clearAllCache() async {
    await _ensureInitialized();
    await _cacheBox!.clear();
    debugPrint('All cache cleared');
  }

  /// Clear cache by category
  Future<void> clearCacheByCategory(String category) async {
    await _ensureInitialized();

    final keysToDelete = <String>[];
    for (final key in _cacheBox!.keys) {
      final cacheData = _cacheBox!.get(key);
      if (cacheData != null) {
        final cacheEntry = CacheEntry.fromJson(
          Map<String, dynamic>.from(cacheData),
        );
        if (cacheEntry.category == category) {
          keysToDelete.add(key);
        }
      }
    }

    for (final key in keysToDelete) {
      await _cacheBox!.delete(key);
    }

    debugPrint(
      'Cache cleared for category: $category (${keysToDelete.length} entries)',
    );
  }

  /// Cache PG properties
  Future<void> cachePGs(List<PGProperty> pgs, {String? location}) async {
    await _ensureInitialized();

    final key = 'pgs_${location ?? 'all'}';
    final pgJsonList = pgs.map((pg) => pg.toJson()).toList();

    await _pgDataBox!.put(key, {
      'data': pgJsonList,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'location': location,
    });

    debugPrint(
      'Cached ${pgs.length} PG properties for location: ${location ?? 'all'}',
    );
  }

  /// Get cached PG properties
  Future<List<PGProperty>> getCachedPGs({String? location}) async {
    await _ensureInitialized();

    final key = 'pgs_${location ?? 'all'}';
    final cachedData = _pgDataBox!.get(key);

    if (cachedData == null) return [];

    try {
      final data = Map<String, dynamic>.from(cachedData);
      final timestamp = data['timestamp'] as int;
      final cacheAge = DateTime.now().millisecondsSinceEpoch - timestamp;

      // Check if cache is still valid (24 hours)
      if (cacheAge > AppConstants.cacheExpiry.inMilliseconds) {
        await _pgDataBox!.delete(key);
        return [];
      }

      final pgJsonList = List<Map<String, dynamic>>.from(data['data']);
      return pgJsonList.map((json) => PGProperty.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error reading cached PGs: $e');
      return [];
    }
  }

  /// Cache single PG property
  Future<void> cachePG(PGProperty pg) async {
    await _ensureInitialized();

    await _pgDataBox!.put('pg_${pg.id}', {
      'data': pg.toJson(),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    debugPrint('Cached PG: ${pg.name}');
  }

  /// Get cached PG property
  Future<PGProperty?> getCachedPG(String pgId) async {
    await _ensureInitialized();

    final cachedData = _pgDataBox!.get('pg_$pgId');
    if (cachedData == null) return null;

    try {
      final data = Map<String, dynamic>.from(cachedData);
      final timestamp = data['timestamp'] as int;
      final cacheAge = DateTime.now().millisecondsSinceEpoch - timestamp;

      // Check if cache is still valid (1 hour for individual PG)
      if (cacheAge > AppConstants.shortCacheExpiry.inMilliseconds) {
        await _pgDataBox!.delete('pg_$pgId');
        return null;
      }

      return PGProperty.fromJson(Map<String, dynamic>.from(data['data']));
    } catch (e) {
      debugPrint('Error reading cached PG: $e');
      return null;
    }
  }

  /// Save recent searches
  Future<void> saveRecentSearches(List<String> searches) async {
    await _ensureInitialized();

    await _searchHistoryBox!.put('recent_searches', {
      'data': searches,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    debugPrint('Saved ${searches.length} recent searches');
  }

  /// Get recent searches
  Future<List<String>> getRecentSearches() async {
    await _ensureInitialized();

    final cachedData = _searchHistoryBox!.get('recent_searches');
    if (cachedData == null) return [];

    try {
      final data = Map<String, dynamic>.from(cachedData);
      return List<String>.from(data['data']);
    } catch (e) {
      debugPrint('Error reading recent searches: $e');
      return [];
    }
  }

  /// Save search filters
  Future<void> saveSearchFilters(SearchFilter filters) async {
    await _ensureInitialized();

    await _userPreferencesBox!.put(AppConstants.keySearchFilters, {
      'data': filters.toJson(),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    debugPrint('Search filters saved');
  }

  /// Get saved search filters
  Future<SearchFilter?> getSavedSearchFilters() async {
    await _ensureInitialized();

    final cachedData = _userPreferencesBox!.get(AppConstants.keySearchFilters);
    if (cachedData == null) return null;

    try {
      final data = Map<String, dynamic>.from(cachedData);
      return SearchFilter.fromJson(Map<String, dynamic>.from(data['data']));
    } catch (e) {
      debugPrint('Error reading search filters: $e');
      return null;
    }
  }

  /// Cache user profile
  Future<void> cacheUserProfile(UserProfile profile) async {
    await _ensureInitialized();

    await _userPreferencesBox!.put(AppConstants.keyUserProfile, {
      'data': profile.toJson(),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    debugPrint('User profile cached');
  }

  /// Get cached user profile
  Future<UserProfile?> getCachedUserProfile() async {
    await _ensureInitialized();

    final cachedData = _userPreferencesBox!.get(AppConstants.keyUserProfile);
    if (cachedData == null) return null;

    try {
      final data = Map<String, dynamic>.from(cachedData);
      return UserProfile.fromJson(Map<String, dynamic>.from(data['data']));
    } catch (e) {
      debugPrint('Error reading user profile: $e');
      return null;
    }
  }

  /// Cache bookings
  Future<void> cacheBookings(List<Booking> bookings) async {
    await _ensureInitialized();

    final bookingJsonList =
        bookings.map((booking) => booking.toJson()).toList();

    await _bookingCacheBox!.put('user_bookings', {
      'data': bookingJsonList,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    debugPrint('Cached ${bookings.length} bookings');
  }

  /// Get cached bookings
  Future<List<Booking>> getCachedBookings() async {
    await _ensureInitialized();

    final cachedData = _bookingCacheBox!.get('user_bookings');
    if (cachedData == null) return [];

    try {
      final data = Map<String, dynamic>.from(cachedData);
      final timestamp = data['timestamp'] as int;
      final cacheAge = DateTime.now().millisecondsSinceEpoch - timestamp;

      // Check if cache is still valid (30 minutes for bookings)
      if (cacheAge > const Duration(minutes: 30).inMilliseconds) {
        await _bookingCacheBox!.delete('user_bookings');
        return [];
      }

      final bookingJsonList = List<Map<String, dynamic>>.from(data['data']);
      return bookingJsonList.map((json) => Booking.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error reading cached bookings: $e');
      return [];
    }
  }

  /// Cache wishlist
  Future<void> cacheWishlist(List<String> pgIds) async {
    await _ensureInitialized();

    await _userPreferencesBox!.put(AppConstants.keyWishlist, {
      'data': pgIds,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    debugPrint('Cached wishlist with ${pgIds.length} items');
  }

  /// Get cached wishlist
  Future<List<String>> getCachedWishlist() async {
    await _ensureInitialized();

    final cachedData = _userPreferencesBox!.get(AppConstants.keyWishlist);
    if (cachedData == null) return [];

    try {
      final data = Map<String, dynamic>.from(cachedData);
      return List<String>.from(data['data']);
    } catch (e) {
      debugPrint('Error reading wishlist: $e');
      return [];
    }
  }

  /// Cache image data
  Future<void> cacheImageData(String imageUrl, List<int> imageData) async {
    await _ensureInitialized();

    final key = _generateImageCacheKey(imageUrl);
    await _imagesCacheBox!.put(key, {
      'data': imageData,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'url': imageUrl,
    });

    debugPrint('Cached image: $imageUrl');
  }

  /// Get cached image data
  Future<List<int>?> getCachedImageData(String imageUrl) async {
    await _ensureInitialized();

    final key = _generateImageCacheKey(imageUrl);
    final cachedData = _imagesCacheBox!.get(key);
    if (cachedData == null) return null;

    try {
      final data = Map<String, dynamic>.from(cachedData);
      final timestamp = data['timestamp'] as int;
      final cacheAge = DateTime.now().millisecondsSinceEpoch - timestamp;

      // Check if cache is still valid (7 days for images)
      if (cacheAge > AppConstants.longCacheExpiry.inMilliseconds) {
        await _imagesCacheBox!.delete(key);
        return null;
      }

      return List<int>.from(data['data']);
    } catch (e) {
      debugPrint('Error reading cached image: $e');
      return null;
    }
  }

  /// Cleanup expired cache entries
  Future<void> _cleanupExpiredEntries() async {
    await _ensureInitialized();

    int removedCount = 0;

    // Cleanup main cache
    final keysToDelete = <String>[];
    for (final key in _cacheBox!.keys) {
      final cacheData = _cacheBox!.get(key);
      if (cacheData != null) {
        try {
          final cacheEntry = CacheEntry.fromJson(
            Map<String, dynamic>.from(cacheData),
          );
          if (cacheEntry.isExpired) {
            keysToDelete.add(key);
          }
        } catch (e) {
          // Remove corrupted entries
          keysToDelete.add(key);
        }
      }
    }

    for (final key in keysToDelete) {
      await _cacheBox!.delete(key);
      removedCount++;
    }

    // Cleanup image cache (remove old images)
    await _cleanupOldImages();

    if (removedCount > 0) {
      debugPrint('Cleaned up $removedCount expired cache entries');
    }
  }

  /// Cleanup old images to manage storage
  Future<void> _cleanupOldImages() async {
    await _ensureInitialized();

    final allImages = _imagesCacheBox!.keys.toList();
    if (allImages.length <= 100) return; // Keep max 100 images

    // Sort by timestamp and remove oldest
    final imageData = <String, int>{};
    for (final key in allImages) {
      final data = _imagesCacheBox!.get(key);
      if (data is Map) {
        imageData[key] = data['timestamp'] ?? 0;
      }
    }

    final sortedKeys =
        imageData.keys.toList()
          ..sort((a, b) => imageData[a]!.compareTo(imageData[b]!));

    // Remove oldest 20 images
    final toRemove = sortedKeys.take(20);
    for (final key in toRemove) {
      await _imagesCacheBox!.delete(key);
    }

    debugPrint('Cleaned up ${toRemove.length} old cached images');
  }

  /// Generate cache key for images
  String _generateImageCacheKey(String imageUrl) {
    return 'img_${imageUrl.hashCode.abs()}';
  }

  /// Get cache statistics
  Future<CacheStatistics> getCacheStatistics() async {
    await _ensureInitialized();

    final mainCacheSize = _cacheBox!.length;
    final pgDataSize = _pgDataBox!.length;
    final imagesCacheSize = _imagesCacheBox!.length;
    final searchHistorySize = _searchHistoryBox!.length;
    final bookingCacheSize = _bookingCacheBox!.length;

    // Calculate total storage size (approximate)
    int totalStorageBytes = 0;
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final hiveDir = Directory('${appDir.path}/hive');
      if (await hiveDir.exists()) {
        await for (final file in hiveDir.list()) {
          if (file is File) {
            totalStorageBytes += await file.length();
          }
        }
      }
    } catch (e) {
      debugPrint('Error calculating storage size: $e');
    }

    return CacheStatistics(
      mainCacheEntries: mainCacheSize,
      pgDataEntries: pgDataSize,
      imagesCacheEntries: imagesCacheSize,
      searchHistoryEntries: searchHistorySize,
      bookingCacheEntries: bookingCacheSize,
      totalStorageBytes: totalStorageBytes,
    );
  }

  /// Ensure service is initialized
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  /// Get user preference
  Future<T?> getUserPreference<T>(String key) async {
    await _ensureInitialized();
    return _userPreferencesBox!.get(key) as T?;
  }

  /// Set user preference
  Future<void> setUserPreference<T>(String key, T value) async {
    await _ensureInitialized();
    await _userPreferencesBox!.put(key, value);
  }

  /// Clear all user data (for logout)
  Future<void> clearUserData() async {
    await _ensureInitialized();

    await _userPreferencesBox!.clear();
    await _bookingCacheBox!.clear();
    await _searchHistoryBox!.clear();

    // Clear user-specific cache entries
    await clearCacheByCategory('user');

    debugPrint('All user data cleared');
  }

  /// Export cache for debugging
  Future<Map<String, dynamic>> exportCacheData() async {
    await _ensureInitialized();

    return {
      'mainCache': _cacheBox!.toMap(),
      'userPreferences': _userPreferencesBox!.toMap(),
      'pgData': _pgDataBox!.toMap(),
      'searchHistory': _searchHistoryBox!.toMap(),
      'bookingCache': _bookingCacheBox!.toMap(),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Dispose and close all boxes
  Future<void> dispose() async {
    await _cacheBox?.close();
    await _userPreferencesBox?.close();
    await _pgDataBox?.close();
    await _searchHistoryBox?.close();
    await _bookingCacheBox?.close();
    await _imagesCacheBox?.close();
    debugPrint('CacheService disposed');
  }
}

/// Cache entry model
class CacheEntry {
  final String key;
  final dynamic data;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final String? category;

  const CacheEntry({
    required this.key,
    required this.data,
    required this.createdAt,
    this.expiresAt,
    this.category,
  });

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  Duration get age => DateTime.now().difference(createdAt);

  Duration? get timeToExpiry {
    if (expiresAt == null) return null;
    final ttl = expiresAt!.difference(DateTime.now());
    return ttl.isNegative ? null : ttl;
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'data': data,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'category': category,
    };
  }

  factory CacheEntry.fromJson(Map<String, dynamic> json) {
    return CacheEntry(
      key: json['key'],
      data: json['data'],
      createdAt: DateTime.parse(json['createdAt']),
      expiresAt:
          json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
      category: json['category'],
    );
  }
}

/// Cache statistics model
class CacheStatistics {
  final int mainCacheEntries;
  final int pgDataEntries;
  final int imagesCacheEntries;
  final int searchHistoryEntries;
  final int bookingCacheEntries;
  final int totalStorageBytes;

  const CacheStatistics({
    required this.mainCacheEntries,
    required this.pgDataEntries,
    required this.imagesCacheEntries,
    required this.searchHistoryEntries,
    required this.bookingCacheEntries,
    required this.totalStorageBytes,
  });

  int get totalEntries {
    return mainCacheEntries +
        pgDataEntries +
        imagesCacheEntries +
        searchHistoryEntries +
        bookingCacheEntries;
  }

  String get formattedStorageSize {
    if (totalStorageBytes < 1024) {
      return '${totalStorageBytes}B';
    } else if (totalStorageBytes < 1024 * 1024) {
      return '${(totalStorageBytes / 1024).toStringAsFixed(1)}KB';
    } else {
      return '${(totalStorageBytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'mainCacheEntries': mainCacheEntries,
      'pgDataEntries': pgDataEntries,
      'imagesCacheEntries': imagesCacheEntries,
      'searchHistoryEntries': searchHistoryEntries,
      'bookingCacheEntries': bookingCacheEntries,
      'totalStorageBytes': totalStorageBytes,
      'totalEntries': totalEntries,
      'formattedStorageSize': formattedStorageSize,
    };
  }
}
