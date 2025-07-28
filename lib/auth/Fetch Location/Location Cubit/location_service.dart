import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

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

  const LocationResult.success({required Position position, String? address})
    : this(success: true, position: position, address: address);

  const LocationResult.error(LocationErrorType errorType)
    : this(success: false, errorType: errorType);
}

class LocationService {
  static final String _googleMapsApiKey = dotenv.env['GOOGLE_MAPS_API_KEY']!;
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
      return const LocationResult.error(
        LocationErrorType.permissionDeniedForever,
      );
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
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?'
        'latlng=${position.latitude},${position.longitude}&'
        'key=$_googleMapsApiKey',
      );

      final response = await http
          .get(url)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => http.Response('{"status": "TIMEOUT"}', 408),
          );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          return _formatGoogleMapsAddress(data['results'][0]);
        } else {
          debugPrint('Geocoding API error: ${data['status']}');
        }
      } else {
        debugPrint('HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Geocoding error: $e');
    }
    return 'Location found';
  }

  String _formatGoogleMapsAddress(Map<String, dynamic> result) {
    try {
      final addressComponents = result['address_components'] as List<dynamic>;
      final addressParts = <String>[];

      // Extract relevant components
      String? locality;
      String? sublocality;
      String? administrativeArea;
      String? route;

      for (final component in addressComponents) {
        final types = List<String>.from(component['types']);
        final longName = component['long_name'] as String;

        if (types.contains('locality')) {
          locality = longName;
        } else if (types.contains('sublocality') ||
            types.contains('sublocality_level_1')) {
          sublocality = longName;
        } else if (types.contains('administrative_area_level_1')) {
          administrativeArea = longName;
        } else if (types.contains('route')) {
          route = longName;
        }
      }

      // Build address with priority: route -> sublocality -> locality -> admin area
      if (route?.isNotEmpty == true) {
        addressParts.add(route!);
      }
      if (sublocality?.isNotEmpty == true && sublocality != locality) {
        addressParts.add(sublocality!);
      }
      if (locality?.isNotEmpty == true) {
        addressParts.add(locality!);
      }
      if (administrativeArea?.isNotEmpty == true && addressParts.length < 2) {
        addressParts.add(administrativeArea!);
      }

      final formattedAddress = addressParts.take(2).join(', ');
      return formattedAddress.isEmpty ? 'Location found' : formattedAddress;
    } catch (e) {
      debugPrint('Error formatting address: $e');
      return result['formatted_address'] ?? 'Location found';
    }
  }

  Future<bool> _hasInternetConnection() async {
    if (_lastInternetCheck != null &&
        _lastInternetResult != null &&
        DateTime.now().difference(_lastInternetCheck!) <
            _internetCacheTimeout) {
      return _lastInternetResult!;
    }
    try {
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 5));
      final hasConnection =
          result.isNotEmpty && result[0].rawAddress.isNotEmpty;
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
