import 'package:flutter/material.dart';
import 'package:priora/core/widgets/shimmer.dart';
import 'package:priora/core/widgets/skeleton_block.dart';

/// Skeleton for “Today's Appointments” section (with appointment and upcoming
/// cards).
class TodayAppointmentsSkeleton extends StatelessWidget {
  const TodayAppointmentsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(),
          const SizedBox(height: 10),
          _buildAppointmentCard(compact: false),
          const SizedBox(height: 10),
          _buildAppointmentCard(compact: false),
          const SizedBox(height: 16),
          const SkeletonBlock(
            width: 110,
            height: 12,
            color: Color(0xFFF1F5F9),
          ),
          const SizedBox(height: 10),
          _buildAppointmentCard(compact: true),
          const SizedBox(height: 10),
          _buildAppointmentCard(compact: true),
        ],
      ),
    );
  }

  Widget _buildSectionTitle() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SkeletonBlock(width: 110, height: 16, radius: 8),
        SkeletonBlock(
          width: 60,
          height: 12,
          color: Color(0xFFF1F5F9),
        ),
      ],
    );
  }

  Widget _buildAppointmentCard({required bool compact}) {
    final avatarSize = compact ? 36.0 : 44.0;
    final nameSize = compact ? 13.0 : 15.0;
    final metaSize = compact ? 12.0 : 13.0;

    return Container(
      padding: EdgeInsets.all(compact ? 12 : 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          SkeletonBlock(
            width: avatarSize,
            height: avatarSize,
            radius: avatarSize / 2,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SkeletonBlock(width: 130, height: nameSize),
                    const SizedBox(width: 8),
                    const SkeletonBlock(
                      width: 52,
                      radius: 4,
                      color: Color(0xFFEFF6FF),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    SkeletonBlock(width: 60, height: metaSize, radius: 4),
                    const SizedBox(width: 10),
                    const SkeletonBlock(
                      width: 70,
                      height: 16,
                      radius: 10,
                      color: Color(0xFFECFDF5),
                    ),
                  ],
                ),
                if (!compact) ...[
                  const SizedBox(height: 6),
                  SkeletonBlock(
                    width: 150,
                    height: metaSize,
                    radius: 4,
                    color: const Color(0xFFF1F5F9),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
