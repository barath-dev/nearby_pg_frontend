// lib/features/offers/providers/offers_provider.dart
import 'package:flutter/foundation.dart';

import '../../../core/services/api_service.dart';
import '../../../core/services/cache_service.dart';
import '../screens/offers_screen.dart';

/// Provider for Offers screen functionality
class OffersProvider with ChangeNotifier {
  // Services
  final ApiService _apiService = ApiService();
  final CacheService _cacheService = CacheService();

  // State variables
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';

  // Data
  List<Offer> _pgOffers = [];
  List<Coupon> _coupons = [];
  List<Referral> _referrals = [];
  String _referralCode = '';
  double _referralBonus = 500;

  // Getters
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;
  List<Offer> get pgOffers => _pgOffers;
  List<Coupon> get coupons => _coupons;
  List<Referral> get referrals => _referrals;
  String get referralCode => _referralCode;
  double get referralBonus => _referralBonus;

  /// Initialize offers provider
  Future<void> initialize() async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();

    try {
      // Load cached data
      await _loadCachedData();

      // Load data from APIs (mock for now)
      await Future.wait([
        _loadOffers(),
        _loadCoupons(),
        _loadReferrals(),
      ]);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _hasError = true;
      _errorMessage = 'Failed to load offers: ${e.toString()}';
      debugPrint('Error initializing offers: $e');
      notifyListeners();
    }
  }

  /// Load cached data
  Future<void> _loadCachedData() async {
    try {
      // In a real app, would load from cache
      _referralCode = 'NPG500';
    } catch (e) {
      debugPrint('Error loading cached data: $e');
    }
  }

  /// Load offers from API (mock data for now)
  Future<void> _loadOffers() async {
    try {
      // Simulate API delay
      await Future.delayed(const Duration(milliseconds: 800));

      // Mock offers data
      _pgOffers = [
        Offer(
          id: 'offer1',
          title: 'First Booking Discount',
          description:
              'Get 20% off on your first month\'s rent when you book through our app',
          imageUrl:
              'https://images.unsplash.com/photo-1505691938895-1758d7feb511?w=500',
          discountText: '20% OFF',
          isExclusive: true,
          expiryDate: DateTime.now().add(const Duration(days: 30)),
          terms: [
            'Valid for first-time users only',
            'Maximum discount amount is ₹3000',
            'Cannot be combined with other offers',
            'Valid on bookings of minimum 3 months',
            'Applicable on all listed PGs',
          ],
        ),
        Offer(
          id: 'offer2',
          title: 'Refer a Friend',
          description:
              'Refer a friend and both of you get ₹1000 off on your next booking',
          imageUrl:
              'https://images.unsplash.com/photo-1521791055366-0d553872125f?w=500',
          discountText: '₹1000 OFF',
          expiryDate: DateTime.now().add(const Duration(days: 60)),
          terms: [
            'Both referrer and referee get ₹1000 off',
            'Valid on bookings of minimum 2 months',
            'Referee must complete the booking for both to get discount',
            'Maximum 5 referrals per user',
          ],
          couponCode: 'REFER1000',
        ),
        Offer(
          id: 'offer3',
          title: 'Long Stay Discount',
          description:
              'Book for 6 months or more and get 10% off on your entire stay',
          imageUrl:
              'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=500',
          discountText: '10% OFF',
          expiryDate: DateTime.now().add(const Duration(days: 45)),
          terms: [
            'Minimum booking duration of 6 months',
            'Valid for all users',
            'Cannot be combined with other offers',
            'Discount applies to entire stay duration',
          ],
        ),
        Offer(
          id: 'offer4',
          title: 'Premium PG Special',
          description:
              'Get complimentary first week meal plan on booking premium PGs',
          imageUrl:
              'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=500',
          discountText: 'FREE MEALS',
          isExclusive: true,
          expiryDate: DateTime.now().add(const Duration(days: 15)),
          terms: [
            'Valid only for Premium category PGs',
            'One week meal plan includes breakfast and dinner',
            'Valid for bookings of minimum 3 months',
            'Subject to availability',
          ],
        ),
      ];
    } catch (e) {
      debugPrint('Error loading offers: $e');
    }
  }

  /// Load coupons from API (mock data for now)
  Future<void> _loadCoupons() async {
    try {
      // Simulate API delay
      await Future.delayed(const Duration(milliseconds: 600));

      // Mock coupons data
      _coupons = [
        Coupon(
          id: 'coupon1',
          code: 'WELCOME20',
          title: 'Welcome Discount',
          description: 'Get 20% off on your first booking',
          expiryDate: DateTime.now().add(const Duration(days: 30)),
        ),
        Coupon(
          id: 'coupon2',
          code: 'SUMMER15',
          title: 'Summer Special',
          description: 'Get 15% off on all bookings during summer',
          expiryDate: DateTime.now().add(const Duration(days: 45)),
        ),
        Coupon(
          id: 'coupon3',
          code: 'PGFEST10',
          title: 'PG Fest Discount',
          description: 'Flat 10% off on all bookings during PG Fest',
          expiryDate: DateTime.now().subtract(const Duration(days: 15)),
          isValid: false,
        ),
        Coupon(
          id: 'coupon4',
          code: 'INSTANT5K',
          title: 'Instant ₹5000 Off',
          description: 'Get instant ₹5000 off on bookings above ₹50,000',
          expiryDate: DateTime.now().add(const Duration(days: 60)),
        ),
      ];
    } catch (e) {
      debugPrint('Error loading coupons: $e');
    }
  }

  /// Load referrals from API (mock data for now)
  Future<void> _loadReferrals() async {
    try {
      // Simulate API delay
      await Future.delayed(const Duration(milliseconds: 700));

      // For demo, sometimes show referrals, sometimes empty
      final random = DateTime.now().second % 3;

      if (random != 0) {
        // Mock referrals data
        _referrals = [
          Referral(
            id: 'ref1',
            name: 'John Doe',
            joinedDate: DateTime.now().subtract(const Duration(days: 45)),
            isComplete: true,
            bonusAmount: 500,
          ),
          Referral(
            id: 'ref2',
            name: 'Jane Smith',
            joinedDate: DateTime.now().subtract(const Duration(days: 20)),
            isComplete: false,
            bonusAmount: 500,
          ),
        ];
      } else {
        _referrals = [];
      }
    } catch (e) {
      debugPrint('Error loading referrals: $e');
    }
  }

  /// Refresh all data
  Future<void> refresh() async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();

    try {
      // Reload all data
      await Future.wait([
        _loadOffers(),
        _loadCoupons(),
        _loadReferrals(),
      ]);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _hasError = true;
      _errorMessage = 'Failed to refresh offers: ${e.toString()}';
      debugPrint('Error refreshing offers: $e');
      notifyListeners();
    }
  }
}
