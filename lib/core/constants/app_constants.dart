/// App constants and configuration values
class AppConstants {
  // App Information
  static const String appName = 'NEARBY PG';
  static const String appTagline = 'Find Your Perfect PG';
  static const String appVersion = '1.0.0';
  static const int appBuildNumber = 1;

  // API Configuration
  static const String baseUrl = 'https://api.nearbypg.com/v1';
  static const String apiVersion = 'v1';
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Local Storage Keys
  static const String userPreferencesBox = 'user_preferences';
  static const String cacheBox = 'cache_box';
  static const String bookingCacheBox = 'booking_cache';
  static const String searchHistoryBox = 'search_history';

  // Shared Preferences Keys
  static const String keyUserToken = 'user_token';
  static const String keyUserId = 'user_id';
  static const String keyUserProfile = 'user_profile';
  static const String keyThemeMode = 'theme_mode';
  static const String keyLanguage = 'language';
  static const String keyFirstTime = 'first_time';
  static const String keyLocationPermission = 'location_permission';
  static const String keyNotificationPermission = 'notification_permission';
  static const String keyBiometricAuth = 'biometric_auth';
  static const String keyLastLocation = 'last_location';
  static const String keySearchFilters = 'search_filters';
  static const String keyWishlist = 'wishlist';
  static const String keyRecentSearches = 'recent_searches';

  // Route Names
  static const String splashRoute = '/splash';
  static const String onboardingRoute = '/onboarding';
  static const String loginRoute = '/login';
  static const String otpRoute = '/otp';
  static const String homeRoute = '/home';
  static const String searchRoute = '/search';
  static const String offersRoute = '/offers';
  static const String profileRoute = '/profile';
  static const String pgDetailRoute = '/pg-detail';
  static const String bookingRoute = '/booking';
  static const String bookingConfirmationRoute = '/booking-confirmation';
  static const String bookingHistoryRoute = '/booking-history';
  static const String wishlistRoute = '/wishlist';
  static const String settingsRoute = '/settings';
  static const String helpRoute = '/help';
  static const String aboutRoute = '/about';
  static const String termsRoute = '/terms';
  static const String privacyRoute = '/privacy';
  static const String contactRoute = '/contact';
  static const String mapViewRoute = '/map-view';
  static const String filterRoute = '/filter';
  static const String photoGalleryRoute = '/photo-gallery';
  static const String reviewsRoute = '/reviews';
  static const String editProfileRoute = '/edit-profile';
  static const String signupRoute = '/signup';

  // API Endpoints
  static const String authEndpoint = '/auth';
  static const String loginEndpoint = '$authEndpoint/login';
  static const String verifyOtpEndpoint = '$authEndpoint/verify-otp';
  static const String refreshTokenEndpoint = '$authEndpoint/refresh';
  static const String logoutEndpoint = '$authEndpoint/logout';

  static const String userEndpoint = '/user';
  static const String userProfileEndpoint = '$userEndpoint/profile';
  static const String updateProfileEndpoint = '$userEndpoint/update';

  static const String pgEndpoint = '/pg';
  static const String pgListEndpoint = '$pgEndpoint/list';
  static const String pgDetailEndpoint = '$pgEndpoint/detail';
  static const String pgSearchEndpoint = '$pgEndpoint/search';
  static const String pgFeaturedEndpoint = '$pgEndpoint/featured';
  static const String pgNearbyEndpoint = '$pgEndpoint/nearby';

  static const String bookingEndpoint = '/booking';
  static const String createBookingEndpoint = '$bookingEndpoint/create';
  static const String bookingHistoryEndpoint = '$bookingEndpoint/history';
  static const String cancelBookingEndpoint = '$bookingEndpoint/cancel';

  static const String wishlistEndpoint = '/wishlist';
  static const String addToWishlistEndpoint = '$wishlistEndpoint/add';
  static const String removeFromWishlistEndpoint = '$wishlistEndpoint/remove';

  static const String reviewEndpoint = '/review';
  static const String pgReviewsEndpoint = '$reviewEndpoint/pg';
  static const String submitReviewEndpoint = '$reviewEndpoint/submit';

  static const String offersEndpoint = '/offers';
  static const String activeOffersEndpoint = '$offersEndpoint/active';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 50;

  // Location Constants
  static const double defaultLatitude = 28.6139; // New Delhi
  static const double defaultLongitude = 77.2090;
  static const double maxSearchRadius = 50.0; // km
  static const double defaultSearchRadius = 10.0; // km

  // Image Configuration
  static const int maxImageQuality = 85;
  static const int thumbnailSize = 200;
  static const int mediumImageSize = 600;
  static const int largeImageSize = 1200;
  static const List<String> allowedImageFormats = [
    'jpg',
    'jpeg',
    'png',
    'webp',
  ];

  // Validation Constants
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;
  static const int otpLength = 6;
  static const int phoneNumberLength = 10;
  static const Duration otpResendDelay = Duration(seconds: 30);
  static const Duration otpExpiry = Duration(minutes: 5);

  // UI Constants
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration splashDuration = Duration(seconds: 3);
  static const Duration debounceDelay = Duration(milliseconds: 500);
  static const Duration refreshIndicatorDuration = Duration(seconds: 2);

  // Spacing and Sizing
  static const double paddingXS = 4.0;
  static const double paddingSM = 8.0;
  static const double paddingMD = 16.0;
  static const double paddingLG = 24.0;
  static const double paddingXL = 32.0;

  static const double borderRadiusXS = 4.0;
  static const double borderRadiusSM = 8.0;
  static const double borderRadiusMD = 12.0;
  static const double borderRadiusLG = 16.0;
  static const double borderRadiusXL = 24.0;

  static const double elevationXS = 1.0;
  static const double elevationSM = 2.0;
  static const double elevationMD = 4.0;
  static const double elevationLG = 8.0;
  static const double elevationXL = 16.0;

  // Font Sizes
  static const double fontSizeXS = 10.0;
  static const double fontSizeSM = 12.0;
  static const double fontSizeMD = 14.0;
  static const double fontSizeLG = 16.0;
  static const double fontSizeXL = 18.0;
  static const double fontSizeXXL = 20.0;
  static const double fontSizeDisplay = 24.0;

  // Grid and Layout
  static const int gridColumns = 2;
  static const double gridSpacing = 16.0;
  static const double cardAspectRatio = 0.75;
  static const double listItemHeight = 120.0;

  // Search and Filter
  static const int maxRecentSearches = 10;
  static const int searchSuggestionLimit = 5;
  static const double minBudgetRange = 1000.0;
  static const double maxBudgetRange = 50000.0;
  static const double budgetStep = 500.0;

  // Booking Constants
  static const int maxAdvanceBookingDays = 90;
  static const int minAdvanceBookingDays = 1;
  static const Duration bookingTimeoutDuration = Duration(minutes: 15);

  // Rating and Review
  static const double minRating = 1.0;
  static const double maxRating = 5.0;
  static const int maxReviewLength = 500;
  static const int minReviewLength = 10;

  // Cache Configuration
  static const Duration cacheExpiry = Duration(hours: 24);
  static const Duration shortCacheExpiry = Duration(hours: 1);
  static const Duration longCacheExpiry = Duration(days: 7);
  static const int maxCacheSize = 100; // Number of items

  // Analytics Events
  static const String eventAppOpen = 'app_open';
  static const String eventLogin = 'login';
  static const String eventSignup = 'signup';
  static const String eventSearch = 'search';
  static const String eventPgView = 'pg_view';
  static const String eventBookingStart = 'booking_start';
  static const String eventBookingComplete = 'booking_complete';
  static const String eventWishlistAdd = 'wishlist_add';
  static const String eventFilterApply = 'filter_apply';
  static const String eventContactPg = 'contact_pg';
  static const String eventSharePg = 'share_pg';

  // Error Messages
  static const String errorGeneric = 'Something went wrong. Please try again.';
  static const String errorNetwork =
      'Check your internet connection and try again.';
  static const String errorTimeout = 'Request timed out. Please try again.';
  static const String errorUnauthorized = 'Please login to continue.';
  static const String errorNotFound = 'The requested resource was not found.';
  static const String errorServerError =
      'Server error. Please try again later.';
  static const String errorInvalidInput =
      'Please check your input and try again.';
  static const String errorLocationPermission =
      'Location permission is required to find nearby PGs.';
  static const String errorLocationUnavailable =
      'Unable to get your location. Please enable GPS.';
  static const String errorNoInternet = 'No internet connection available.';

  // Success Messages
  static const String successLogin = 'Successfully logged in!';
  static const String successProfileUpdate = 'Profile updated successfully!';
  static const String successBooking = 'Booking confirmed successfully!';
  static const String successWishlistAdd = 'Added to wishlist!';
  static const String successWishlistRemove = 'Removed from wishlist!';
  static const String successReviewSubmit = 'Review submitted successfully!';

  // Amenity Icons (Material Icons)
  static const Map<String, String> amenityIcons = {
    'wifi': 'wifi',
    'ac': 'ac_unit',
    'meals': 'restaurant',
    'laundry': 'local_laundry_service',
    'parking': 'local_parking',
    'gym': 'fitness_center',
    'security': 'security',
    'housekeeping': 'cleaning_services',
    'hot_water': 'water_drop',
    'power_backup': 'power',
    'cctv': 'videocam',
    'study_room': 'book',
    'recreation_room': 'sports_esports',
  };

  // Currency Configuration
  static const String currency = '₹';
  static const String currencyCode = 'INR';
  static const String locale = 'en_IN';

  // Contact Information
  static const String supportEmail = 'support@nearbypg.com';
  static const String supportPhone = '+91-1234567890';
  static const String companyAddress = 'Bangalore, Karnataka, India';
  static const String website = 'https://nearbypg.com';

  // Social Media Links
  static const String facebookUrl = 'https://facebook.com/nearbypg';
  static const String twitterUrl = 'https://twitter.com/nearbypg';
  static const String instagramUrl = 'https://instagram.com/nearbypg';
  static const String linkedinUrl = 'https://linkedin.com/company/nearbypg';

  // App Store Links
  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.nearbypg.app';
  static const String appStoreUrl =
      'https://apps.apple.com/app/nearby-pg/id123456789';

  // Feature Flags
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;
  static const bool enableLocationTracking = true;
  static const bool enablePushNotifications = true;
  static const bool enableBiometricAuth = true;
  static const bool enableDarkMode = true;
  static const bool enableOfflineMode = true;
  static const bool enableShareFeature = true;
  static const bool enableReviewFeature = true;
  static const bool enableChatFeature = false; // Future feature
  static const bool enableVideoCallFeature = false; // Future feature

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
  static const String seeLess = 'see_less';

  // PG Related
  static const String pgName = 'pg_name';
  static const String location = 'location';
  static const String rent = 'rent';
  static const String securityDeposit = 'security_deposit';
  static const String availableRooms = 'available_rooms';
  static const String amenities = 'amenities';
  static const String rating = 'rating';
  static const String reviews = 'reviews';
  static const String bookNow = 'book_now';
  static const String viewDetails = 'view_details';
  static const String addToWishlist = 'add_to_wishlist';
  static const String removeFromWishlist = 'remove_from_wishlist';

  // Search and Filter
  static const String searchPgs = 'search_pgs';
  static const String filters = 'filters';
  static const String applyFilters = 'apply_filters';
  static const String clearFilters = 'clear_filters';
  static const String budget = 'budget';
  static const String roomType = 'room_type';
  static const String genderPreference = 'gender_preference';
  static const String sortBy = 'sort_by';
  static const String nearbyPgs = 'nearby_pgs';
  static const String featuredPgs = 'featured_pgs';

  // Booking
  static const String bookingConfirmation = 'booking_confirmation';
  static const String bookingHistory = 'booking_history';
  static const String cancelBooking = 'cancel_booking';
  static const String bookingDetails = 'booking_details';
  static const String checkIn = 'check_in';
  static const String checkOut = 'check_out';

  // Profile
  static const String myProfile = 'my_profile';
  static const String editProfile = 'edit_profile';
  static const String settings = 'settings';
  static const String helpSupport = 'help_support';
  static const String aboutUs = 'about_us';
  static const String termsConditions = 'terms_conditions';
  static const String privacyPolicy = 'privacy_policy';

  // Prevent instantiation
  StringConstants._();
}

/// Asset path constants
class AssetConstants {
  // Images
  static const String _imagesPath = 'assets/images';
  static const String logoPath = '$_imagesPath/logo.png';
  static const String splashLogo = '$_imagesPath/splash_logo.png';
  static const String onboardingImage1 = '$_imagesPath/onboarding_1.png';
  static const String onboardingImage2 = '$_imagesPath/onboarding_2.png';
  static const String onboardingImage3 = '$_imagesPath/onboarding_3.png';
  static const String placeholderImage = '$_imagesPath/placeholder.png';
  static const String errorImage = '$_imagesPath/error.png';
  static const String noDataImage = '$_imagesPath/no_data.png';

  // Icons
  static const String _iconsPath = 'assets/icons';
  static const String homeIcon = '$_iconsPath/home.svg';
  static const String searchIcon = '$_iconsPath/search.svg';
  static const String offersIcon = '$_iconsPath/offers.svg';
  static const String profileIcon = '$_iconsPath/profile.svg';
  static const String locationIcon = '$_iconsPath/location.svg';
  static const String filterIcon = '$_iconsPath/filter.svg';
  static const String heartIcon = '$_iconsPath/heart.svg';
  static const String starIcon = '$_iconsPath/star.svg';

  // Lottie Animations
  static const String _lottiePath = 'assets/lottie';
  static const String loadingAnimation = '$_lottiePath/loading.json';
  static const String successAnimation = '$_lottiePath/success.json';
  static const String errorAnimation = '$_lottiePath/error.json';
  static const String emptyAnimation = '$_lottiePath/empty.json';

  // Fonts
  static const String poppinsFont = 'Poppins';
  static const String interFont = 'Inter';
  static const String robotoFont = 'Roboto';

  // Prevent instantiation
  AssetConstants._();
  // Removed duplicate AppConstants class to fix the redefinition error.
  static const String appTagline = 'Find Your Perfect PG';
  static const String appVersion = '1.0.0';
  static const int appBuildNumber = 1;

  // API Configuration - Optimized timeouts
  static const String baseUrl = 'https://api.nearbypg.com/v1';
  static const String apiVersion = 'v1';
  static const Duration apiTimeout = Duration(
    seconds: 15,
  ); // Reduced for better UX
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // Storage Keys - Organized by category
  static const String userPreferencesBox = 'user_prefs';
  static const String cacheBox = 'app_cache';
  static const String pgDataBox = 'pg_data';
  static const String searchHistoryBox = 'search_history';
  static const String bookingCacheBox = 'booking_cache';

  // User Preferences Keys
  static const String keyUserToken = 'user_token';
  static const String keyUserId = 'user_id';
  static const String keyUserProfile = 'user_profile';
  static const String keyThemeMode = 'theme_mode';
  static const String keyLanguage = 'language';
  static const String keyFirstTime = 'first_time';
  static const String keyLocationPermission = 'location_permission';
  static const String keySearchFilters = 'search_filters';
  static const String keyWishlist = 'wishlist';
  static const String keyLastLocation = 'last_location';

  // Routes - Comprehensive routing
  static const String splashRoute = '/splash';
  static const String loginRoute = '/login';
  static const String signupRoute = '/signup';
  static const String otpRoute = '/otp';
  static const String homeRoute = '/home';
  static const String searchRoute = '/search';
  static const String offersRoute = '/offers';
  static const String profileRoute = '/profile';
  static const String pgDetailRoute = '/pg-detail';
  static const String bookingRoute = '/booking';
  static const String wishlistRoute = '/wishlist';
  static const String settingsRoute = '/settings';
  static const String mapViewRoute = '/map-view';
  static const String filterRoute = '/filter';

  // API Endpoints - Organized for better maintainability
  static const String loginEndpoint = '/auth/login';
  static const String verifyOtpEndpoint = '/auth/verify-otp';
  static const String refreshTokenEndpoint = '/auth/refresh';
  static const String pgListEndpoint = '/pg/list';
  static const String pgDetailEndpoint = '/pg/detail';
  static const String pgSearchEndpoint = '/pg/search';
  static const String pgFeaturedEndpoint = '/pg/featured';
  static const String createBookingEndpoint = '/booking/create';
  static const String wishlistEndpoint = '/wishlist';

  // UI Constants - Optimized for performance
  static const Duration animationDuration = Duration(milliseconds: 250);
  static const Duration splashDuration = Duration(seconds: 2); // Reduced
  static const Duration debounceDelay = Duration(milliseconds: 300);

  // Responsive Design Constants
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;
  static const double desktopBreakpoint = 1200.0;

  // Spacing - Design system
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;

  // Border Radius
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;

  // Cache Configuration - Optimized
  static const Duration shortCacheExpiry = Duration(minutes: 30);
  static const Duration mediumCacheExpiry = Duration(hours: 6);
  static const Duration longCacheExpiry = Duration(days: 1);
  static const int maxCacheEntries = 50; // Reduced for memory optimization

  // Location Constants
  static const double defaultLatitude = 28.6139; // Delhi
  static const double defaultLongitude = 77.2090;
  static const double defaultSearchRadius = 10.0; // km
  static const double maxSearchRadius = 50.0; // km

  // Validation
  static const int phoneNumberLength = 10;
  static const int otpLength = 6;
  static const Duration otpResendDelay = Duration(seconds: 30);
  static const int maxRecentSearches = 10;

  // Performance Limits
  static const int defaultPageSize = 20;
  static const int maxPageSize = 50;
  static const int imageCompressionQuality = 85;
  static const int maxImageSizeMB = 5;

  // Error Messages - User-friendly
  static const String errorGeneric = 'Something went wrong. Please try again.';
  static const String errorNetwork = 'Please check your internet connection.';
  static const String errorTimeout = 'Request timed out. Please try again.';
  static const String errorUnauthorized = 'Please sign in to continue.';
  static const String errorLocationPermission =
      'Location access is required to find nearby PGs.';

  // Success Messages
  static const String successLogin = 'Welcome back!';
  static const String successBooking = 'Booking confirmed successfully!';
  static const String successWishlistAdd = 'Added to favorites!';

  // Environment
  static const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );
  static bool get isProduction => environment == 'production';
  static bool get isDevelopment => environment == 'development';

  // Feature Flags - Optimized for performance
  static const bool enableCaching = true;
  static const bool enableAnalytics = true;
  static const bool enableLocationTracking = true;
  static const bool enableOfflineMode = true;
}
