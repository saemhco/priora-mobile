import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:priora/features/shared/auth/controller/complete_profile_controller.dart';

class LocationSection extends StatelessWidget {
  final CompleteProfileController controller;
  final bool isLoading;

  const LocationSection({
    super.key,
    required this.controller,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    Future<void> selectLocationFromMap() async {
      final result = await context.push<Map<String, double>>(
        '/map-picker',
        extra: {
          'latitude': controller.latitude,
          'longitude': controller.longitude,
        },
      );
      if (result != null) {
        final lat = result['latitude'];
        final lng = result['longitude'];
        if (lat != null && lng != null) {
          controller.setCoordinates(lat, lng);
        }
      }
    }

    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: 24.0),
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFF1F5F9)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x050F172A),
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    color: Color(0xFF0256C2),
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Ubicación (opcional)',
                    style: TextStyle(
                      color: Color(0xFF0256C2),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: isLoading ? null : selectLocationFromMap,
                child: Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D4A53),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            'https://api.mapbox.com/styles/v1/mapbox/streets-v11/static/${controller.longitude},${controller.latitude},14,0/600x300?access_token=${dotenv.env['MAPBOX_DOWNLOADS_TOKEN'] ?? 'mock'}',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  color: const Color(0xFF334E57),
                                  child: const Center(
                                    child: Icon(
                                      Icons.map,
                                      color: Colors.white60,
                                      size: 40,
                                    ),
                                  ),
                                ),
                          ),
                        ),
                      ),
                      if (controller.hasSelectedLocation)
                        const Center(
                          child: Icon(
                            Icons.location_pin,
                            color: Color(0xFF0256C2),
                            size: 40,
                          ),
                        )
                      else
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.55),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.touch_app,
                                  color: Colors.white,
                                  size: 36,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Presiona aquí para elegir tu ubicación',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
