import 'package:flutter/material.dart';

class TrackingControlCard extends StatelessWidget {
  final bool isTracking;
  final int markerCount;
  final VoidCallback onToggleTracking;

  const TrackingControlCard({
    super.key,
    required this.isTracking,
    required this.markerCount,
    required this.onToggleTracking,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Toplam Konum: $markerCount',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onToggleTracking,
                icon: Icon(isTracking ? Icons.stop : Icons.play_arrow),
                label: Text(isTracking ? 'Takibi Durdur' : 'Takibi Başlat'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isTracking ? Colors.red : Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
