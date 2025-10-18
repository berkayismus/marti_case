import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
  final Set<Marker> mapMarkers;
  final bool isTracking;

  const LocationLoaded({
    required this.markers,
    required this.mapMarkers,
    required this.isTracking,
  });

  @override
  List<Object?> get props => [markers, mapMarkers, isTracking];

  LocationLoaded copyWith({
    List<LocationMarker>? markers,
    Set<Marker>? mapMarkers,
    bool? isTracking,
  }) {
    return LocationLoaded(
      markers: markers ?? this.markers,
      mapMarkers: mapMarkers ?? this.mapMarkers,
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

class MarkerAddressLoading extends LocationLoaded {
  final int markerIndex;

  const MarkerAddressLoading({
    required this.markerIndex,
    required super.markers,
    required super.mapMarkers,
    required super.isTracking,
  });

  @override
  List<Object?> get props => [markerIndex, markers, mapMarkers, isTracking];
}
