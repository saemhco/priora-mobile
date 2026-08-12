import 'package:flutter/material.dart';
import 'package:priora/features/doctor/profile/domain/models/doctor_profile.dart';
import 'package:priora/features/doctor/profile/presentation/widgets/doctor_profile_section_header.dart';

/// Contact section of the professional's profile (mail and telephone).
class DoctorProfileContactSection extends StatelessWidget {
  const DoctorProfileContactSection({required this.profile, super.key});

  final DoctorProfile profile;

  @override
  Widget build(BuildContext context) {
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
          const DoctorProfileSectionHeader(
            icon: Icons.contact_page_outlined,
            title: 'Contacto',
          ),
          const SizedBox(height: 12),
          _buildContactRow(
            Icons.email_outlined,
            'Correo electrónico',
            profile.email.isEmpty ? 'No registrado' : profile.email,
          ),
          const SizedBox(height: 12),
          _buildContactRow(
            Icons.phone_outlined,
            'Teléfono',
            (profile.phone == null || profile.phone!.isEmpty)
                ? 'No registrado'
                : profile.phone!,
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF64748B)),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
