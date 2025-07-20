import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import constants and models
import '../constants/app_constants.dart';

/// Comprehensive API service for all HTTP operations
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late final Dio _dio;
  String? _authToken;
  bool _isInitialized = false;

  /// Initialize the API service
  Future<void> initialize() async {
    if (_isInitialized) return;

    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        sendTimeout: AppConstants.connectTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-App-Version': AppConstants.appVersion,
          'X-Platform': Platform.isAndroid ? 'android' : 'ios',
        },
      ),
    );

    // Load saved auth token
    await _loadAuthToken();

    // Setup interceptors
    _setupInterceptors();

    _isInitialized = true;
    debugPrint('ApiService initialized with base URL: ${AppConstants.baseUrl}');
  }

  /// Setup request/response interceptors
  void _setupInterceptors() {
    // Request interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add auth token if available
          if (_authToken != null) {
            options.headers['Authorization'] = 'Bearer $_authToken';
          }

          // Add request ID for tracking
          options.headers['X-Request-ID'] = _generateRequestId();

          // Log request in debug mode
          if (kDebugMode) {
            debugPrint('🚀 API Request: ${options.method} ${options.path}');
            debugPrint('📤 Headers: ${options.headers}');
            if (options.data != null) {
              debugPrint('📤 Data: ${options.data}');
            }
            if (options.queryParameters.isNotEmpty) {
              debugPrint('📤 Query: ${options.queryParameters}');
            }
          }

          handler.next(options);
        },

        onResponse: (response, handler) {
          // Log response in debug mode
          if (kDebugMode) {
            debugPrint(
              '✅ API Response: ${response.statusCode} ${response.requestOptions.path}',
            );
            debugPrint('📥 Data: ${response.data}');
          }

          // Handle response wrapper
          if (response.data is Map<String, dynamic>) {
            final data = response.data as Map<String, dynamic>;

            // Check for API-level errors
            if (data.containsKey('error') && data['error'] == true) {
              throw ApiException(
                message: data['message'] ?? 'Unknown API error',
                statusCode: response.statusCode ?? 0,
                errorCode: data['code'],
              );
            }
          }

          handler.next(response);
        },

        onError: (error, handler) async {
          // Log error in debug mode
          if (kDebugMode) {
            debugPrint('❌ API Error: ${error.message}');
            debugPrint('❌ Response: ${error.response?.data}');
          }

          // Handle specific error cases
          if (error.response?.statusCode == 401) {
            // Unauthorized - try to refresh token
            final refreshed = await _refreshAuthToken();
            if (refreshed) {
              // Retry the original request
              final options = error.requestOptions;
              options.headers['Authorization'] = 'Bearer $_authToken';

              try {
                final response = await _dio.fetch(options);
                handler.resolve(response);
                return;
              } catch (e) {
                // If retry fails, continue with error
              }
            }

            // Clear invalid token and redirect to login
            await _clearAuthToken();
          }

          // Transform DioError to ApiException
          final apiException = _transformError(error);
          handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              error: apiException,
              type: error.type,
            ),
          );
        },
      ),
    );

    // Add logging interceptor for detailed debugging
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: false,
          responseHeader: false,
        ),
      );
    }
  }

  /// GET request
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return _extractData(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// POST request
  Future<Map<String, dynamic>> post(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return _extractData(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT request
  Future<Map<String, dynamic>> put(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return _extractData(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE request
  Future<Map<String, dynamic>> delete(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.delete(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return _extractData(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// PATCH request
  Future<Map<String, dynamic>> patch(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.patch(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return _extractData(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Upload file
  Future<Map<String, dynamic>> uploadFile(
    String endpoint,
    String filePath, {
    String fieldName = 'file',
    Map<String, dynamic>? additionalData,
    ProgressCallback? onProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      final formData = FormData();

      // Add file
      formData.files.add(
        MapEntry(fieldName, await MultipartFile.fromFile(filePath)),
      );

      // Add additional data
      if (additionalData != null) {
        additionalData.forEach((key, value) {
          formData.fields.add(MapEntry(key, value.toString()));
        });
      }

      final response = await _dio.post(
        endpoint,
        data: formData,
        onSendProgress: onProgress,
        cancelToken: cancelToken,
      );

      return _extractData(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Download file
  Future<void> downloadFile(
    String url,
    String savePath, {
    ProgressCallback? onProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      await _dio.download(
        url,
        savePath,
        onReceiveProgress: onProgress,
        cancelToken: cancelToken,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Set authentication token
  Future<void> setAuthToken(String token) async {
    _authToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyUserToken, token);
    debugPrint('Auth token set and saved');
  }

  /// Clear authentication token
  Future<void> clearAuthToken() async {
    await _clearAuthToken();
  }

  /// Get current auth token
  String? get authToken => _authToken;

  /// Check if user is authenticated
  bool get isAuthenticated => _authToken != null && _authToken!.isNotEmpty;

  /// Load auth token from storage
  Future<void> _loadAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _authToken = prefs.getString(AppConstants.keyUserToken);
      if (_authToken != null) {
        debugPrint('Auth token loaded from storage');
      }
    } catch (e) {
      debugPrint('Failed to load auth token: $e');
    }
  }

  /// Clear auth token from storage
  Future<void> _clearAuthToken() async {
    _authToken = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.keyUserToken);
      debugPrint('Auth token cleared');
    } catch (e) {
      debugPrint('Failed to clear auth token: $e');
    }
  }

  /// Refresh authentication token
  Future<bool> _refreshAuthToken() async {
    try {
      // TODO: Implement token refresh logic based on your backend
      // This is a placeholder implementation

      final response = await _dio.post(AppConstants.refreshTokenEndpoint);
      final data = _extractData(response);

      if (data.containsKey('token')) {
        await setAuthToken(data['token']);
        return true;
      }
    } catch (e) {
      debugPrint('Token refresh failed: $e');
    }
    return false;
  }

  /// Extract data from response
  Map<String, dynamic> _extractData(Response response) {
    if (response.data is Map<String, dynamic>) {
      return response.data as Map<String, dynamic>;
    } else if (response.data is List) {
      return {'data': response.data};
    } else {
      return {'data': response.data};
    }
  }

  /// Transform DioError to ApiException
  ApiException _transformError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException(
          message: AppConstants.errorTimeout,
          statusCode: 0,
          errorType: ApiErrorType.timeout,
        );

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode ?? 0;
        String message = AppConstants.errorGeneric;

        if (error.response?.data is Map<String, dynamic>) {
          final data = error.response!.data as Map<String, dynamic>;
          message = data['message'] ?? message;
        }

        return ApiException(
          message: message,
          statusCode: statusCode,
          errorType: _getErrorTypeFromStatusCode(statusCode),
          errorCode: error.response?.data?['code'],
        );

      case DioExceptionType.cancel:
        return const ApiException(
          message: 'Request was cancelled',
          statusCode: 0,
          errorType: ApiErrorType.cancelled,
        );

      case DioExceptionType.connectionError:
        return const ApiException(
          message: AppConstants.errorNetwork,
          statusCode: 0,
          errorType: ApiErrorType.network,
        );

      default:
        return ApiException(
          message: error.message ?? AppConstants.errorGeneric,
          statusCode: 0,
          errorType: ApiErrorType.unknown,
        );
    }
  }

  /// Handle and throw appropriate error
  Never _handleError(dynamic error) {
    if (error is ApiException) {
      throw error;
    } else if (error is DioException) {
      throw _transformError(error);
    } else {
      throw ApiException(
        message: error.toString(),
        statusCode: 0,
        errorType: ApiErrorType.unknown,
      );
    }
  }

  /// Get error type from HTTP status code
  ApiErrorType _getErrorTypeFromStatusCode(int statusCode) {
    if (statusCode >= 400 && statusCode < 500) {
      switch (statusCode) {
        case 401:
          return ApiErrorType.unauthorized;
        case 403:
          return ApiErrorType.forbidden;
        case 404:
          return ApiErrorType.notFound;
        case 422:
          return ApiErrorType.validation;
        default:
          return ApiErrorType.clientError;
      }
    } else if (statusCode >= 500) {
      return ApiErrorType.serverError;
    } else {
      return ApiErrorType.unknown;
    }
  }

  /// Generate unique request ID
  String _generateRequestId() {
    return '${DateTime.now().millisecondsSinceEpoch}-${_generateRandomString(6)}';
  }

  /// Generate random string
  String _generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(
      length,
      (index) =>
          chars[(DateTime.now().millisecondsSinceEpoch + index) % chars.length],
    ).join();
  }

  /// Cancel all requests
  void cancelAllRequests() {
    _dio.close();
  }

  /// Get request statistics
  Map<String, dynamic> getStats() {
    return {
      'baseUrl': _dio.options.baseUrl,
      'isAuthenticated': isAuthenticated,
      'hasAuthToken': _authToken != null,
      'interceptorsCount': _dio.interceptors.length,
    };
  }
}

/// Custom API exception
class ApiException implements Exception {
  final String message;
  final int statusCode;
  final ApiErrorType errorType;
  final String? errorCode;
  final Map<String, dynamic>? details;

  const ApiException({
    required this.message,
    required this.statusCode,
    this.errorType = ApiErrorType.unknown,
    this.errorCode,
    this.details,
  });

  @override
  String toString() {
    return 'ApiException: $message (Status: $statusCode, Type: $errorType)';
  }

  /// Check if error is recoverable
  bool get isRecoverable {
    return errorType == ApiErrorType.network ||
        errorType == ApiErrorType.timeout ||
        statusCode >= 500;
  }

  /// Get user-friendly error message
  String get userMessage {
    switch (errorType) {
      case ApiErrorType.network:
        return AppConstants.errorNetwork;
      case ApiErrorType.timeout:
        return AppConstants.errorTimeout;
      case ApiErrorType.unauthorized:
        return AppConstants.errorUnauthorized;
      case ApiErrorType.notFound:
        return AppConstants.errorNotFound;
      case ApiErrorType.serverError:
        return AppConstants.errorServerError;
      case ApiErrorType.validation:
        return details?['errors']?.join(', ') ?? AppConstants.errorInvalidInput;
      default:
        return message.isNotEmpty ? message : AppConstants.errorGeneric;
    }
  }
}

/// API error types
enum ApiErrorType {
  network,
  timeout,
  unauthorized,
  forbidden,
  notFound,
  validation,
  clientError,
  serverError,
  cancelled,
  unknown,
}

/// Singleton pattern helper
mixin SingletonMixin {
  static final Map<Type, dynamic> _instances = {};

  static T getInstance<T>(T Function() constructor) {
    if (!_instances.containsKey(T)) {
      _instances[T] = constructor();
    }
    return _instances[T] as T;
  }
}

/// Request cancellation helper
class CancelTokenManager {
  static final Map<String, CancelToken> _tokens = {};

  static CancelToken createToken(String key) {
    cancelToken(key);
    final token = CancelToken();
    _tokens[key] = token;
    return token;
  }

  static void cancelToken(String key) {
    final token = _tokens[key];
    if (token != null && !token.isCancelled) {
      token.cancel();
    }
    _tokens.remove(key);
  }

  static void cancelAll() {
    for (final token in _tokens.values) {
      if (!token.isCancelled) {
        token.cancel();
      }
    }
    _tokens.clear();
  }
}
