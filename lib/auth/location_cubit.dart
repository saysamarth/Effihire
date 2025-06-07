import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';
import 'location_state.dart';
import 'location_service.dart';

class LocationCubit extends Cubit<LocationState> {
  LocationCubit(this._locationService) : super(const LocationInitial());
  final LocationService _locationService;
  Position? _currentPosition;
  String? _currentAddress;
  Timer? _autoNavigationTimer;

  Position? get currentPosition => _currentPosition;
  String? get currentAddress => _currentAddress;
  bool get hasLocation => _currentPosition != null;


  Future<void> getCurrentLocation() async {
    if (state is LocationLoading) return;
    emit(const LocationLoading());

    try {
      final result = await _locationService.getCurrentLocation();
      
      if (result.success && result.position != null) {
        _currentPosition = result.position;
        _currentAddress = result.address;
        
        emit(LocationSuccess(
          position: result.position!,
          address: result.address ?? 'Location acquired',
        ));
        _startAutoNavigationTimer();
      } else {
        _handleLocationError(result.errorType!);
      }
    } catch (e) {
      debugPrint('LocationCubit error: $e');
      _handleLocationError(LocationErrorType.unknown);
    }
  }

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
    }
    
    emit(errorState);
  }

  void _startAutoNavigationTimer() {
    _autoNavigationTimer?.cancel();
    _autoNavigationTimer = Timer(const Duration(milliseconds: 1500), () {
      debugPrint('Auto-navigation timer completed');
    });
  }
  Future<void> updateLocation() async {
    _currentPosition = null;
    _currentAddress = null;
    
    await getCurrentLocation();
  }

  void clearLocation() {
    _currentPosition = null;
    _currentAddress = null;
    _autoNavigationTimer?.cancel();
    emit(const LocationInitial());
  }

  LocationState? getCachedLocationState() {
    if (_currentPosition != null && _currentAddress != null) {
      return LocationSuccess(
        position: _currentPosition!,
        address: _currentAddress!,
      );
    }
    return null;
  }

  bool shouldShowSettingsButton() {
    return state is LocationError && (state as LocationError).needsSettings;
  }

  void reset() {
    _autoNavigationTimer?.cancel();
    emit(const LocationInitial());
  }

  @override
  Future<void> close() {
    _autoNavigationTimer?.cancel();
    return super.close();
  }
}