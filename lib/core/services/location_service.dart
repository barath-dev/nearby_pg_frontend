import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import constants
import '../constants/app_constants.dart';

/// Comprehensive location service for GPS, permissions, and geocoding
class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  // Location tracking
  Position? _currentPosition;
  String? _currentLocationName;
  LocationPermission? _currentPermission;
  StreamSubscription<Position>? _positionSubscription;

  // Location stream controller
  final StreamController<Position> _positionController =
      StreamController<Position>.broadcast();
  final StreamController<String> _locationNameController =
      StreamController<String>.broadcast();

  // Settings
  bool _isTrackingEnabled = false;
  double _lastKnownLatitude = AppConstants.defaultLatitude;
  double _lastKnownLongitude = AppConstants.defaultLongitude;

  // Getters
  Position? get currentPosition => _currentPosition;
  String? get currentLocationName => _currentLocationName;
  LocationPermission? get currentPermission => _currentPermission;
  bool get isTrackingEnabled => _isTrackingEnabled;
  double get lastKnownLatitude => _lastKnownLatitude;
  double get lastKnownLongitude => _lastKnownLongitude;

  // Streams
  Stream<Position> get positionStream => _positionController.stream;
  Stream<String> get locationNameStream => _locationNameController.stream;

  /// Initialize location service
  Future<void> initialize() async {
    await _loadLastKnownLocation();
    await _checkLocationServiceStatus();
    debugPrint('LocationService initialized');
  }

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      debugPrint('Error checking location service: $e');
      return false;
    }
  }

  /// Get current location permission status
  Future<LocationPermission> getPermissionStatus() async {
    try {
      _currentPermission = await Geolocator.checkPermission();
      return _currentPermission!;
    } catch (e) {
      debugPrint('Error checking permission: $e');
      return LocationPermission.denied;
    }
  }

  /// Request location permission
  Future<bool> requestPermission() async {
    try {
      // Check if location service is enabled
      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled');
        return false;
      }

      // Check current permission
      LocationPermission permission = await getPermissionStatus();

      // Request permission if denied
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        _currentPermission = permission;
      }

      // Handle permanently denied
      if (permission == LocationPermission.deniedForever) {
        debugPrint('Location permissions are permanently denied');
        return false;
      }

      // Check if permission is granted
      final isGranted =
          permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;

      if (isGranted) {
        debugPrint('Location permission granted: $permission');
      } else {
        debugPrint('Location permission denied: $permission');
      }

      return isGranted;
    } catch (e) {
      debugPrint('Error requesting permission: $e');
      return false;
    }
  }

  /// Get current position
  Future<Position?> getCurrentPosition({
    LocationAccuracy accuracy = LocationAccuracy.high,
    Duration? timeout,
  }) async {
    try {
      // Check permission first
      final hasPermission = await requestPermission();
      if (!hasPermission) {
        throw const LocationException('Location permission not granted');
      }

      // Get position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: accuracy,
        timeLimit: timeout ?? const Duration(seconds: 15),
      );

      _currentPosition = position;
      _lastKnownLatitude = position.latitude;
      _lastKnownLongitude = position.longitude;

      // Save last known location
      await _saveLastKnownLocation(position);

      // Emit position to stream
      _positionController.add(position);

      // Get location name
      _updateLocationName(position);

      debugPrint(
        'Current position: ${position.latitude}, ${position.longitude}',
      );
      return position;
    } catch (e) {
      debugPrint('Error getting current position: $e');

      // Return last known position if available
      if (_currentPosition != null) {
        return _currentPosition;
      }

      return null;
    }
  }

  /// Start continuous location tracking
  Future<bool> startLocationTracking({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 10, // meters
    Duration interval = const Duration(seconds: 5),
  }) async {
    try {
      // Check permission
      final hasPermission = await requestPermission();
      if (!hasPermission) {
        return false;
      }

      // Stop existing tracking
      await stopLocationTracking();

      // Configure location settings
      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      );

      // Start position stream
      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        (Position position) {
          _currentPosition = position;
          _lastKnownLatitude = position.latitude;
          _lastKnownLongitude = position.longitude;

          // Save location periodically
          _saveLastKnownLocation(position);

          // Emit to stream
          _positionController.add(position);

          // Update location name (debounced)
          _updateLocationName(position);

          debugPrint(
            'Position updated: ${position.latitude}, ${position.longitude}',
          );
        },
        onError: (error) {
          debugPrint('Location tracking error: $error');
        },
      );

      _isTrackingEnabled = true;
      debugPrint('Location tracking started');
      return true;
    } catch (e) {
      debugPrint('Error starting location tracking: $e');
      return false;
    }
  }

  /// Stop location tracking
  Future<void> stopLocationTracking() async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;
    _isTrackingEnabled = false;
    debugPrint('Location tracking stopped');
  }

  /// Get location name from coordinates
  Future<String?> getLocationName(double latitude, double longitude) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return _formatLocationName(place);
      }
    } catch (e) {
      debugPrint('Error getting location name: $e');
    }
    return null;
  }

  /// Get coordinates from location name
  Future<List<Location>> getCoordinatesFromName(String locationName) async {
    try {
      final locations = await locationFromAddress(locationName);
      debugPrint('Found ${locations.length} locations for: $locationName');
      return locations;
    } catch (e) {
      debugPrint('Error getting coordinates: $e');
      return [];
    }
  }

  /// Calculate distance between two points
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
          startLatitude,
          startLongitude,
          endLatitude,
          endLongitude,
        ) /
        1000; // Convert to kilometers
  }

  /// Calculate bearing between two points
  double calculateBearing(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.bearingBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Check if location is within radius
  bool isWithinRadius(
    double centerLatitude,
    double centerLongitude,
    double targetLatitude,
    double targetLongitude,
    double radiusInKm,
  ) {
    final distance = calculateDistance(
      centerLatitude,
      centerLongitude,
      targetLatitude,
      targetLongitude,
    );
    return distance <= radiusInKm;
  }

  /// Get nearby locations within radius
  List<LocationPoint> filterLocationsByRadius(
    List<LocationPoint> locations,
    double centerLatitude,
    double centerLongitude,
    double radiusInKm,
  ) {
    return locations.where((location) {
      return isWithinRadius(
        centerLatitude,
        centerLongitude,
        location.latitude,
        location.longitude,
        radiusInKm,
      );
    }).toList();
  }

  /// Sort locations by distance from center
  List<LocationPoint> sortLocationsByDistance(
    List<LocationPoint> locations,
    double centerLatitude,
    double centerLongitude,
  ) {
    // Add distance to each location
    for (final location in locations) {
      location.distanceFromCenter = calculateDistance(
        centerLatitude,
        centerLongitude,
        location.latitude,
        location.longitude,
      );
    }

    // Sort by distance
    locations.sort(
      (a, b) => a.distanceFromCenter!.compareTo(b.distanceFromCenter!),
    );
    return locations;
  }

  /// Open location settings
  Future<bool> openLocationSettings() async {
    try {
      return await Geolocator.openLocationSettings();
    } catch (e) {
      debugPrint('Error opening location settings: $e');
      return false;
    }
  }

  /// Open app settings
  Future<bool> openAppSettings() async {
    try {
      return await Geolocator.openAppSettings();
    } catch (e) {
      debugPrint('Error opening app settings: $e');
      return false;
    }
  }

  /// Get location accuracy description
  String getAccuracyDescription(LocationAccuracy accuracy) {
    switch (accuracy) {
      case LocationAccuracy.lowest:
        return 'Lowest (~3000m)';
      case LocationAccuracy.low:
        return 'Low (~1000m)';
      case LocationAccuracy.medium:
        return 'Medium (~100m)';
      case LocationAccuracy.high:
        return 'High (~10m)';
      case LocationAccuracy.best:
        return 'Best (~3m)';
      case LocationAccuracy.bestForNavigation:
        return 'Navigation (~1m)';
      default:
        return 'Unknown';
    }
  }

  /// Format location name from placemark
  String _formatLocationName(Placemark place) {
    final parts = <String>[];

    if (place.locality?.isNotEmpty == true) {
      parts.add(place.locality!);
    }

    if (place.administrativeArea?.isNotEmpty == true &&
        place.administrativeArea != place.locality) {
      parts.add(place.administrativeArea!);
    }

    if (place.country?.isNotEmpty == true && parts.length < 2) {
      parts.add(place.country!);
    }

    return parts.isNotEmpty ? parts.join(', ') : 'Unknown Location';
  }

  /// Update location name (debounced)
  Timer? _locationNameTimer;
  void _updateLocationName(Position position) {
    _locationNameTimer?.cancel();
    _locationNameTimer = Timer(const Duration(seconds: 2), () async {
      final name = await getLocationName(position.latitude, position.longitude);
      if (name != null) {
        _currentLocationName = name;
        _locationNameController.add(name);
        debugPrint('Location name updated: $name');
      }
    });
  }

  /// Save last known location to storage
  Future<void> _saveLastKnownLocation(Position position) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        AppConstants.keyLastLocation,
        '${position.latitude},${position.longitude}',
      );
      debugPrint('Last location saved');
    } catch (e) {
      debugPrint('Error saving location: $e');
    }
  }

  /// Load last known location from storage
  Future<void> _loadLastKnownLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final locationString = prefs.getString(AppConstants.keyLastLocation);

      if (locationString != null) {
        final parts = locationString.split(',');
        if (parts.length == 2) {
          _lastKnownLatitude = double.parse(parts[0]);
          _lastKnownLongitude = double.parse(parts[1]);
          debugPrint(
            'Last location loaded: $_lastKnownLatitude, $_lastKnownLongitude',
          );
        }
      }
    } catch (e) {
      debugPrint('Error loading last location: $e');
    }
  }

  /// Check location service status
  Future<void> _checkLocationServiceStatus() async {
    final serviceEnabled = await isLocationServiceEnabled();
    final permission = await getPermissionStatus();

    debugPrint('Location service enabled: $serviceEnabled');
    debugPrint('Location permission: $permission');
  }

  /// Get location service status summary
  Future<LocationServiceStatus> getServiceStatus() async {
    final serviceEnabled = await isLocationServiceEnabled();
    final permission = await getPermissionStatus();

    return LocationServiceStatus(
      serviceEnabled: serviceEnabled,
      permission: permission,
      hasValidPosition: _currentPosition != null,
      isTracking: _isTrackingEnabled,
    );
  }

  /// Dispose resources
  void dispose() {
    _positionSubscription?.cancel();
    _locationNameTimer?.cancel();
    _positionController.close();
    _locationNameController.close();
    debugPrint('LocationService disposed');
  }
}

/// Location point model
class LocationPoint {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String? address;
  final Map<String, dynamic>? metadata;
  double? distanceFromCenter;

  LocationPoint({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.address,
    this.metadata,
    this.distanceFromCenter,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'metadata': metadata,
      'distanceFromCenter': distanceFromCenter,
    };
  }

  factory LocationPoint.fromJson(Map<String, dynamic> json) {
    return LocationPoint(
      id: json['id'],
      name: json['name'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      address: json['address'],
      metadata: json['metadata'],
      distanceFromCenter: json['distanceFromCenter']?.toDouble(),
    );
  }
}

/// Location service status
class LocationServiceStatus {
  final bool serviceEnabled;
  final LocationPermission permission;
  final bool hasValidPosition;
  final bool isTracking;

  const LocationServiceStatus({
    required this.serviceEnabled,
    required this.permission,
    required this.hasValidPosition,
    required this.isTracking,
  });

  bool get isFullyEnabled {
    return serviceEnabled &&
        (permission == LocationPermission.whileInUse ||
            permission == LocationPermission.always);
  }

  bool get canGetLocation {
    return serviceEnabled &&
        permission != LocationPermission.denied &&
        permission != LocationPermission.deniedForever;
  }

  String get statusMessage {
    if (!serviceEnabled) {
      return 'Location services are disabled';
    } else if (permission == LocationPermission.denied) {
      return 'Location permission denied';
    } else if (permission == LocationPermission.deniedForever) {
      return 'Location permission permanently denied';
    } else if (!hasValidPosition) {
      return 'Getting location...';
    } else {
      return 'Location services ready';
    }
  }
}

/// Location exception
class LocationException implements Exception {
  final String message;
  final String? code;

  const LocationException(this.message, [this.code]);

  @override
  String toString() => 'LocationException: $message';
}

/// Location utilities
class LocationUtils {
  /// Convert degrees to radians
  static double degToRad(double degrees) {
    return degrees * (pi / 180);
  }

  /// Convert radians to degrees
  static double radToDeg(double radians) {
    return radians * (180 / pi);
  }

  /// Get cardinal direction from bearing
  static String getCardinalDirection(double bearing) {
    const directions = [
      'N',
      'NNE',
      'NE',
      'ENE',
      'E',
      'ESE',
      'SE',
      'SSE',
      'S',
      'SSW',
      'SW',
      'WSW',
      'W',
      'WNW',
      'NW',
      'NNW',
    ];

    final index = ((bearing + 11.25) / 22.5).floor() % 16;
    return directions[index];
  }

  /// Format distance for display
  static String formatDistance(double distanceInKm) {
    if (distanceInKm < 1) {
      return '${(distanceInKm * 1000).round()}m';
    } else if (distanceInKm < 10) {
      return '${distanceInKm.toStringAsFixed(1)}km';
    } else {
      return '${distanceInKm.round()}km';
    }
  }

  /// Validate coordinates
  static bool isValidCoordinates(double latitude, double longitude) {
    return latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180;
  }

  /// Generate random location within radius
  static LocationPoint generateRandomLocationNear(
    double centerLat,
    double centerLng,
    double radiusKm,
    String name,
  ) {
    final random = Random();
    final radiusInDegrees = radiusKm / 111.32; // Rough conversion

    final angle = random.nextDouble() * 2 * pi;
    final distance = random.nextDouble() * radiusInDegrees;

    final deltaLat = distance * cos(angle);
    final deltaLng = distance * sin(angle);

    return LocationPoint(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      latitude: centerLat + deltaLat,
      longitude: centerLng + deltaLng,
    );
  }
}
