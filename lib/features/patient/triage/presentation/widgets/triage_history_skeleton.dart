import 'package:flutter/material.dart';
import 'package:priora/core/widgets/shimmer.dart';

/// Skeleton de carga para el historial de triaje.
class TriageHistorySkeleton extends StatelessWidget {
  const TriageHistorySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Column(
        children: List.generate(3, (index) => _buildSkeletonCard()),
      ),
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 5,
              decoration: const BoxDecoration(
                color: Color(0xFFE2E8F0),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 80,
                          height: 12,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        Container(
                          width: 60,
                          height: 18,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: 180,
                      height: 16,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE2E8F0),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 120,
                          height: 12,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
