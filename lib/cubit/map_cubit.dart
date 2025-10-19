import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:injectable/injectable.dart';

import '../models/location_marker.dart';
import '../services/location_service.dart';
import '../services/storage_service.dart';
import 'map_state.dart';

@singleton
class MapCubit extends Cubit<MapState> {
  final StorageService _storageService;
  final LocationService _locationService;

  MapCubit(this._storageService, this._locationService) : super(const MapInitial());

  void initialize(List<LocationMarker> markers) {
    final mapMarkers = _createMapMarkers(markers);
    emit(MapLoaded(mapMarkers: mapMarkers, markers: markers));
  }

  void updateMarkers(List<LocationMarker> markers) {
    final currentState = state;
    
    print('🗺️ MapCubit: updateMarkers called with ${markers.length} markers');
    
    // If not yet initialized, initialize with markers
    if (currentState is! MapLoaded) {
      print('🗺️ MapCubit: Not loaded yet, calling initialize');
      initialize(markers);
      return;
    }

    print('🗺️ MapCubit: Creating ${markers.length} map markers');
    final mapMarkers = _createMapMarkers(markers);
    emit(currentState.copyWith(mapMarkers: mapMarkers, markers: markers));
    print('🗺️ MapCubit: Emitted MapLoaded with ${mapMarkers.length} markers');
  }

  Set<Marker> _createMapMarkers(List<LocationMarker> locationMarkers) {
    final markers = <Marker>{};

    for (int i = 0; i < locationMarkers.length; i++) {
      final locationMarker = locationMarkers[i];

      markers.add(
        Marker(
          markerId: MarkerId('marker_$i'),
          position: LatLng(locationMarker.latitude, locationMarker.longitude),
          infoWindow: InfoWindow(
            title: 'Konum ${i + 1}',
            snippet: locationMarker.address ?? 'Adres yükleniyor...',
          ),
          onTap: () => loadMarkerAddress(i),
        ),
      );
    }

    return markers;
  }

  Future<void> loadMarkerAddress(int index) async {
    final currentState = state;
    if (currentState is! MapLoaded) return;

    final markers = currentState.markers;
    if (index >= markers.length) return;

    final marker = markers[index];

    // Always emit MarkerAddressLoading to show dialog
    emit(
      MarkerAddressLoading(
        markerIndex: index,
        mapMarkers: currentState.mapMarkers,
        markers: currentState.markers,
      ),
    );

    // If address already loaded, just re-emit loaded state
    if (marker.address != null) {
      emit(
        MapLoaded(
          mapMarkers: currentState.mapMarkers,
          markers: currentState.markers,
        ),
      );
      return;
    }

    try {
      // Fetch address
      List<Placemark> placemarks = await placemarkFromCoordinates(
        marker.latitude,
        marker.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final address =
            '${place.street ?? ''}, ${place.subLocality ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}';

        // Update marker with address
        final updatedMarker = marker.copyWith(address: address);
        final updatedMarkers = List<LocationMarker>.from(markers);
        updatedMarkers[index] = updatedMarker;

        // Update LocationService markers
        _locationService.updateMarker(index, updatedMarker);

        // Save to storage
        await _storageService.saveMarkers(updatedMarkers);

        // Update map markers
        final mapMarkers = _createMapMarkers(updatedMarkers);

        emit(
          MapLoaded(
            markers: updatedMarkers,
            mapMarkers: mapMarkers,
          ),
        );
      } else {
        // No address found, restore previous state
        emit(MapLoaded(
          mapMarkers: currentState.mapMarkers,
          markers: currentState.markers,
        ));
      }
    } catch (e) {
      // Error fetching address, restore previous state
      emit(MapLoaded(
        mapMarkers: currentState.mapMarkers,
        markers: currentState.markers,
      ));
    }
  }
}
