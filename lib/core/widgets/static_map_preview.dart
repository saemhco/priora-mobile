import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Lightweight, non-interactive preview of a map using OpenStreetMap tiles
/// via [FlutterMap].
class StaticMapPreview extends StatelessWidget {
  const StaticMapPreview({
    required this.latitude,
    required this.longitude,
    super.key,
    this.zoom = 14,
    this.height = 150,
    this.borderRadius,
    this.overlay,
  });
  final double latitude;
  final double longitude;
  final double zoom;
  final double height;
  final BorderRadius? borderRadius;
  final Widget? overlay;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(latitude, longitude),
                initialZoom: zoom,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.none,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.dope.priora',
                  maxZoom: 19,
                ),
              ],
            ),
            ?overlay,
          ],
        ),
      ),
    );
  }
}
