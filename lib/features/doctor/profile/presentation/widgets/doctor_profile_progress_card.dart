import 'package:flutter/material.dart';
import 'package:priora/features/doctor/profile/domain/models/doctor_profile.dart';

/// Tarjeta de progreso de completado del perfil profesional.
class DoctorProfileProgressCard extends StatelessWidget {
  const DoctorProfileProgressCard({required this.profile, super.key});

  final DoctorProfile profile;

  @override
  Widget build(BuildContext context) {
    final percent = profile.completionPercent;
    final nextStep = _nextStep(profile);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Completar Perfil Profesional',
            style: TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$percent% Completado',
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (nextStep != null)
                GestureDetector(
                  onTap: () {},
                  child: Text(
                    'Siguiente: $nextStep',
                    style: const TextStyle(
                      color: Color(0xFF0256C2),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percent / 100,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF00CBB8),
              ),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  String? _nextStep(DoctorProfile profile) {
    if (profile.bio == null || profile.bio!.trim().isEmpty) {
      return 'Añadir Bio';
    }
    if (profile.profilePhotoUrl == null || profile.profilePhotoUrl!.isEmpty) {
      return 'Añadir Foto';
    }
    if (profile.phone == null || profile.phone!.trim().isEmpty) {
      return 'Añadir Teléfono';
    }
    if (profile.specialties.isEmpty) return 'Completar Especialidades';
    return null;
  }
}
