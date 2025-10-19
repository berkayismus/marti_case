import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../models/location_marker.dart';
import '../services/location_service.dart';
import '../services/storage_service.dart';
import 'location_state.dart';

@singleton
class LocationCubit extends Cubit<LocationState> {
  final LocationService _locationService;
  final StorageService _storageService;
  
  // Callback for marker updates to notify MapCubit
  Function(List<LocationMarker>)? onMarkersUpdated;

  LocationCubit(this._locationService, this._storageService)
      : super(const LocationInitial());

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

      emit(
        LocationLoaded(
          markers: savedMarkers,
          isTracking: _locationService.isTracking,
        ),
      );
      
      // Notify MapCubit
      onMarkersUpdated?.call(savedMarkers);
    } catch (e) {
      emit(LocationError('Başlatma hatası: $e'));
    }
  }

  Future<void> _onNewMarkerAdded(LocationMarker marker) async {
    final currentState = state;
    if (currentState is! LocationLoaded) return;

    print('🎯 LocationCubit: New marker added - Total markers: ${_locationService.markers.length}');

    // Save markers
    await _storageService.saveMarkers(_locationService.markers);

    emit(
      currentState.copyWith(
        markers: List.from(_locationService.markers),
        isTracking: _locationService.isTracking,
      ),
    );
    
    // Notify MapCubit
    print('📢 LocationCubit: Notifying MapCubit with ${_locationService.markers.length} markers');
    onMarkersUpdated?.call(List.from(_locationService.markers));
  }

  Future<void> startTracking() async {
    final currentState = state;
    if (currentState is! LocationLoaded) return;

    // First, update state to show tracking is active
    emit(currentState.copyWith(isTracking: true));

    try {
      await _locationService.startTracking();
    } catch (e) {
      // Revert tracking state on error
      emit(currentState.copyWith(isTracking: false));
      
      if (e.toString().contains('permission')) {
        emit(const LocationPermissionDenied());
        // Restore previous state
        emit(currentState.copyWith(isTracking: false));
      } else {
        emit(LocationError('Takip başlatılamadı: $e'));
        // Restore previous state
        emit(currentState.copyWith(isTracking: false));
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

    emit(const LocationLoaded(markers: [], isTracking: false));
    
    // Notify MapCubit
    onMarkersUpdated?.call([]);
  }

  @override
  Future<void> close() {
    _locationService.dispose();
    return super.close();
  }
}
