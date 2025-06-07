// location_cubit.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';
import 'location_state.dart';
import 'location_service.dart';

/// LocationCubit manages all location-related state and business logic
/// Optimized to prevent memory leaks and improve performance
class LocationCubit extends Cubit<LocationState> {
  LocationCubit(this._locationService) : super(const LocationInitial());

  final LocationService _locationService;
  
  // Private fields for caching - no more static variables!
  Position? _currentPosition;
  String? _currentAddress;
  Timer? _autoNavigationTimer;

  /// Public getters for accessing location data from other screens
  Position? get currentPosition => _currentPosition;
  String? get currentAddress => _currentAddress;
  bool get hasLocation => _currentPosition != null;

  /// Main method to get current location with comprehensive error handling
  Future<void> getCurrentLocation() async {
    // Prevent multiple simultaneous requests
    if (state is LocationLoading) return;

    emit(const LocationLoading());

    try {
      final result = await _locationService.getCurrentLocation();
      
      if (result.success && result.position != null) {
        // Cache the successful result
        _currentPosition = result.position;
        _currentAddress = result.address;
        
        emit(LocationSuccess(
          position: result.position!,
          address: result.address ?? 'Location acquired',
        ));

        // Auto-navigate after success with cleanup timer
        _startAutoNavigationTimer();
      } else {
        _handleLocationError(result.errorType!);
      }
    } catch (e) {
      debugPrint('LocationCubit error: $e');
      _handleLocationError(LocationErrorType.unknown);
    }
  }

  /// Handle different types of location errors with appropriate UI messages
  void _handleLocationError(LocationErrorType errorType) {
    late LocationError errorState;
    
    switch (errorType) {
      case LocationErrorType.permissionDenied:
        errorState = const LocationError(
          errorType: LocationErrorType.permissionDenied,
          title: 'Location permission needed',
          message: 'We need location access to show you nearby delivery tasks',
          needsSettings: false,
        );
        break;
        
      case LocationErrorType.permissionDeniedForever:
        errorState = const LocationError(
          errorType: LocationErrorType.permissionDeniedForever,
          title: 'Location access blocked',
          message: 'Please enable location permission in settings to continue',
          needsSettings: true,
        );
        break;
        
      case LocationErrorType.serviceDisabled:
        errorState = const LocationError(
          errorType: LocationErrorType.serviceDisabled,
          title: 'Location services disabled',
          message: 'Please turn on location services to find delivery tasks near you',
          needsSettings: true,
        );
        break;
        
      case LocationErrorType.noInternet:
        errorState = const LocationError(
          errorType: LocationErrorType.noInternet,
          title: 'No internet connection',
          message: 'Please check your internet connection and try again',
          needsSettings: false,
        );
        break;
        
      case LocationErrorType.timeout:
        errorState = const LocationError(
          errorType: LocationErrorType.timeout,
          title: 'Location request timed out',
          message: 'Unable to get your location. Please try again',
          needsSettings: false,
        );
        break;
        
      case LocationErrorType.unknown:
      default:
        errorState = const LocationError(
          errorType: LocationErrorType.unknown,
          title: 'Something went wrong',
          message: 'Unable to get your location. Please try again',
          needsSettings: false,
        );
        break;
    }
    
    emit(errorState);
  }

  /// Start timer for auto-navigation after successful location acquisition
  void _startAutoNavigationTimer() {
    _autoNavigationTimer?.cancel();
    _autoNavigationTimer = Timer(const Duration(milliseconds: 1500), () {
      // Timer completed - UI can listen to this or handle navigation elsewhere
      debugPrint('Auto-navigation timer completed');
    });
  }

  /// Update location - useful when user moves to a new location
  Future<void> updateLocation() async {
    // Clear cache
    _currentPosition = null;
    _currentAddress = null;
    
    await getCurrentLocation();
  }

  /// Clear all location data
  void clearLocation() {
    _currentPosition = null;
    _currentAddress = null;
    _autoNavigationTimer?.cancel();
    emit(const LocationInitial());
  }

  /// Get cached location without making a new request
  LocationState? getCachedLocationState() {
    if (_currentPosition != null && _currentAddress != null) {
      return LocationSuccess(
        position: _currentPosition!,
        address: _currentAddress!,
      );
    }
    return null;
  }

  /// Check if user needs to open settings based on current error
  bool shouldShowSettingsButton() {
    return state is LocationError && (state as LocationError).needsSettings;
  }

  /// Reset to initial state
  void reset() {
    _autoNavigationTimer?.cancel();
    emit(const LocationInitial());
  }

  @override
  Future<void> close() {
    // Clean up timer to prevent memory leaks
    _autoNavigationTimer?.cancel();
    return super.close();
  }
}