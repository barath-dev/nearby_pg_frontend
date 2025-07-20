// lib/features/profile/providers/profile_provider.dart
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
  bool get isProfileComplete => _userProfile != null;

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
      // Since this is a minimal implementation, we'll use mock data
      _loadMockProfile();
      _loadMockBookings();
      _loadMockWishlist();

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading cached data: $e');
    }
  }

  /// Load mock profile data for demo
  void _loadMockProfile() {
    _userProfile = UserProfile(
      userId: 'user123',
      name: 'John Doe',
      email: 'john.doe@example.com',
      phone: '9876543210',
      profilePicture: 'https://i.pravatar.cc/300',
      occupationType: 'PROFESSIONAL',
      currentLocation: 'Delhi',
      preferredLocation: 'Noida',
      budgetMin: 8000,
      budgetMax: 15000,
      preferredAmenities: ['WIFI', 'AC', 'MEALS'],
      genderPreference: 'ANY',
      prefersMeals: true,
      preferredRoomTypes: ['SINGLE', 'DOUBLE'],
      isVerified: true,
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      updatedAt: DateTime.now(),
    );
  }

  /// Load mock bookings for demo
  void _loadMockBookings() {
    _userBookings = [
      Booking(
        bookingId: 'booking123',
        pgPropertyId: 'pg123',
        userId: 'user123',
        roomType: 'SINGLE',
        checkInDate: DateTime.now().subtract(const Duration(days: 30)),
        monthlyRent: 12000,
        securityDeposit: 12000,
        additionalFees: 1000,
        totalAmount: 25000,
        status: 'CONFIRMED',
        createdAt: DateTime.now().subtract(const Duration(days: 35)),
        updatedAt: DateTime.now().subtract(const Duration(days: 35)),
        pgName: 'Green Valley PG',
        pgAddress: 'Sector 18, Noida',
        pgImage:
            'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=400',
      ),
      Booking(
        bookingId: 'booking456',
        pgPropertyId: 'pg456',
        userId: 'user123',
        roomType: 'DOUBLE',
        checkInDate: DateTime.now().subtract(const Duration(days: 90)),
        checkOutDate: DateTime.now().subtract(const Duration(days: 30)),
        monthlyRent: 10000,
        securityDeposit: 10000,
        additionalFees: 500,
        totalAmount: 20500,
        status: 'CHECKED_OUT',
        createdAt: DateTime.now().subtract(const Duration(days: 95)),
        updatedAt: DateTime.now().subtract(const Duration(days: 30)),
        pgName: 'Comfort PG',
        pgAddress: 'Sector 62, Noida',
        pgImage:
            'https://images.unsplash.com/photo-1555854877-bab0e655b6f0?w=400',
      ),
    ];
  }

  /// Load mock wishlist for demo
  void _loadMockWishlist() {
    _wishlistPGIds = ['pg123', 'pg456', 'pg789'];

    _wishlistPGs = [
      PGProperty(
        id: 'pg123',
        name: 'Green Valley PG',
        address: 'Sector 18, Noida',
        latitude: 28.5706,
        longitude: 77.3261,
        totalRooms: 1,
        availableRooms: 1,
        price: 12000,
        securityDeposit: 12000,
        rating: 4.5,
        reviewCount: 42,
        amenities: ['WIFI', 'AC', 'MEALS', 'PARKING'],
        images: [
          'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=400'
        ],
        genderPreference: 'ANY',
        roomTypes: ['SINGLE', 'DOUBLE'],
        occupationType: 'ANY',
        ownerName: 'Mr. Sharma',
        contactPhone: '9876543210',
        description: 'A comfortable PG with all amenities',
        houseRules: ['No smoking', 'No loud music after 10 PM'],
        nearbyLandmarks: ['Metro Station - 500m'],
        isVerified: true,
        isFeatured: true,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        updatedAt: DateTime.now(),
      ),
      PGProperty(
        id: 'pg456',
        name: 'Comfort PG',
        address: 'Sector 62, Noida',
        latitude: 28.6280,
        totalRooms: 1,
        availableRooms: 1,
        longitude: 77.3649,
        price: 10000,
        securityDeposit: 10000,
        rating: 4.0,
        reviewCount: 28,
        amenities: ['WIFI', 'AC', 'PARKING'],
        images: [
          'https://images.unsplash.com/photo-1555854877-bab0e655b6f0?w=400'
        ],
        genderPreference: 'MALE',
        roomTypes: ['DOUBLE', 'TRIPLE'],
        occupationType: 'STUDENT',
        ownerName: 'Mr. Kumar',
        contactPhone: '9876543211',
        description: 'Budget-friendly PG for students',
        houseRules: ['No guests after 9 PM'],
        nearbyLandmarks: ['College - 1km'],
        isVerified: true,
        isFeatured: false,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  /// Load user profile from API
  Future<void> _loadUserProfile() async {
    try {
      // In a real app, this would be an API call
      // For now, just use the mock data already loaded
      // The API call would look like:
      // final response = await _apiService.get(AppConstants.userProfileEndpoint);
      // _userProfile = UserProfile.fromJson(response['data']);

      // Simulate API delay
      await Future.delayed(const Duration(milliseconds: 500));

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user profile: $e');
      // Keep cached data if API fails
    }
  }

  /// Load user bookings
  Future<void> _loadUserBookings() async {
    try {
      // In a real app, this would be an API call
      // For now, just use the mock data already loaded

      // Simulate API delay
      await Future.delayed(const Duration(milliseconds: 700));

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading bookings: $e');
    }
  }

  /// Load wishlist
  Future<void> _loadWishlist() async {
    try {
      // In a real app, this would be an API call
      // For now, just use the mock data already loaded

      // Simulate API delay
      await Future.delayed(const Duration(milliseconds: 600));

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading wishlist: $e');
    }
  }

  /// Load app settings
  Future<void> _loadAppSettings() async {
    try {
      // Simulate loading from preferences
      await Future.delayed(const Duration(milliseconds: 300));

      _appSettings = const AppSettings(
        themeMode: 'system',
        notificationsEnabled: true,
        locationTrackingEnabled: true,
        emailNotificationsEnabled: true,
        smsNotificationsEnabled: false,
      );

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading app settings: $e');
    }
  }

  /// Upload profile image
  Future<bool> uploadProfileImage(File image) async {
    _selectedProfileImage = image;
    _isUploadingImage = true;
    notifyListeners();

    try {
      // Simulate API upload delay
      await Future.delayed(const Duration(seconds: 2));

      // In a real app, this would upload the image to a server
      // For demo, we'll just update the profile with a mock URL
      if (_userProfile != null) {
        _userProfile = _userProfile!.copyWith(
          profilePicture:
              'https://i.pravatar.cc/300?u=${DateTime.now().millisecondsSinceEpoch}',
        );
      }

      _selectedProfileImage = null;
      _isUploadingImage = false;
      notifyListeners();

      return true;
    } catch (e) {
      _setError('Failed to upload image: ${e.toString()}');
      _selectedProfileImage = null;
      _isUploadingImage = false;
      notifyListeners();
      return false;
    }
  }

  /// Remove profile image
  Future<bool> removeProfileImage() async {
    _isUploadingImage = true;
    notifyListeners();

    try {
      // Simulate API delay
      await Future.delayed(const Duration(seconds: 1));

      // Remove profile picture
      if (_userProfile != null) {
        _userProfile = _userProfile!.copyWith(profilePicture: null);
      }

      _isUploadingImage = false;
      notifyListeners();

      return true;
    } catch (e) {
      _setError('Failed to remove image: ${e.toString()}');
      _isUploadingImage = false;
      notifyListeners();
      return false;
    }
  }

  /// Toggle wishlist item
  Future<bool> toggleWishlist(String pgId) async {
    try {
      final isCurrentlyWishlisted = _wishlistPGIds.contains(pgId);

      if (isCurrentlyWishlisted) {
        // Remove from wishlist
        _wishlistPGIds.remove(pgId);
        _wishlistPGs.removeWhere((pg) => pg.id == pgId);
      } else {
        // Add to wishlist
        _wishlistPGIds.add(pgId);

        // In a real app, we would fetch PG details if not already cached
        // For demo, we'll check if it's one of our mock PGs
        final mockPG = _getMockPGById(pgId);
        if (mockPG != null && !_wishlistPGs.any((pg) => pg.id == pgId)) {
          _wishlistPGs.add(mockPG);
        }
      }

      // Recalculate stats
      _calculateProfileStats();

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update wishlist: ${e.toString()}');
      return false;
    }
  }

  /// Get mock PG by ID (helper method for demo)
  PGProperty? _getMockPGById(String pgId) {
    final mockPGs = [
      PGProperty(
        id: 'pg123',
        name: 'Green Valley PG',
        address: 'Sector 18, Noida',
        latitude: 28.5706,
        longitude: 77.3261,
        price: 12000,
        securityDeposit: 12000,
        rating: 4.5,
        reviewCount: 42,
        amenities: ['WIFI', 'AC', 'MEALS', 'PARKING'],
        images: [
          'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=400'
        ],
        genderPreference: 'ANY',
        roomTypes: ['SINGLE', 'DOUBLE'],
        occupationType: 'ANY',
        ownerName: 'Mr. Sharma',
        contactPhone: '9876543210',
        description: 'A comfortable PG with all amenities',
        houseRules: ['No smoking', 'No loud music after 10 PM'],
        nearbyLandmarks: ['Metro Station - 500m'],
        isVerified: true,
        isFeatured: true,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        updatedAt: DateTime.now(),
        totalRooms: 1,
        availableRooms: 1,
      ),
      PGProperty(
        id: 'pg456',
        name: 'Comfort PG',
        address: 'Sector 62, Noida',
        latitude: 28.6280,
        longitude: 77.3649,
        price: 10000,
        securityDeposit: 10000,
        rating: 4.0,
        reviewCount: 28,
        amenities: ['WIFI', 'AC', 'PARKING'],
        images: [
          'https://images.unsplash.com/photo-1555854877-bab0e655b6f0?w=400'
        ],
        genderPreference: 'MALE',
        roomTypes: ['DOUBLE', 'TRIPLE'],
        occupationType: 'STUDENT',
        ownerName: 'Mr. Kumar',
        contactPhone: '9876543211',
        description: 'Budget-friendly PG for students',
        houseRules: ['No guests after 9 PM'],
        nearbyLandmarks: ['College - 1km'],
        isVerified: true,
        isFeatured: false,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
        updatedAt: DateTime.now(),
        totalRooms: 1,
        availableRooms: 1,
      ),
      PGProperty(
        id: 'pg789',
        name: 'Luxury PG',
        address: 'Sector 50, Noida',
        latitude: 28.5735,
        longitude: 77.3718,
        price: 15000,
        securityDeposit: 15000,
        rating: 4.8,
        reviewCount: 56,
        amenities: ['WIFI', 'AC', 'MEALS', 'PARKING', 'GYM', 'RECREATION_ROOM'],
        images: [
          'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=400'
        ],
        genderPreference: 'FEMALE',
        roomTypes: ['SINGLE'],
        occupationType: 'PROFESSIONAL',
        ownerName: 'Mrs. Gupta',
        contactPhone: '9876543212',
        description: 'Premium PG for working professionals',
        houseRules: ['No smoking', 'No loud music after 10 PM'],
        nearbyLandmarks: ['Metro Station - 200m', 'Mall - 500m'],
        isVerified: true,
        isFeatured: true,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
        updatedAt: DateTime.now(),
        totalRooms: 1,
        availableRooms: 1,
      ),
    ];

    return mockPGs.firstWhere((pg) => pg.id == pgId, orElse: () => mockPGs[0]);
  }

  /// Update app settings
  Future<void> updateAppSettings(AppSettings newSettings) async {
    try {
      _appSettings = newSettings;

      // In a real app, would save to cache/preferences
      // await _cacheService.saveUserPreference('theme_mode', newSettings.themeMode);

      notifyListeners();
    } catch (e) {
      debugPrint('Error updating settings: $e');
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Reset state
      _userProfile = null;
      _userBookings = [];
      _wishlistPGIds = [];
      _wishlistPGs = [];
      _profileStats = ProfileStats();
      _selectedProfileImage = null;

      notifyListeners();
    } catch (e) {
      debugPrint('Error during logout: $e');
    }
  }

  /// Calculate profile statistics
  void _calculateProfileStats() {
    if (_userProfile == null) return;

    final now = DateTime.now();
    final totalBookings = _userBookings.length;
    final activeBookings = _userBookings
        .where((b) => b.status == 'CONFIRMED' || b.status == 'CHECKED_IN')
        .length;
    final completedBookings =
        _userBookings.where((b) => b.status == 'CHECKED_OUT').length;
    final totalSpent = _userBookings.fold<double>(
      0,
      (sum, b) => sum + b.totalAmount,
    );
    final memberSince = _userProfile!.createdAt;
    final wishlistCount = _wishlistPGIds.length;

    _profileStats = ProfileStats(
      totalBookings: totalBookings,
      activeBookings: activeBookings,
      completedBookings: completedBookings,
      totalSpent: totalSpent,
      memberSince: memberSince,
      wishlistCount: wishlistCount,
      profileCompletionPercentage: 85, // Mock value
    );

    notifyListeners();
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
  }) : memberSince = memberSince ?? ProfileStats.defDate;

  static DateTime defDate = DateTime.now();

  String get formattedTotalSpent => '₹${totalSpent.toInt()}';

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

  const AppSettings({
    this.themeMode = 'system',
    this.notificationsEnabled = true,
    this.locationTrackingEnabled = true,
    this.emailNotificationsEnabled = true,
    this.smsNotificationsEnabled = false,
  });

  AppSettings copyWith({
    String? themeMode,
    bool? notificationsEnabled,
    bool? locationTrackingEnabled,
    bool? emailNotificationsEnabled,
    bool? smsNotificationsEnabled,
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
    );
  }
}
