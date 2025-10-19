import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/location_marker.dart';

abstract class MapState extends Equatable {
  const MapState();

  @override
  List<Object?> get props => [];
}

class MapInitial extends MapState {
  const MapInitial();
}

class MapLoaded extends MapState {
  final Set<Marker> mapMarkers;
  final List<LocationMarker> markers;

  const MapLoaded({
    required this.mapMarkers,
    required this.markers,
  });

  @override
  List<Object?> get props => [mapMarkers, markers];

  MapLoaded copyWith({
    Set<Marker>? mapMarkers,
    List<LocationMarker>? markers,
  }) {
    return MapLoaded(
      mapMarkers: mapMarkers ?? this.mapMarkers,
      markers: markers ?? this.markers,
    );
  }
}

class MarkerAddressLoading extends MapLoaded {
  final int markerIndex;

  const MarkerAddressLoading({
    required this.markerIndex,
    required super.mapMarkers,
    required super.markers,
  });

  @override
  List<Object?> get props => [markerIndex, mapMarkers, markers];
}
