import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../cubit/location_cubit.dart';
import '../cubit/location_state.dart';
import '../cubit/map_cubit.dart';
import '../cubit/map_state.dart';
import '../widgets/confirmation_dialog.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/location_info_dialog.dart';
import '../widgets/tracking_control_card.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Istanbul center (Taksim Square)
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(41.0082, 28.9784),
    zoom: 18,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Marti Case - Konum Takibi',
        onResetPressed: _showResetConfirmation,
      ),
      body: BlocBuilder<LocationCubit, LocationState>(
        builder: (context, locationState) {
          if (locationState is LocationInitial || locationState is LocationLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (locationState is LocationError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(locationState.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<LocationCubit>().initialize(),
                    child: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            );
          }

          if (locationState is LocationPermissionDenied) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_off, size: 64, color: Colors.orange),
                  const SizedBox(height: 16),
                  const Text('Konum izni reddedildi'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<LocationCubit>().initialize(),
                    child: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            );
          }

          if (locationState is LocationLoaded) {
            return BlocConsumer<MapCubit, MapState>(
              listener: (context, mapState) {
                if (mapState is MarkerAddressLoading) {
                  // Show dialog when marker is tapped
                  final marker = mapState.markers[mapState.markerIndex];
                  _showAddressDialog(context, marker, mapState.markerIndex);
                }
              },
              builder: (context, mapState) {
                if (mapState is! MapLoaded) {
                  return const Center(child: CircularProgressIndicator());
                }

                return Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: _initialPosition,
                      markers: mapState.mapMarkers,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      onMapCreated: (controller) {
                        if (mapState.markers.isNotEmpty) {
                          final lastMarker = mapState.markers.last;
                          controller.animateCamera(
                            CameraUpdate.newLatLng(
                              LatLng(lastMarker.latitude, lastMarker.longitude),
                            ),
                          );
                        }
                      },
                    ),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: TrackingControlCard(
                        isTracking: locationState.isTracking,
                        markerCount: locationState.markers.length,
                        onToggleTracking: () =>
                            _toggleTracking(context, locationState.isTracking),
                      ),
                    ),
                  ],
                );
              },
            );
          }

          return const Center(child: Text('Bilinmeyen durum'));
        },
      ),
    );
  }

  void _toggleTracking(BuildContext context, bool isCurrentlyTracking) {
    final cubit = context.read<LocationCubit>();

    if (isCurrentlyTracking) {
      cubit.stopTracking();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Konum takibi durduruldu')));
    } else {
      cubit.startTracking();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Konum takibi başlatıldı')));
    }
  }

  Future<void> _showResetConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => const ConfirmationDialog(
        title: 'Rotayı Sıfırla',
        content: 'Tüm kayıtlı konumlar silinecek. Emin misiniz?',
        confirmText: 'Sıfırla',
        cancelText: 'İptal',
        confirmColor: Colors.red,
      ),
    );

    if (confirmed == true && mounted) {
      context.read<LocationCubit>().resetRoute();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Rota sıfırlandı')));
    }
  }

  void _showAddressDialog(BuildContext context, dynamic marker, int index) {
    showDialog(
      context: context,
      builder: (dialogContext) => LocationInfoDialog(
        marker: marker,
        index: index,
        address: marker.address,
      ),
    );
  }
}
