import 'package:flutter/material.dart';
import 'package:priora/features/doctor/profile/domain/models/doctor_profile.dart';
import 'package:priora/features/doctor/profile/presentation/widgets/doctor_profile_section_header.dart';

/// Profile biography section of the professional.
class DoctorProfileBioSection extends StatelessWidget {
  const DoctorProfileBioSection({required this.profile, super.key});

  final DoctorProfile profile;

  @override
  Widget build(BuildContext context) {
    final bio = profile.bio?.trim() ?? '';
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
            icon: Icons.description_outlined,
            title: 'Biografía',
          ),
          const SizedBox(height: 12),
          Text(
            bio.isEmpty ? 'Aún no has añadido una biografía.' : bio,
            style: TextStyle(
              color: bio.isEmpty
                  ? const Color(0xFF94A3B8)
                  : const Color(0xFF475569),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
