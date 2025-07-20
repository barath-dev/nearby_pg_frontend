// lib/core/services/location_service.dart
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../constants/app_constants.dart';

/// Service for handling location-related operations
class LocationService {
  Position? _currentPosition;
  String _currentLocationName = 'Unknown location';
  bool _locationPermissionGranted = false;

  /// Get the current position (lat/long)
  Position? get currentPosition => _currentPosition;

  /// Get the current location name (address)
  String get currentLocationName => _currentLocationName;

  /// Check if location permission is granted
  bool get isLocationPermissionGranted => _locationPermissionGranted;

  /// Initialize the location service
  Future<void> initialize() async {
    try {
      _locationPermissionGranted = await _checkPermission();
      if (_locationPermissionGranted && AppConstants.enableLocationFeatures) {
        await getCurrentPosition();
      }
    } catch (e) {
      debugPrint('Error initializing location service: $e');
    }
  }

  /// Check if location permission is granted
  Future<bool> _checkPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  /// Request location permission from the user
  Future<bool> requestPermission() async {
    try {
      final permission = await Geolocator.requestPermission();
      _locationPermissionGranted =
          permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
      return _locationPermissionGranted;
    } catch (e) {
      debugPrint('Error requesting location permission: $e');
      return false;
    }
  }

  /// Get the current position from device GPS
  Future<Position?> getCurrentPosition() async {
    try {
      if (!_locationPermissionGranted) {
        _locationPermissionGranted = await requestPermission();
        if (!_locationPermissionGranted) {
          return null;
        }
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _currentPosition = position;
      await _getAddressFromLatLng(position);

      return position;
    } catch (e) {
      debugPrint('Error getting current position: $e');
      return null;
    }
  }

  /// Get address from latitude and longitude
  Future<void> _getAddressFromLatLng(Position position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        _currentLocationName = _formatAddress(place);
      }
    } catch (e) {
      debugPrint('Error getting address from lat/lng: $e');
    }
  }

  /// Format address from placemark
  String _formatAddress(Placemark placemark) {
    final locality = placemark.locality ?? '';
    final subLocality = placemark.subLocality ?? '';

    if (subLocality.isNotEmpty) {
      return '$subLocality, $locality';
    } else {
      return locality;
    }
  }

  /// Calculate distance between two coordinates in kilometers
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

  /// Get a list of nearby PGs based on current location
  Future<List<Map<String, dynamic>>> getNearbyPGs(double radiusInKm) async {
    // TODO: Implement real API call to get nearby PGs
    // For now, returning mock data
    return _getMockNearbyPGs(radiusInKm);
  }

  /// Mock method to get nearby PGs (for development)
  List<Map<String, dynamic>> _getMockNearbyPGs(double radiusInKm) {
    final currentLat = _currentPosition?.latitude ?? 28.6139;
    final currentLng = _currentPosition?.longitude ?? 77.2090;

    return List.generate(8, (index) {
      // Generate random coordinates within the radius
      final randomDistance = (index + 1) * 0.5; // km
      final randomLat =
          currentLat +
          (index % 2 == 0 ? 1 : -1) *
              (randomDistance / 111); // 1 degree ~ 111 km
      final randomLng =
          currentLng + (index % 3 == 0 ? 1 : -1) * (randomDistance / 111);

      return {
        'id': 'nearby_${index + 1}',
        'latitude': randomLat,
        'longitude': randomLng,
        'distance': randomDistance,
      };
    });
  }
}
