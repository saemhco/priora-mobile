import 'package:flutter/material.dart';
import 'package:priora/core/widgets/shimmer.dart';

/// Skeleton de carga para la pantalla de perfil del paciente.
class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Column(
        children: [
          // Header Card Skeleton
          Container(
            width: double.infinity,
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
            ),
          ),
          const SizedBox(height: 20),
          // Info Card Skeleton
          Container(
            width: double.infinity,
            height: 220,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
            ),
          ),
          const SizedBox(height: 20),
          // Location Card Skeleton
          Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
