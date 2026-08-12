import 'package:flutter/material.dart';
import 'package:priora/core/widgets/static_map_preview.dart';
import 'package:priora/features/patient/profile/domain/models/patient_profile.dart';

class LocationCard extends StatelessWidget {
  const LocationCard({super.key, this.profile});
  final PatientProfile? profile;

  @override
  Widget build(BuildContext context) {
    final lat = profile?.latitude;
    final lng = profile?.longitude;
    final hasLocation = lat != null && lng != null;

    final locationText = hasLocation 
        ? 'Ubicación seleccionada (${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)})'
        : 'No tiene ubicación registrada';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  color: Color(0xFF0256C2),
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dirección de atención',
                      style: TextStyle(
                        color: Color(0xFF1E293B),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      locationText,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Map Container (Only show if has location)
          if (hasLocation)
            Stack(
              children: [
                StaticMapPreview(
                  latitude: lat,
                  longitude: lng,
                  borderRadius: BorderRadius.circular(16),
                  overlay: ColoredBox(
                    color: Colors.black.withValues(alpha: 0.05),
                    child: const Center(
                      child: Icon(
                        Icons.location_pin,
                        color: Color(0xFF0256C2),
                        size: 38,
                      ),
                    ),
                  ),
                ),
                // Map badge overlay
                Positioned(
                  bottom: 12,
                  left: 12,
                  right: 12,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.fullscreen_rounded,
                            color: Color(0xFF64748B),
                            size: 18,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Ver pantalla completa',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: const Color(0xFFF1F5F9),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                ),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.map_outlined,
                    color: Color(0xFF94A3B8),
                    size: 28,
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Ubicación no configurada',
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
