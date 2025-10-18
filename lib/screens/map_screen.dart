import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../cubit/location_cubit.dart';
import '../cubit/location_state.dart';
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
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(41.0082, 28.9784),
    zoom: 14,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Marti Case - Konum Takibi',
        onResetPressed: _showResetConfirmation,
      ),
      body: BlocConsumer<LocationCubit, LocationState>(
        listener: (context, state) {
          if (state is LocationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is LocationPermissionDenied) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Konum izni reddedildi'),
                backgroundColor: Colors.orange,
              ),
            );
          } else if (state is MarkerAddressLoading) {
            // Show dialog when marker is tapped
            final marker = state.markers[state.markerIndex];
            _showAddressDialog(context, marker, state.markerIndex);
          }
        },
        builder: (context, state) {
          if (state is LocationInitial || state is LocationLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is LocationError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<LocationCubit>().initialize(),
                    child: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            );
          }

          if (state is LocationLoaded || state is MarkerAddressLoading) {
            final loadedState = state as LocationLoaded;
            return Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: _initialPosition,
                  markers: loadedState.mapMarkers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  onMapCreated: (controller) {
                    if (loadedState.markers.isNotEmpty) {
                      final lastMarker = loadedState.markers.last;
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
                    isTracking: loadedState.isTracking,
                    markerCount: loadedState.markers.length,
                    onToggleTracking: () =>
                        _toggleTracking(context, loadedState.isTracking),
                  ),
                ),
              ],
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
