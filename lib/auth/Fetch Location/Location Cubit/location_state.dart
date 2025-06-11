import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';

abstract class LocationState extends Equatable {
  const LocationState();

  @override
  List<Object?> get props => [];
}

class LocationInitial extends LocationState {
  const LocationInitial();
}

class LocationLoading extends LocationState {
  final String message;
  
  const LocationLoading({
    this.message = 'Finding your location...',
  });

  @override
  List<Object?> get props => [message];
}

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

enum LocationErrorType {
  permissionDenied,
  permissionDeniedForever,
  serviceDisabled,
  noInternet,
  timeout,
  unknown,
}
