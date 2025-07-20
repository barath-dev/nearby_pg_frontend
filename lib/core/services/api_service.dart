// lib/core/services/api_service.dart
import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import 'package:flutter/foundation.dart';

/// Service for handling API requests
class ApiService {
  late final Dio _dio;
  bool _isAuthenticated = false;

  /// Constructor with Dio initialization
  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // Add interceptors for logging, authentication, etc.
    _setupInterceptors();
  }

  /// Set up Dio interceptors for logging and token handling
  void _setupInterceptors() {
    // Log interceptor for debugging API calls
    if (AppConstants.isDevelopment) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (object) => debugPrint('DIO: $object'),
        ),
      );
    }

    // Auth interceptor for adding token to requests
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add auth token if available
          final token = _getAuthToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          // Handle 401 Unauthorized errors
          if (error.response?.statusCode == 401) {
            _handleUnauthorized();
          }
          return handler.next(error);
        },
      ),
    );
  }

  /// Check if user is authenticated
  bool get isAuthenticated => _isAuthenticated;

  /// Get authentication token from secure storage
  String? _getAuthToken() {
    // TODO: Implement secure storage for token
    return null;
  }

  /// Handle unauthorized errors (token expired, etc.)
  void _handleUnauthorized() {
    _isAuthenticated = false;
    // TODO: Navigate to login screen
  }

  /// Make a GET request to the API
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
      );
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Make a POST request to the API
  Future<Map<String, dynamic>> post(String endpoint, {dynamic data}) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Make a PUT request to the API
  Future<Map<String, dynamic>> put(String endpoint, {dynamic data}) async {
    try {
      final response = await _dio.put(endpoint, data: data);
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Make a DELETE request to the API
  Future<Map<String, dynamic>> delete(String endpoint, {dynamic data}) async {
    try {
      final response = await _dio.delete(endpoint, data: data);
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Handle API response
  Map<String, dynamic> _handleResponse(Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      if (response.data is Map<String, dynamic>) {
        return response.data;
      } else {
        return {'data': response.data};
      }
    } else {
      throw Exception('Unexpected response format');
    }
  }

  /// Handle errors from API requests
  Exception _handleError(dynamic error) {
    if (error is DioException) {
      final errorMessage = error.response?.data?['message'] ??
          error.message ??
          'Network error occurred';
      debugPrint('API Error: $errorMessage');
      return Exception(errorMessage);
    }
    return Exception('Unknown error occurred');
  }

  /// Mock API call for getting nearby PGs (for development)
  Future<List<Map<String, dynamic>>> getMockNearbyPGs() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

    return List.generate(
      10,
      (index) => {
        'id': 'pg_${index + 1}',
        'name': 'Luxury PG ${index + 1}',
        'address': '123 Main Street, City',
        'price': 10000.0 + (index * 1000),
        'rating': 3.5 + (index % 3) * 0.5,
        'reviewCount': 10 + index * 5,
        'distance': 0.5 + (index * 0.3),
        'images': [
          'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267',
          'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688',
        ],
        'amenities': ['WiFi', 'AC', 'Food', 'Parking'],
        'genderPreference':
            index % 3 == 0 ? 'MALE' : (index % 3 == 1 ? 'FEMALE' : 'ANY'),
        'mealsIncluded': index % 2 == 0,
        'isVerified': true,
        'isFeatured': index < 3,
      },
    );
  }

  /// Mock API call for featured PGs (for development)
  Future<List<Map<String, dynamic>>> getMockFeaturedPGs() async {
    await Future.delayed(
      const Duration(milliseconds: 800),
    ); // Simulate network delay

    return List.generate(
      5,
      (index) => {
        'id': 'featured_${index + 1}',
        'name': 'Premium PG ${index + 1}',
        'address': '456 Park Avenue, City',
        'price': 15000.0 + (index * 1500),
        'rating': 4.0 + (index % 2) * 0.5,
        'reviewCount': 20 + index * 8,
        'distance': 1.0 + (index * 0.5),
        'images': [
          'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2',
          'https://images.unsplash.com/photo-1484154218962-a197022b5858',
        ],
        'amenities': ['WiFi', 'AC', 'Food', 'Parking', 'Gym', 'Laundry'],
        'genderPreference':
            index % 3 == 0 ? 'MALE' : (index % 3 == 1 ? 'FEMALE' : 'ANY'),
        'mealsIncluded': true,
        'isVerified': true,
        'totalRooms': 1,
        'isFeatured': true,
        'availableRooms': 1,
      },
    );
  }

  /// Mock API call for promotional banners (for development)
  Future<List<Map<String, dynamic>>> getMockPromotionalBanners() async {
    await Future.delayed(
      const Duration(milliseconds: 600),
    ); // Simulate network delay

    return [
      {
        'id': 'banner_1',
        'imageUrl':
            'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af',
        'title': 'Special Discount',
        'description': 'Get 10% off on your first booking',
        'actionUrl': '/offers/first-booking',
      },
      {
        'id': 'banner_2',
        'imageUrl':
            'https://images.unsplash.com/photo-1493809842364-78817add7ffb',
        'title': 'Premium PGs',
        'description': 'Luxury PGs with all amenities',
        'actionUrl': '/featured',
      },
      {
        'id': 'banner_3',
        'imageUrl': 'https://images.unsplash.com/photo-1560185007-c5ca9d2c0862',
        'title': 'Verified PGs Only',
        'description': 'Safe and secure accommodation',
        'actionUrl': '/verified',
      },
    ];
  }
}
