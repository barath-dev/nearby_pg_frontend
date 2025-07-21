// lib/core/constants/app_constants.dart


/// Application-wide constants
class AppConstants {
  // API configuration
  static const String baseUrl = 'https://api.nearbypg.com/v1';
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Feature flags
  static const bool isDevelopment = true;
  static const bool enableAnalytics = true;

  // Cache configuration
  static const Duration shortCacheExpiry = Duration(minutes: 30);
  static const Duration longCacheExpiry = Duration(days: 7);
  static const int maxRecentSearches = 10;
  static const int maxSearchSuggestions = 8;

  // Pagination
  static const int defaultPageSize = 10;

  // Search configuration
  static const Duration debounceDelay = Duration(milliseconds: 500);

  // Map configuration
  static const double defaultMapZoom = 14.0;
  static const double defaultLatitude = 28.6139;
  static const double defaultLongitude = 77.2090;

  // App routes
  static const String homeRoute = 'home';
  static const String searchRoute = 'search';
  static const String offersRoute = 'offers';
  static const String profileRoute = 'profile';
  static const String pgDetailRoute = 'pgDetail';
  static const String loginRoute = 'login';
  static const String signupRoute = 'signup';
  static const String onboardingRoute = 'onboarding';
  static const String splashRoute = 'splash';

  // Default values
  static const double defaultRatingValue = 0.0;
  static const int defaultReviewCount = 0;
  static const List<String> defaultAmenities = [];
  static const List<String> defaultRoomTypes = ['SINGLE', 'DOUBLE', 'TRIPLE'];
  static const List<String> defaultGenderOptions = [
    'MALE',
    'FEMALE',
    'CO_ED',
    'ANY'
  ];
  static const List<String> defaultOccupationTypes = [
    'STUDENT',
    'PROFESSIONAL',
    'ANY'
  ];
  static const List<String> defaultSortOptions = [
    'distance',
    'price',
    'rating',
    'newest'
  ];

  // Error messages
  static const String genericErrorMessage =
      'Something went wrong. Please try again.';
  static const String networkErrorMessage =
      'Network error. Please check your connection.';
  static const String locationPermissionDeniedMessage =
      'Location permission denied. Some features may not work properly.';

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultMargin = 16.0;
  static const double defaultRadius = 12.0;
  static const double cardElevation = 2.0;
  static const double buttonHeight = 56.0;
  static const double iconSize = 24.0;
  static const double smallIconSize = 16.0;

  // Animation durations
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // App-specific constants
  static const int minBookingDuration = 30; // days
  static const double minSecurityDeposit = 1000.0;
  static const double maxSecurityDeposit = 50000.0;
  static const double defaultReferralBonus = 500.0;

  // Pricing constants
  static const double minPrice = 1000.0;
  static const double maxPrice = 50000.0;
  static const double defaultMinPrice = 5000.0;
  static const double defaultMaxPrice = 15000.0;

  // Filter constants
  static const double maxFilterDistance = 10.0; // km
  static const double defaultFilterDistance = 5.0;

  static var minBudgetRange = 1000.0;

  static var maxBudgetRange = 30000.0;

  static var maxSearchRadius = 20.0;

  static Duration splashDuration = const Duration(seconds: 2);

  static String otpRoute = '/otp';
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
