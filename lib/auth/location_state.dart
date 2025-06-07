import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';

/// Base class for all location states
/// Using Equatable for efficient state comparison and preventing unnecessary rebuilds
abstract class LocationState extends Equatable {
  const LocationState();

  @override
  List<Object?> get props => [];
}

/// Initial state when the location screen first loads
class LocationInitial extends LocationState {
  const LocationInitial();
}

/// Loading state during location acquisition
class LocationLoading extends LocationState {
  final String message;
  
  const LocationLoading({
    this.message = 'Finding your location...',
  });

  @override
  List<Object?> get props => [message];
}

/// Success state when location is successfully obtained
class LocationSuccess extends LocationState {
  final Position position;
  final String address;
  final String message;
  
  const LocationSuccess({
    required this.position,
    required this.address,
    this.message = 'Location found!',
  });

  @override
  List<Object?> get props => [
    position.latitude,
    position.longitude,
    address,
    message,
  ];
}

/// Error state for various location-related failures
class LocationError extends LocationState {
  final LocationErrorType errorType;
  final String title;
  final String message;
  final bool canRetry;
  final bool needsSettings;
  
  const LocationError({
    required this.errorType,
    required this.title,
    required this.message,
    this.canRetry = true,
    this.needsSettings = false,
  });

  @override
  List<Object?> get props => [
    errorType,
    title,
    message,
    canRetry,
    needsSettings,
  ];
}

/// Enumeration of possible location error types
/// Simplified from the original enum for better organization
enum LocationErrorType {
  permissionDenied,
  permissionDeniedForever,
  serviceDisabled,
  noInternet,
  timeout,
  unknown,
}