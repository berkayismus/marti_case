import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import '../models/location_marker.dart';
import '../services/location_service.dart';
import '../services/storage_service.dart';
import 'location_state.dart';

class LocationCubit extends Cubit<LocationState> {
  final LocationService _locationService;
  final StorageService _storageService;

  LocationCubit({
    LocationService? locationService,
    StorageService? storageService,
  })  : _locationService = locationService ?? LocationService(),
        _storageService = storageService ?? StorageService(),
        super(const LocationInitial());

  Future<void> initialize() async {
    emit(const LocationLoading());

    try {
      // Load saved markers
      final savedMarkers = await _storageService.loadMarkers();
      _locationService.loadMarkers(savedMarkers);

      // Set up marker callback
      _locationService.onMarkerAdded = (marker) {
        _onNewMarkerAdded(marker);
      };

      // Create initial map markers
      final mapMarkers = _createMapMarkers(savedMarkers);

      emit(LocationLoaded(
        markers: savedMarkers,
        mapMarkers: mapMarkers,
        isTracking: false,
      ));
    } catch (e) {
      emit(LocationError('Başlatma hatası: $e'));
    }
  }

  Set<Marker> _createMapMarkers(List<LocationMarker> locationMarkers) {
    final markers = <Marker>{};

    for (int i = 0; i < locationMarkers.length; i++) {
      final locMarker = locationMarkers[i];
      markers.add(
        Marker(
          markerId: MarkerId('marker_$i'),
          position: LatLng(locMarker.latitude, locMarker.longitude),
          infoWindow: InfoWindow(
            title: 'Konum ${i + 1}',
            snippet: 'Dokunarak adres bilgisini görün',
          ),
          onTap: () => loadMarkerAddress(i),
        ),
      );
    }

    return markers;
  }

  Future<void> _onNewMarkerAdded(LocationMarker marker) async {
    final currentState = state;
    if (currentState is! LocationLoaded) return;

    // Save markers
    await _storageService.saveMarkers(_locationService.markers);

    // Update map markers
    final mapMarkers = _createMapMarkers(_locationService.markers);

    emit(currentState.copyWith(
      markers: List.from(_locationService.markers),
      mapMarkers: mapMarkers,
    ));
  }

  Future<void> startTracking() async {
    final currentState = state;
    if (currentState is! LocationLoaded) return;

    try {
      await _locationService.startTracking();
      emit(currentState.copyWith(isTracking: true));
    } catch (e) {
      if (e.toString().contains('permission')) {
        emit(const LocationPermissionDenied());
        // Restore previous state
        emit(currentState);
      } else {
        emit(LocationError('Takip başlatılamadı: $e'));
        // Restore previous state
        emit(currentState);
      }
    }
  }

  void stopTracking() {
    final currentState = state;
    if (currentState is! LocationLoaded) return;

    _locationService.stopTracking();
    emit(currentState.copyWith(isTracking: false));
  }

  Future<void> resetRoute() async {
    final currentState = state;
    if (currentState is! LocationLoaded) return;

    // Stop tracking if active
    if (currentState.isTracking) {
      _locationService.stopTracking();
    }

    // Clear markers
    _locationService.clearMarkers();
    await _storageService.clearMarkers();

    emit(const LocationLoaded(
      markers: [],
      mapMarkers: {},
      isTracking: false,
    ));
  }

  Future<void> loadMarkerAddress(int index) async {
    final currentState = state;
    if (currentState is! LocationLoaded) return;

    final markers = currentState.markers;
    if (index >= markers.length) return;

    final marker = markers[index];

    // If address already loaded, no need to fetch again
    if (marker.address != null) return;

    // Emit loading state
    emit(MarkerAddressLoading(
      markerIndex: index,
      markers: currentState.markers,
      mapMarkers: currentState.mapMarkers,
      isTracking: currentState.isTracking,
    ));

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

        // Update service markers
        _locationService.markers[index] = updatedMarker;

        // Save to storage
        await _storageService.saveMarkers(updatedMarkers);

        // Update map markers
        final mapMarkers = _createMapMarkers(updatedMarkers);

        emit(LocationLoaded(
          markers: updatedMarkers,
          mapMarkers: mapMarkers,
          isTracking: currentState.isTracking,
        ));
      } else {
        // No address found, restore previous state
        emit(currentState);
      }
    } catch (e) {
      // Error fetching address, restore previous state
      emit(currentState);
    }
  }

  @override
  Future<void> close() {
    _locationService.dispose();
    return super.close();
  }
}
