import 'package:flutter/material.dart';
import 'package:priora/core/widgets/shimmer.dart';
import 'package:priora/core/widgets/skeleton_block.dart';

/// Skeleton compacto para el selector de "Filtrar por" cuando cargan los
/// lugares.
class LocationSelectorSkeleton extends StatelessWidget {
  const LocationSelectorSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Row(
          children: [
            SkeletonBlock(
              width: 20,
              height: 20,
              radius: 4,
              color: Color(0xFFCBD5E1),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBlock(width: 140),
                  SizedBox(height: 6),
                  SkeletonBlock(
                    width: 90,
                    height: 10,
                    radius: 5,
                    color: Color(0xFFF1F5F9),
                  ),
                ],
              ),
            ),
            SkeletonBlock(
              width: 14,
              radius: 4,
              color: Color(0xFFCBD5E1),
            ),
          ],
        ),
      ),
    );
  }
}
