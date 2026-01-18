import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapSection extends StatelessWidget {
  const MapSection({super.key});

  @override
  Widget build(BuildContext context) {
    const stores = <LatLng>[
      // Promenada
      LatLng(45.2460, 19.8409),
      // Bulevar Oslobodjenja
      LatLng(45.2647, 19.8316),
    ];

    return FlutterMap(
      options: const MapOptions(
        initialCenter: LatLng(45.2671, 19.8335),
        initialZoom: 13,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.shoeshop',
        ),
        MarkerLayer(
          markers: stores.map((p) {
            return Marker(
              point: p,
              width: 40,
              height: 40,
              child: const Icon(Icons.location_on),
            );
          }).toList(),
        ),
      ],
    );
  }
}
