import 'package:flutter/material.dart';
import 'package:priora/features/doctor/profile/domain/models/doctor_profile.dart';

/// Encabezado del perfil: avatar, nombre, especialidad y tags.
class DoctorProfileHeader extends StatelessWidget {
  const DoctorProfileHeader({required this.profile, super.key});

  final DoctorProfile profile;

  @override
  Widget build(BuildContext context) {
    final hasPhoto = profile.profilePhotoUrl != null &&
        profile.profilePhotoUrl!.isNotEmpty;
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color(0xFFE2E8F0),
              ),
              clipBehavior: Clip.antiAlias,
              alignment: Alignment.center,
              child: hasPhoto
                  ? Image.network(
                      profile.profilePhotoUrl!,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.person,
                        size: 48,
                        color: Color(0xFF94A3B8),
                      ),
                    )
                  : const Icon(
                      Icons.person,
                      size: 48,
                      color: Color(0xFF94A3B8),
                    ),
            ),
            Positioned(
              bottom: -4,
              right: -4,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: const Color(0xFF059669),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.white, width: 2.5),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          profile.displayName,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          profile.primarySpecialty ?? 'Profesional de salud',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF0256C2),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        _buildTags(),
      ],
    );
  }

  Widget _buildTags() {
    final tags = <String>[
      ...profile.professions.map((p) => p.name),
    ];
    if (profile.documentId != null && profile.documentId!.isNotEmpty) {
      final docType = profile.documentType ?? 'DOC';
      tags.add('$docType ${profile.documentId}');
    }
    if (tags.isEmpty) tags.add('Profesional de salud');

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: List.generate(tags.length, (index) {
        final isPrimary = index.isEven;
        return _buildTag(
          tags[index],
          isPrimary
              ? const Color(0xFFE0F7F6)
              : const Color(0xFFF1F5F9),
          isPrimary
              ? const Color(0xFF0C6159)
              : const Color(0xFF64748B),
        );
      }),
    );
  }

  Widget _buildTag(String text, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
