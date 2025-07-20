import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

// Import models and services
import '../../../shared/models/app_models.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/cache_service.dart';

/// Profile screen state management
class ProfileProvider extends ChangeNotifier {
  // Services
  final ApiService _apiService = ApiService();
  final CacheService _cacheService = CacheService();
  final ImagePicker _imagePicker = ImagePicker();

  // State variables
  bool _isLoading = false;
  bool _isUpdating = false;
  bool _hasError = false;
  String _errorMessage = '';

  // User data
  UserProfile? _userProfile;
  List<Booking> _userBookings = [];
  List<String> _wishlistPGIds = [];
  List<PGProperty> _wishlistPGs = [];

  // Profile statistics
  ProfileStats _profileStats = ProfileStats();

  // Settings
  AppSettings _appSettings = const AppSettings();

  // Image handling
  File? _selectedProfileImage;
  bool _isUploadingImage = false;

  // Getters
  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;

  UserProfile? get userProfile => _userProfile;
  List<Booking> get userBookings => _userBookings;
  List<String> get wishlistPGIds => _wishlistPGIds;
  List<PGProperty> get wishlistPGs => _wishlistPGs;
  ProfileStats get profileStats => _profileStats;
  AppSettings get appSettings => _appSettings;

  File? get selectedProfileImage => _selectedProfileImage;
  bool get isUploadingImage => _isUploadingImage;

  bool get isAuthenticated => _apiService.isAuthenticated;
  bool get hasProfile => _userProfile != null;
  bool get isProfileComplete => _userProfile?.isProfileComplete ?? false;

  /// Initialize profile data
  Future<void> initialize() async {
    if (!isAuthenticated) return;

    _setLoading(true);
    _clearError();

    try {
      // Load cached data first for fast UI
      await _loadCachedData();

      // Load fresh data from API
      await Future.wait([
        _loadUserProfile(),
        _loadUserBookings(),
        _loadWishlist(),
        _loadAppSettings(),
      ]);

      // Calculate statistics
      _calculateProfileStats();
    } catch (e) {
      _setError('Failed to load profile: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Load cached profile data
  Future<void> _loadCachedData() async {
    try {
      final cachedProfile = await _cacheService.getCachedUserProfile();
      if (cachedProfile != null) {
        _userProfile = cachedProfile;
        notifyListeners();
      }

      final cachedBookings = await _cacheService.getCachedBookings();
      if (cachedBookings.isNotEmpty) {
        _userBookings = cachedBookings;
        notifyListeners();
      }

      final cachedWishlist = await _cacheService.getCachedWishlist();
      if (cachedWishlist.isNotEmpty) {
        _wishlistPGIds = cachedWishlist;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading cached data: $e');
    }
  }

  /// Load user profile from API
  Future<void> _loadUserProfile() async {
    try {
      final response = await _apiService.get(AppConstants.userProfileEndpoint);
      _userProfile = UserProfile.fromJson(response['data']);

      // Cache the profile
      await _cacheService.cacheUserProfile(_userProfile!);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user profile: $e');
      // Keep cached data if API fails
    }
  }

  /// Load user bookings
  Future<void> _loadUserBookings() async {
    try {
      final response = await _apiService.get(
        AppConstants.bookingHistoryEndpoint,
      );
      _userBookings =
          (response['data'] as List)
              .map((json) => Booking.fromJson(json))
              .toList();

      // Cache bookings
      await _cacheService.cacheBookings(_userBookings);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading bookings: $e');
    }
  }

  /// Load wishlist
  Future<void> _loadWishlist() async {
    try {
      final response = await _apiService.get(AppConstants.wishlistEndpoint);
      _wishlistPGIds = List<String>.from(response['data']['pgIds'] ?? []);

      // Load wishlist PG details
      if (_wishlistPGIds.isNotEmpty) {
        await _loadWishlistPGDetails();
      }

      // Cache wishlist
      await _cacheService.cacheWishlist(_wishlistPGIds);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading wishlist: $e');
    }
  }

  /// Load wishlist PG details
  Future<void> _loadWishlistPGDetails() async {
    try {
      final pgDetails = <PGProperty>[];

      for (final pgId in _wishlistPGIds) {
        // Try cache first
        var pg = await _cacheService.getCachedPG(pgId);

        if (pg == null) {
          // Fetch from API
          final response = await _apiService.get(
            '${AppConstants.pgDetailEndpoint}/$pgId',
          );
          pg = PGProperty.fromJson(response['data']);

          // Cache the PG
          await _cacheService.cachePG(pg);
        }

        pgDetails.add(pg);
      }

      _wishlistPGs = pgDetails;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading wishlist PG details: $e');
    }
  }

  /// Load app settings
  Future<void> _loadAppSettings() async {
    try {
      // Load from cache/preferences
      final themeMode =
          await _cacheService.getUserPreference<String>('theme_mode') ??
          'system';
      final notifications =
          await _cacheService.getUserPreference<bool>(
            'notifications_enabled',
          ) ??
          true;
      final locationTracking =
          await _cacheService.getUserPreference<bool>('location_tracking') ??
          true;
      final emailNotifications =
          await _cacheService.getUserPreference<bool>('email_notifications') ??
          true;
      final smsNotifications =
          await _cacheService.getUserPreference<bool>('sms_notifications') ??
          false;

      _appSettings = AppSettings(
        themeMode: themeMode,
        notificationsEnabled: notifications,
        locationTrackingEnabled: locationTracking,
        emailNotificationsEnabled: emailNotifications,
        smsNotificationsEnabled: smsNotifications,
      );

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading app settings: $e');
    }
  }

  /// Update user profile
  Future<bool> updateProfile(UserProfile updatedProfile) async {
    _setUpdating(true);
    _clearError();

    try {
      final response = await _apiService.put(
        AppConstants.updateProfileEndpoint,
        data: updatedProfile.toJson(),
      );

      _userProfile = UserProfile.fromJson(response['data']);

      // Update cache
      await _cacheService.cacheUserProfile(_userProfile!);

      // Recalculate stats
      _calculateProfileStats();

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update profile: ${e.toString()}');
      return false;
    } finally {
      _setUpdating(false);
    }
  }

  /// Upload profile picture
  Future<bool> uploadProfilePicture(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (pickedFile == null) return false;

      _selectedProfileImage = File(pickedFile.path);
      _isUploadingImage = true;
      notifyListeners();

      // Upload to server
      final response = await _apiService.uploadFile(
        '/user/upload-avatar',
        pickedFile.path,
        fieldName: 'avatar',
      );

      // Update profile with new image URL
      if (_userProfile != null) {
        final updatedProfile = _userProfile!.copyWith(
          profilePicture: response['data']['imageUrl'],
        );

        _userProfile = updatedProfile;
        await _cacheService.cacheUserProfile(_userProfile!);
        notifyListeners();
      }

      return true;
    } catch (e) {
      _setError('Failed to upload image: ${e.toString()}');
      return false;
    } finally {
      _selectedProfileImage = null;
      _isUploadingImage = false;
      notifyListeners();
    }
  }

  /// Toggle wishlist item
  Future<bool> toggleWishlist(String pgId) async {
    try {
      final isCurrentlyWishlisted = _wishlistPGIds.contains(pgId);

      if (isCurrentlyWishlisted) {
        // Remove from wishlist
        await _apiService.delete(
          '${AppConstants.removeFromWishlistEndpoint}/$pgId',
        );
        _wishlistPGIds.remove(pgId);
        _wishlistPGs.removeWhere((pg) => pg.id == pgId);
      } else {
        // Add to wishlist
        await _apiService.post(
          AppConstants.addToWishlistEndpoint,
          data: {'pgId': pgId},
        );
        _wishlistPGIds.add(pgId);

        // Load PG details
        final pg = await _cacheService.getCachedPG(pgId);
        if (pg != null) {
          _wishlistPGs.add(pg);
        }
      }

      // Update cache
      await _cacheService.cacheWishlist(_wishlistPGIds);

      // Recalculate stats
      _calculateProfileStats();

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update wishlist: ${e.toString()}');
      return false;
    }
  }

  /// Update app settings
  Future<void> updateAppSettings(AppSettings newSettings) async {
    try {
      _appSettings = newSettings;

      // Save to cache/preferences
      await _cacheService.setUserPreference(
        'theme_mode',
        newSettings.themeMode,
      );
      await _cacheService.setUserPreference(
        'notifications_enabled',
        newSettings.notificationsEnabled,
      );
      await _cacheService.setUserPreference(
        'location_tracking',
        newSettings.locationTrackingEnabled,
      );
      await _cacheService.setUserPreference(
        'email_notifications',
        newSettings.emailNotificationsEnabled,
      );
      await _cacheService.setUserPreference(
        'sms_notifications',
        newSettings.smsNotificationsEnabled,
      );

      notifyListeners();
    } catch (e) {
      debugPrint('Error updating settings: $e');
    }
  }

  /// Delete user account
  Future<bool> deleteAccount() async {
    try {
      await _apiService.delete('/user/account');

      // Clear all user data
      await logout();

      return true;
    } catch (e) {
      _setError('Failed to delete account: ${e.toString()}');
      return false;
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      // Call logout API
      await _apiService.post(AppConstants.logoutEndpoint);
    } catch (e) {
      debugPrint('Logout API error: $e');
    } finally {
      // Clear local data regardless of API success
      await _apiService.clearAuthToken();
      await _cacheService.clearUserData();

      // Reset state
      _userProfile = null;
      _userBookings.clear();
      _wishlistPGIds.clear();
      _wishlistPGs.clear();
      _profileStats = ProfileStats();
      _selectedProfileImage = null;

      notifyListeners();
    }
  }

  /// Calculate profile statistics
  void _calculateProfileStats() {
    if (_userProfile == null) return;

    final now = DateTime.now();
    final totalBookings = _userBookings.length;
    final activeBookings = _userBookings.where((b) => b.isActive).length;
    final completedBookings =
        _userBookings.where((b) => b.status == BookingStatus.checkedOut).length;
    final totalSpent = _userBookings.fold<double>(
      0,
      (sum, b) => sum + b.totalAmount,
    );
    final memberSince = _userProfile!.createdAt;
    final wishlistCount = _wishlistPGIds.length;

    // Calculate loyalty tier
    String loyaltyTier = 'Bronze';
    if (totalBookings >= 10) {
      loyaltyTier = 'Gold';
    } else if (totalBookings >= 5) {
      loyaltyTier = 'Silver';
    }

    _profileStats = ProfileStats(
      totalBookings: totalBookings,
      activeBookings: activeBookings,
      completedBookings: completedBookings,
      totalSpent: totalSpent,
      memberSince: memberSince,
      wishlistCount: wishlistCount,
      loyaltyTier: loyaltyTier,
      profileCompletionPercentage: _calculateProfileCompletion(),
    );

    notifyListeners();
  }

  /// Calculate profile completion percentage
  int _calculateProfileCompletion() {
    if (_userProfile == null) return 0;

    int completedFields = 0;
    const totalFields = 10;

    if (_userProfile!.name.isNotEmpty) completedFields++;
    if (_userProfile!.email.isNotEmpty) completedFields++;
    if (_userProfile!.phone.isNotEmpty) completedFields++;
    if (_userProfile!.profilePicture?.isNotEmpty == true) completedFields++;
    if (_userProfile!.dateOfBirth != null) completedFields++;
    if (_userProfile!.gender?.isNotEmpty == true) completedFields++;
    if (_userProfile!.currentLocation.isNotEmpty) completedFields++;
    if (_userProfile!.preferredLocation.isNotEmpty) completedFields++;
    if (_userProfile!.budgetMin > 0 && _userProfile!.budgetMax > 0) {
      completedFields++;
    }
    if (_userProfile!.preferredAmenities.isNotEmpty) completedFields++;

    return ((completedFields / totalFields) * 100).round();
  }

  /// Get user's active booking
  Booking? get activeBooking {
    try {
      return _userBookings.firstWhere((booking) => booking.isActive);
    } catch (e) {
      return null;
    }
  }

  /// Get recent bookings
  List<Booking> get recentBookings {
    final sorted = List<Booking>.from(_userBookings);
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.take(3).toList();
  }

  /// Check if PG is in wishlist
  bool isPGInWishlist(String pgId) {
    return _wishlistPGIds.contains(pgId);
  }

  /// Refresh profile data
  Future<void> refresh() async {
    await initialize();
  }

  /// Helper methods for state management
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setUpdating(bool updating) {
    _isUpdating = updating;
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

/// Profile statistics model
class ProfileStats {
  final int totalBookings;
  final int activeBookings;
  final int completedBookings;
  final double totalSpent;
  final DateTime memberSince;
  final int wishlistCount;
  final String loyaltyTier;
  final int profileCompletionPercentage;

  ProfileStats({
    this.totalBookings = 0,
    this.activeBookings = 0,
    this.completedBookings = 0,
    this.totalSpent = 0.0,
    DateTime? memberSince,
    this.wishlistCount = 0,
    this.loyaltyTier = 'Bronze',
    this.profileCompletionPercentage = 0,
  }) : memberSince = memberSince ?? _defaultDate;

  static final DateTime _defaultDate = DateTime.now();

  String get formattedTotalSpent =>
      '${AppConstants.currency}${totalSpent.toInt()}';

  String get memberSinceFormatted {
    final now = DateTime.now();
    final difference = now.difference(memberSince);

    if (difference.inDays < 30) {
      return '${difference.inDays} days';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()} months';
    } else {
      return '${(difference.inDays / 365).floor()} years';
    }
  }

  Color get loyaltyTierColor {
    switch (loyaltyTier.toLowerCase()) {
      case 'gold':
        return const Color(0xFFFFD700);
      case 'silver':
        return const Color(0xFFC0C0C0);
      default:
        return const Color(0xFFCD7F32); // Bronze
    }
  }
}

/// App settings model
class AppSettings {
  final String themeMode; // 'light', 'dark', 'system'
  final bool notificationsEnabled;
  final bool locationTrackingEnabled;
  final bool emailNotificationsEnabled;
  final bool smsNotificationsEnabled;
  final String language;
  final String currency;

  const AppSettings({
    this.themeMode = 'system',
    this.notificationsEnabled = true,
    this.locationTrackingEnabled = true,
    this.emailNotificationsEnabled = true,
    this.smsNotificationsEnabled = false,
    this.language = 'en',
    this.currency = 'INR',
  });

  AppSettings copyWith({
    String? themeMode,
    bool? notificationsEnabled,
    bool? locationTrackingEnabled,
    bool? emailNotificationsEnabled,
    bool? smsNotificationsEnabled,
    String? language,
    String? currency,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      locationTrackingEnabled:
          locationTrackingEnabled ?? this.locationTrackingEnabled,
      emailNotificationsEnabled:
          emailNotificationsEnabled ?? this.emailNotificationsEnabled,
      smsNotificationsEnabled:
          smsNotificationsEnabled ?? this.smsNotificationsEnabled,
      language: language ?? this.language,
      currency: currency ?? this.currency,
    );
  }
}
