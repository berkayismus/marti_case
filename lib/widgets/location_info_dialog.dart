import 'package:flutter/material.dart';

import '../models/location_marker.dart';
import '../utils/date_formatter.dart';

class LocationInfoDialog extends StatelessWidget {
  final LocationMarker marker;
  final int index;
  final String? address;

  const LocationInfoDialog({
    super.key,
    required this.marker,
    required this.index,
    this.address,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Konum ${index + 1}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Enlem: ${marker.latitude.toStringAsFixed(6)}'),
          Text('Boylam: ${marker.longitude.toStringAsFixed(6)}'),
          const SizedBox(height: 8),
          Text('Tarih: ${DateFormatter.format(marker.timestamp)}'),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          const Text('Adres:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(address ?? 'Adres yükleniyor...'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Kapat'),
        ),
      ],
    );
  }
}
