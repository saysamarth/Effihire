// location_service.dart
import 'dart:async';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/foundation.dart';

enum LocationState { loading, success, error }

enum LocationError {
  permissionDenied,
  permissionDeniedForever, 
  serviceDisabled,
  noInternet,
  timeout,
  unknown
}

class LocationResult {
  final bool success;
  final Position? position;
  final String? address;
  final LocationError? error;

  const LocationResult({
    required this.success,
    this.position,
    this.address,
    this.error,
  });
}

class LocationService {
  static Position? _currentPosition;
  static String? _currentAddress;
  static Completer<LocationResult>? _locationCompleter;
  
  // Cache for internet connectivity check
  static DateTime? _lastInternetCheck;
  static bool? _lastInternetResult;
  static const Duration _internetCacheTimeout = Duration(seconds: 30);

  // Getters for accessing location data throughout the app
  static Position? get currentPosition => _currentPosition;
  static String? get currentAddress => _currentAddress;
  static bool get hasLocation => _currentPosition != null;

  static Future<LocationResult> getCurrentLocation() async {
    // Prevent multiple simultaneous location requests
    if (_locationCompleter != null && !_locationCompleter!.isCompleted) {
      return _locationCompleter!.future;
    }
    
    _locationCompleter = Completer<LocationResult>();
    
    try {
      // Check internet connectivity with caching
      if (!await _hasInternetConnection()) {
        final result = const LocationResult(success: false, error: LocationError.noInternet);
        _locationCompleter!.complete(result);
        return result;
      }

      // Check location services
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        final result = const LocationResult(success: false, error: LocationError.serviceDisabled);
        _locationCompleter!.complete(result);
        return result;
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          final result = const LocationResult(success: false, error: LocationError.permissionDenied);
          _locationCompleter!.complete(result);
          return result;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        final result = const LocationResult(success: false, error: LocationError.permissionDeniedForever);
        _locationCompleter!.complete(result);
        return result;
      }

      // Get position with timeout and better accuracy settings
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      ).timeout(
        const Duration(seconds: 20),
        onTimeout: () => throw TimeoutException('Location request timed out', const Duration(seconds: 20)),
      );

      // Get address from coordinates with timeout
      String address = await _getAddressFromCoordinates(position).timeout(
        const Duration(seconds: 10),
        onTimeout: () => 'Location found',
      );

      // Store the location data
      _currentPosition = position;
      _currentAddress = address;

      final result = LocationResult(
        success: true,
        position: position,
        address: address,
      );
      
      _locationCompleter!.complete(result);
      return result;

    } on TimeoutException {
      const result = LocationResult(success: false, error: LocationError.timeout);
      if (!_locationCompleter!.isCompleted) {
        _locationCompleter!.complete(result);
      }
      return result;
    } catch (e) {
      debugPrint('Location error: $e');
      const result = LocationResult(success: false, error: LocationError.unknown);
      if (!_locationCompleter!.isCompleted) {
        _locationCompleter!.complete(result);
      }
      return result;
    } finally {
      _locationCompleter = null;
    }
  }

  static Future<String> _getAddressFromCoordinates(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        return _formatAddress(place);
      }
    } catch (e) {
      debugPrint('Geocoding error: $e');
    }
    return 'Location found';
  }

  static String _formatAddress(Placemark place) {
    List<String> addressParts = [];
    
    if (place.name?.isNotEmpty == true) {
      addressParts.add(place.name!);
    }
    if (place.locality?.isNotEmpty == true) {
      addressParts.add(place.locality!);
    }
    if (place.administrativeArea?.isNotEmpty == true) {
      addressParts.add(place.administrativeArea!);
    }

    return addressParts.take(2).join(', ').isEmpty ? 'Location found' : addressParts.take(2).join(', ');
  }

  static Future<bool> _hasInternetConnection() async {
    // Use cached result if it's still valid
    if (_lastInternetCheck != null && 
        _lastInternetResult != null && 
        DateTime.now().difference(_lastInternetCheck!) < _internetCacheTimeout) {
      return _lastInternetResult!;
    }

    try {
      final result = await InternetAddress.lookup('google.com').timeout(
        const Duration(seconds: 5),
      );
      final hasConnection = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      
      // Cache the result
      _lastInternetCheck = DateTime.now();
      _lastInternetResult = hasConnection;
      
      return hasConnection;
    } on SocketException catch (_) {
      _lastInternetCheck = DateTime.now();
      _lastInternetResult = false;
      return false;
    } on TimeoutException catch (_) {
      _lastInternetCheck = DateTime.now();
      _lastInternetResult = false;
      return false;
    }
  }

  // Method to update location (for when user moves to new location)
  static Future<LocationResult> updateLocation() async {
    // Clear cache to force fresh location request
    _currentPosition = null;
    _currentAddress = null;
    _lastInternetCheck = null;
    _lastInternetResult = null;
    
    return await getCurrentLocation();
  }

  // Method to clear stored location
  static void clearLocation() {
    _currentPosition = null;
    _currentAddress = null;
    _lastInternetCheck = null;
    _lastInternetResult = null;
  }

  // Method to get cached location without making new request
  static LocationResult? getCachedLocation() {
    if (_currentPosition != null) {
      return LocationResult(
        success: true,
        position: _currentPosition,
        address: _currentAddress,
      );
    }
    return null;
  }
}