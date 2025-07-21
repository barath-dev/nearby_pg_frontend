// lib/core/services/location_service.dart

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

/// Service for handling location functionality
class LocationService {
  // Internal cache for place names to reduce API calls
  final Map<String, String> _placeNameCache = {};

  String currentLocationName = '';

  /// Check if location permission is granted
  Future<bool> checkPermission() async {
    try {
      LocationPermission permission;

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Handle case where location services are disabled
        debugPrint('Location services are disabled');
        return false;
      }

      // Check if we have permission
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        // Request permission
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Permission denied
          debugPrint('Location permission denied');
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Permission denied permanently
        debugPrint('Location permission permanently denied');
        return false;
      }

      // Permission granted
      return true;
    } catch (e) {
      debugPrint('Error checking location permission: $e');
      return false;
    }
  }

  /// Get the current position with graceful error handling
  Future<Position?> getCurrentPosition() async {
    try {
      // First check permission
      final hasPermission = await checkPermission();
      if (!hasPermission) {
        return null;
      }

      // Get current position with high accuracy
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      debugPrint('Error getting current position: $e');

      // Try with lower accuracy as fallback
      try {
        return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low,
          timeLimit: const Duration(seconds: 5),
        );
      } catch (e) {
        debugPrint('Error getting position with low accuracy: $e');
        return getLastKnownPosition();
      }
    }
  }

  /// Get last known position as fallback
  Future<Position?> getLastKnownPosition() async {
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (e) {
      debugPrint('Error getting last known position: $e');
      return null;
    }
  }

  /// Calculate distance between two coordinates in kilometers
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    try {
      return Geolocator.distanceBetween(
            startLatitude,
            startLongitude,
            endLatitude,
            endLongitude,
          ) /
          1000; // Convert to kilometers
    } catch (e) {
      debugPrint('Error calculating distance: $e');
      // Return a very large distance as fallback
      return double.infinity;
    }
  }

  /// Determine if location is enabled for the platform
  Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      debugPrint('Error checking location service status: $e');
      return false;
    }
  }

  /// Get address from coordinates (reverse geocoding)
  Future<String?> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      // Check cache first
      final cacheKey = '$latitude,$longitude';
      if (_placeNameCache.containsKey(cacheKey)) {
        return _placeNameCache[cacheKey];
      }

      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        final address = _formatAddress(placemark);

        // Cache the result
        _placeNameCache[cacheKey] = address;

        return address;
      }
    } catch (e) {
      debugPrint('Error getting address from coordinates: $e');
    }

    return null;
  }

  /// Get coordinates from address (geocoding)
  Future<Position?> getCoordinatesFromAddress(String address) async {
    try {
      final locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        final location = locations.first;
        return Position(
          latitude: location.latitude,
          longitude: location.longitude,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );
      }
    } catch (e) {
      debugPrint('Error getting coordinates from address: $e');
    }

    return null;
  }

  /// Format address from placemark
  String _formatAddress(Placemark placemark) {
    // Create a list of address components
    final components = <String>[];

    if (placemark.subLocality?.isNotEmpty == true) {
      components.add(placemark.subLocality!);
    }

    if (placemark.locality?.isNotEmpty == true) {
      components.add(placemark.locality!);
    }

    if (placemark.administrativeArea?.isNotEmpty == true &&
        placemark.administrativeArea != placemark.locality) {
      components.add(placemark.administrativeArea!);
    }

    // Join components with commas
    return components.join(', ');
  }

  /// Get nearby locations based on user's current location
  Future<List<String>> getNearbyLocations() async {
    try {
      final position = await getCurrentPosition();
      if (position == null) return [];

      // For a real implementation, this would call an API
      // For now, return some mock nearby locations
      return [
        'Current Location',
        'Nearby Area 1',
        'Nearby Area 2',
        'Nearby Area 3',
      ];
    } catch (e) {
      debugPrint('Error getting nearby locations: $e');
      return [];
    }
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

  /// Open app settings (for when location permission is denied forever)
  Future<bool> openAppSettings() async {
    try {
      return await Geolocator.openAppSettings();
    } catch (e) {
      debugPrint('Error opening app settings: $e');
      return false;
    }
  }
}
