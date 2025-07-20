// lib/core/constants/app_constants.dart
import 'package:flutter/material.dart';

/// Application constants and configuration
class AppConstants {
  // App Info
  static const String appName = 'NEARBY PG';
  static const String appTagline = 'Find Your Perfect PG';
  static const String appDescription = 'Premium PG Discovery Platform';
  static const String appVersion = '1.0.0';

  // Route Constants
  static const String splashRoute = '/';
  static const String onboardingRoute = '/onboarding';
  static const String loginRoute = '/login';
  static const String signupRoute = '/signup';
  static const String otpRoute = '/otp';
  static const String homeRoute = '/home';
  static const String searchRoute = '/search';
  static const String pgDetailRoute = '/pg-detail';
  static const String bookingRoute = '/booking';
  static const String profileRoute = '/profile';
  static const String offersRoute = '/offers';
  static const String settingsRoute = '/settings';
  static const String wishlistRoute = '/wishlist';
  static const String mapViewRoute = '/map-view';
  static const String filterRoute = '/filter';

  // API Constants
  static const String baseUrl = 'https://api.nearbypg.com/v1';
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const String apiKey = 'YOUR_API_KEY';

  // Endpoint Constants
  static const String pgListEndpoint = '/pg/list';
  static const String pgDetailEndpoint = '/pg/detail';
  static const String featuredPGsEndpoint = '/pg/featured';
  static const String nearbyPGsEndpoint = '/pg/nearby';
  static const String searchPGsEndpoint = '/pg/search';
  static const String bannersEndpoint = '/banners';
  static const String bookingEndpoint = '/booking';
  static const String bookingHistoryEndpoint = '/booking/history';
  static const String userProfileEndpoint = '/user/profile';
  static const String wishlistEndpoint = '/user/wishlist';
  static const String authLoginEndpoint = '/auth/login';
  static const String authVerifyOTPEndpoint = '/auth/verify-otp';
  static const String authSignupEndpoint = '/auth/signup';

  // Splash Screen
  static const Duration splashDuration = Duration(seconds: 2);

  // Local Storage Keys
  static const String userPreferencesBox = 'user_preferences';
  static const String cacheBox = 'cache_box';
  static const String searchHistoryBox = 'search_history';
  static const String bookingCacheBox = 'booking_cache';

  // Cache Configuration
  static const Duration pgCacheValidityDuration = Duration(hours: 1);
  static const Duration bannersValidityDuration = Duration(hours: 12);
  static const Duration locationValidityDuration = Duration(minutes: 30);
  static const int maxRecentSearches = 10;

  // Location Configuration
  static const double defaultSearchRadius = 5.0; // in kilometers
  static const double maxSearchRadius = 20.0; // in kilometers

  // UI Configuration
  static const double cardBorderRadius = 12.0;
  static const double buttonBorderRadius = 8.0;
  static const double pillBorderRadius = 20.0;
  static const EdgeInsets defaultPadding = EdgeInsets.all(16.0);
  static const double defaultSpacing = 16.0;

  // Feature Flags
  static const bool enableLocationFeatures = true;
  static const bool enableOfflineMode = true;
  static const bool enableBookingFeature = true;
  static const bool enableNotifications = true;
  static const bool enableRatingFeature = true;
  static const bool enableWishlistFeature = true;
  static const bool enableChatFeature = false; // Future feature
  static const bool enableVideoCallFeature = false; // Future feature

  static const double minBudgetRange = 1000;
  static const double maxBudgetRange = 50000;
  static const double budgetStep = 500;

  // Environment Configuration
  static const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );

  static bool get isProduction => environment == 'production';
  static bool get isDevelopment => environment == 'development';
  static bool get isStaging => environment == 'staging';

  // Prevent instantiation
  AppConstants._();
}

/// String constants for localization keys
class StringConstants {
  // App
  static const String appName = 'app_name';
  static const String appTagline = 'app_tagline';

  // Authentication
  static const String login = 'login';
  static const String signup = 'signup';
  static const String logout = 'logout';
  static const String phoneNumber = 'phone_number';
  static const String enterPhoneNumber = 'enter_phone_number';
  static const String otpVerification = 'otp_verification';
  static const String enterOtp = 'enter_otp';
  static const String resendOtp = 'resend_otp';
  static const String verifyAndLogin = 'verify_and_login';

  // Navigation
  static const String home = 'home';
  static const String search = 'search';
  static const String offers = 'offers';
  static const String profile = 'profile';

  // Common
  static const String ok = 'ok';
  static const String cancel = 'cancel';
  static const String save = 'save';
  static const String delete = 'delete';
  static const String edit = 'edit';
  static const String update = 'update';
  static const String loading = 'loading';
  static const String retry = 'retry';
  static const String refresh = 'refresh';
  static const String share = 'share';
  static const String contact = 'contact';
  static const String viewAll = 'view_all';
  static const String seeMore = 'see_more';

  // Search
  // static const String search = 'search';
  static const String searchHint = 'search_hint';
  static const String filter = 'filter';
  static const String sort = 'sort';
  static const String noResults = 'no_results';
  static const String clearFilters = 'clear_filters';
  static const String applyFilters = 'apply_filters';

  // PG Properties
  static const String featuredPGs = 'featured_pgs';
  static const String nearbyPGs = 'nearby_pgs';
  static const String recommendedPGs = 'recommended_pgs';
  static const String newlyAddedPGs = 'newly_added_pgs';
  static const String verified = 'verified';
  static const String amenities = 'amenities';
  static const String reviews = 'reviews';
  static const String description = 'description';
  static const String location = 'location';
  static const String distance = 'distance';
  static const String pricePerMonth = 'price_per_month';
  static const String roomTypes = 'room_types';
  static const String gender = 'gender';
  static const String genderPreference = 'gender_preference';
  static const String meals = 'meals';
  static const String bookNow = 'book_now';
  static const String viewDetails = 'view_details';
  static const String showOnMap = 'show_on_map';

  // Wishlist
  static const String wishlist = 'wishlist';
  static const String addedToWishlist = 'added_to_wishlist';
  static const String removedFromWishlist = 'removed_from_wishlist';
  static const String emptyWishlist = 'empty_wishlist';

  // Error Messages
  static const String errorLoading = 'error_loading';
  static const String errorNetwork = 'error_network';
  static const String errorUnknown = 'error_unknown';
  static const String errorLocation = 'error_location';

  // Success Messages
  static const String successLogin = 'success_login';
  static const String successSignup = 'success_signup';
  static const String successBooking = 'success_booking';

  // Onboarding
  static const String skip = 'skip';
  static const String next = 'next';
  static const String getStarted = 'get_started';
}
