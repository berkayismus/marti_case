import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/location_marker.dart';

class LocationService {
  StreamSubscription<Position>? _positionStreamSubscription;
  Position? _lastPosition;
  final List<LocationMarker> _markers = [];
  
  // Callback when new marker is added
  Function(LocationMarker)? onMarkerAdded;
  
  // Distance threshold in meters
  static const double distanceThreshold = 100.0;

  // Check and request location permissions
  Future<bool> requestLocationPermission() async {
    // Check if location service is enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    // Check permission status
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    // For background location on Android 10+
    if (await Permission.locationAlways.isDenied) {
      await Permission.locationAlways.request();
    }

    return true;
  }

  // Start tracking location
  Future<void> startTracking() async {
    bool hasPermission = await requestLocationPermission();
    if (!hasPermission) {
      throw Exception('Location permission not granted');
    }

    // Get current position first
    try {
      _lastPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      
      // Add first marker
      _addMarker(_lastPosition!);
    } catch (e) {
      // Silently handle error for MVP
    }

    // Configure location settings for background tracking
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update every 10 meters to not miss the 100m threshold
    );

    // Start listening to position changes
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      _handlePositionUpdate(position);
    });
  }

  // Handle position updates
  void _handlePositionUpdate(Position position) {
    if (_lastPosition == null) {
      _addMarker(position);
      _lastPosition = position;
      return;
    }

    // Calculate distance from last marker
    double distance = Geolocator.distanceBetween(
      _lastPosition!.latitude,
      _lastPosition!.longitude,
      position.latitude,
      position.longitude,
    );

    // If distance is >= 100m, add new marker
    if (distance >= distanceThreshold) {
      _addMarker(position);
      _lastPosition = position;
    }
  }

  // Add a new marker
  void _addMarker(Position position) {
    final marker = LocationMarker(
      latitude: position.latitude,
      longitude: position.longitude,
      timestamp: DateTime.now(),
    );
    
    _markers.add(marker);
    
    // Notify listener
    if (onMarkerAdded != null) {
      onMarkerAdded!(marker);
    }
  }

  // Stop tracking
  void stopTracking() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
  }

  // Check if tracking is active
  bool get isTracking => _positionStreamSubscription != null;

  // Get all markers
  List<LocationMarker> get markers => List.unmodifiable(_markers);

  // Load markers from storage
  void loadMarkers(List<LocationMarker> markers) {
    _markers.clear();
    _markers.addAll(markers);
    
    // Set last position from last marker
    if (markers.isNotEmpty) {
      final lastMarker = markers.last;
      _lastPosition = Position(
        latitude: lastMarker.latitude,
        longitude: lastMarker.longitude,
        timestamp: lastMarker.timestamp,
        accuracy: 0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );
    }
  }

  // Clear all markers
  void clearMarkers() {
    _markers.clear();
    _lastPosition = null;
  }

  // Dispose resources
  void dispose() {
    stopTracking();
  }
}
