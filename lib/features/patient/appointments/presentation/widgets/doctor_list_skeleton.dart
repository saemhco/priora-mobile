import 'package:flutter/material.dart';
import 'package:priora/core/widgets/shimmer.dart';

/// Skeleton de carga para la lista de doctores disponibles.
class DoctorListSkeleton extends StatelessWidget {
  const DoctorListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Column(
        children: List.generate(2, (index) => _buildSkeletonCard()),
      ),
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 120,
                            height: 16,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE2E8F0),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          Container(
                            width: 30,
                            height: 14,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE2E8F0),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 80,
                        height: 12,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: 140,
                        height: 12,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: Color(0xFFF1F5F9), height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 90,
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                Container(
                  width: 70,
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(3, (index) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Container(
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1.2,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
