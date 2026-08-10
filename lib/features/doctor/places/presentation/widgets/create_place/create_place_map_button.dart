import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:priora/features/doctor/places/presentation/controller/create_place_controller.dart';

/// Button to select the location of the place on the map.
class CreatePlaceMapButton extends StatelessWidget {
  const CreatePlaceMapButton({
    required this.controller, super.key,
  });

  final CreatePlaceController controller;

  Future<void> _selectOnMap(BuildContext context) async {
    final result = await context.push<Map<String, double>>(
      '/map-picker',
      extra: {
        'latitude': controller.latitude ?? -12.046374,
        'longitude': controller.longitude ?? -77.042793,
      },
    );
    if (result != null) {
      controller.setLocation(result['latitude'], result['longitude']);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasLocation =
        controller.latitude != null && controller.longitude != null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: OutlinedButton.icon(
        onPressed: () => _selectOnMap(context),
        icon: Icon(
          hasLocation ? Icons.check_circle : Icons.explore_outlined,
          color: const Color(0xFF0256C2),
          size: 20,
        ),
        label: Text(
          hasLocation ? 'Ubicación seleccionada' : 'Seleccionar en mapa',
          style: const TextStyle(
            color: Color(0xFF0256C2),
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 52),
          side: BorderSide(
            color: const Color(0xFF0256C2).withValues(alpha: 0.3),
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: const Color(0xFFF8FAFC),
        ),
      ),
    );
  }
}
