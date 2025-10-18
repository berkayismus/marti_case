import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import '../models/location_marker.dart';
import '../services/location_service.dart';
import '../services/storage_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final LocationService _locationService = LocationService();
  final StorageService _storageService = StorageService();
  
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  bool _isTracking = false;
  bool _isLoading = true;
  
  // Default camera position (will be updated)
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(41.0082, 28.9784), // Istanbul
    zoom: 14,
  );

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Load saved markers
    final savedMarkers = await _storageService.loadMarkers();
    _locationService.loadMarkers(savedMarkers);
    
    // Create map markers
    await _updateMapMarkers();
    
    // Move camera to last marker if exists
    if (savedMarkers.isNotEmpty) {
      final lastMarker = savedMarkers.last;
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(lastMarker.latitude, lastMarker.longitude),
        ),
      );
    }
    
    setState(() {
      _isLoading = false;
    });
    
    // Set up marker callback
    _locationService.onMarkerAdded = (marker) {
      _onNewMarkerAdded(marker);
    };
  }

  Future<void> _updateMapMarkers() async {
    final markers = <Marker>{};
    final locationMarkers = _locationService.markers;
    
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
          onTap: () => _showAddressDialog(locMarker, i),
        ),
      );
    }
    
    setState(() {
      _markers = markers;
    });
  }

  Future<void> _onNewMarkerAdded(LocationMarker marker) async {
    // Save markers
    await _storageService.saveMarkers(_locationService.markers);
    
    // Update map markers
    await _updateMapMarkers();
    
    // Move camera to new marker
    _mapController?.animateCamera(
      CameraUpdate.newLatLng(
        LatLng(marker.latitude, marker.longitude),
      ),
    );
    
    // Show snackbar
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Yeni konum eklendi (${_locationService.markers.length})'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _showAddressDialog(LocationMarker marker, int index) async {
    String address = marker.address ?? 'Adres yükleniyor...';
    
    // Show dialog immediately with loading state
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Konum ${index + 1}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Enlem: ${marker.latitude.toStringAsFixed(6)}'),
            Text('Boylam: ${marker.longitude.toStringAsFixed(6)}'),
            const SizedBox(height: 8),
            Text('Tarih: ${_formatDateTime(marker.timestamp)}'),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'Adres:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(address),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
    
    // Fetch address if not already loaded
    if (marker.address == null) {
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          marker.latitude,
          marker.longitude,
        );
        
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          address = '${place.street ?? ''}, ${place.subLocality ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}';
          
          // Update marker with address
          final updatedMarker = marker.copyWith(address: address);
          final allMarkers = _locationService.markers;
          allMarkers[index] = updatedMarker;
          await _storageService.saveMarkers(allMarkers);
          
          // Close and reopen dialog with address
          if (mounted) {
            Navigator.pop(context);
            _showAddressDialog(updatedMarker, index);
          }
        }
      } catch (e) {
        address = 'Adres bilgisi alınamadı';
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _toggleTracking() async {
    if (_isTracking) {
      // Stop tracking
      _locationService.stopTracking();
      setState(() {
        _isTracking = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Konum takibi durduruldu')),
      );
    } else {
      // Start tracking
      try {
        await _locationService.startTracking();
        setState(() {
          _isTracking = true;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Konum takibi başlatıldı')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Hata: $e')),
          );
        }
      }
    }
  }

  Future<void> _resetRoute() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rotayı Sıfırla'),
        content: const Text('Tüm kayıtlı konumlar silinecek. Emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sıfırla', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      // Stop tracking if active
      if (_isTracking) {
        _locationService.stopTracking();
      }
      
      // Clear markers
      _locationService.clearMarkers();
      await _storageService.clearMarkers();
      
      setState(() {
        _markers = {};
        _isTracking = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rota sıfırlandı')),
        );
      }
    }
  }

  @override
  void dispose() {
    _locationService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Marti Case - Konum Takibi'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetRoute,
            tooltip: 'Rotayı Sıfırla',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: _initialPosition,
                  markers: _markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Toplam Konum: ${_locationService.markers.length}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _toggleTracking,
                              icon: Icon(_isTracking ? Icons.stop : Icons.play_arrow),
                              label: Text(_isTracking ? 'Takibi Durdur' : 'Takibi Başlat'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isTracking ? Colors.red : Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
