import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:injectable/injectable.dart';
import '../models/location_marker.dart';

@lazySingleton
class StorageService {
  static const String _markersKey = 'location_markers';

  // Save markers to local storage
  Future<void> saveMarkers(List<LocationMarker> markers) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = markers.map((marker) => marker.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await prefs.setString(_markersKey, jsonString);
  }

  // Load markers from local storage
  Future<List<LocationMarker>> loadMarkers() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_markersKey);
    
    if (jsonString == null) {
      return [];
    }

    try {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) => LocationMarker.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // If parsing fails, return empty list
      return [];
    }
  }

  // Clear all markers
  Future<void> clearMarkers() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_markersKey);
  }

  // Check if there are saved markers
  Future<bool> hasMarkers() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_markersKey);
  }
}
