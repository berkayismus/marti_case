import 'package:equatable/equatable.dart';

import '../models/location_marker.dart';

abstract class LocationState extends Equatable {
  const LocationState();

  @override
  List<Object?> get props => [];
}

class LocationInitial extends LocationState {
  const LocationInitial();
}

class LocationLoading extends LocationState {
  const LocationLoading();
}

class LocationLoaded extends LocationState {
  final List<LocationMarker> markers;
  final bool isTracking;

  const LocationLoaded({
    required this.markers,
    required this.isTracking,
  });

  @override
  List<Object?> get props => [markers, isTracking];

  LocationLoaded copyWith({
    List<LocationMarker>? markers,
    bool? isTracking,
  }) {
    return LocationLoaded(
      markers: markers ?? this.markers,
      isTracking: isTracking ?? this.isTracking,
    );
  }
}

class LocationError extends LocationState {
  final String message;

  const LocationError(this.message);

  @override
  List<Object?> get props => [message];
}

class LocationPermissionDenied extends LocationState {
  const LocationPermissionDenied();
}
