import 'dart:async';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/foundation.dart';
import 'location_state.dart';

class LocationResult {
  final bool success;
  final Position? position;
  final String? address;
  final LocationErrorType? errorType;

  const LocationResult({
    required this.success,
    this.position,
    this.address,
    this.errorType,
  });

  const LocationResult.success({
    required Position position,
    String? address,
  }) : this(
          success: true,
          position: position,
          address: address,
        );

  const LocationResult.error(LocationErrorType errorType)
      : this(
          success: false,
          errorType: errorType,
        );
}

class LocationService {
  DateTime? _lastInternetCheck;
  bool? _lastInternetResult;
  static const Duration _internetCacheTimeout = Duration(seconds: 30);
  
  Completer<LocationResult>? _locationCompleter;

  Future<LocationResult> getCurrentLocation() async {
    if (_locationCompleter != null && !_locationCompleter!.isCompleted) {
      return _locationCompleter!.future;
    }
    
    _locationCompleter = Completer<LocationResult>();
    
    try {
      if (!await _hasInternetConnection()) {
        const result = LocationResult.error(LocationErrorType.noInternet);
        _locationCompleter!.complete(result);
        return result;
      }

      if (!await Geolocator.isLocationServiceEnabled()) {
        const result = LocationResult.error(LocationErrorType.serviceDisabled);
        _locationCompleter!.complete(result);
        return result;
      }

      final permissionResult = await _handleLocationPermissions();
      if (!permissionResult.success) {
        _locationCompleter!.complete(permissionResult);
        return permissionResult;
      }

      final position = await _getCurrentPosition();
      final address = await _getAddressFromCoordinates(position);

      final result = LocationResult.success(
        position: position,
        address: address,
      );
      
      _locationCompleter!.complete(result);
      return result;

    } on TimeoutException catch (e) {
      debugPrint('Location timeout: $e');
      const result = LocationResult.error(LocationErrorType.timeout);
      if (!_locationCompleter!.isCompleted) {
        _locationCompleter!.complete(result);
      }
      return result;
    } catch (e) {
      debugPrint('Location service error: $e');
      const result = LocationResult.error(LocationErrorType.unknown);
      if (!_locationCompleter!.isCompleted) {
        _locationCompleter!.complete(result);
      }
      return result;
    } finally {
      _locationCompleter = null;
    }
  }

  Future<LocationResult> _handleLocationPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return const LocationResult.error(LocationErrorType.permissionDenied);
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return const LocationResult.error(LocationErrorType.permissionDeniedForever);
    }
    return const LocationResult(success: true);
  }

  Future<Position> _getCurrentPosition() async {
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 15),
    ).timeout(
      const Duration(seconds: 20),
      onTimeout: () => throw TimeoutException(
        'Location request timed out', 
        const Duration(seconds: 20),
      ),
    );
  }

  Future<String> _getAddressFromCoordinates(Position position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => <Placemark>[],
      );

      if (placemarks.isNotEmpty) {
        return _formatAddress(placemarks.first);
      }
    } catch (e) {
      debugPrint('Geocoding error: $e');
    }
    return 'Location found';
  }

  String _formatAddress(Placemark place) {
    final addressParts = <String>[];
    if (place.name?.isNotEmpty == true && place.name != place.locality) {
      addressParts.add(place.name!);
    }
    if (place.locality?.isNotEmpty == true) {
      addressParts.add(place.locality!);
    }
    if (place.administrativeArea?.isNotEmpty == true && 
        addressParts.length < 2) {
      addressParts.add(place.administrativeArea!);
    }

    final formattedAddress = addressParts.take(2).join(', ');
    return formattedAddress.isEmpty ? 'Location found' : formattedAddress;
  }

  Future<bool> _hasInternetConnection() async {
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
  void clearInternetCache() {
    _lastInternetCheck = null;
    _lastInternetResult = null;
  }
  void dispose() {
    _locationCompleter?.complete(
      const LocationResult.error(LocationErrorType.unknown),
    );
    _locationCompleter = null;
    clearInternetCache();
  }
}
