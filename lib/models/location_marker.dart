class LocationMarker {
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final String? address;

  LocationMarker({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.address,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
      'address': address,
    };
  }

  // Create from JSON
  factory LocationMarker.fromJson(Map<String, dynamic> json) {
    return LocationMarker(
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      timestamp: DateTime.parse(json['timestamp'] as String),
      address: json['address'] as String?,
    );
  }

  // Create a copy with updated address
  LocationMarker copyWith({String? address}) {
    return LocationMarker(
      latitude: latitude,
      longitude: longitude,
      timestamp: timestamp,
      address: address ?? this.address,
    );
  }
}
