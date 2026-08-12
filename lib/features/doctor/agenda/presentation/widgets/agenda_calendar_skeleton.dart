import 'package:flutter/material.dart';
import 'package:priora/core/widgets/shimmer.dart';
import 'package:priora/core/widgets/skeleton_block.dart';

/// Weekly calendar skeleton (days header + hours rows).
class AgendaCalendarSkeleton extends StatelessWidget {
  const AgendaCalendarSkeleton({super.key});

  static const int _rowCount = 5;

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        clipBehavior: Clip.antiAlias,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              for (int i = 0; i < _rowCount; i++) _buildRow(i),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const SizedBox(width: 60),
        for (int i = 0; i < 7; i++)
          Container(
            width: 100,
            height: 44,
            decoration: BoxDecoration(
              color: i == DateTime.now().weekday - 1
                  ? const Color(0xFFEFF6FF)
                  : const Color(0xFFF8FAFC),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 0.5,
              ),
            ),
            child: Center(
              child: SkeletonBlock(
                width: 28,
                height: 10,
                radius: 4,
                color: i == DateTime.now().weekday - 1
                    ? const Color(0xFFBFDBFE)
                    : const Color(0xFFE2E8F0),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRow(int rowIndex) {
    return Row(
      children: [
        const SizedBox(
          width: 60,
          height: 60,
          child: Center(
            child: SkeletonBlock(width: 32, height: 10, radius: 4),
          ),
        ),
        for (int col = 0; col < 7; col++) _buildCell(rowIndex, col),
      ],
    );
  }

  Widget _buildCell(int rowIndex, int colIndex) {
    final hasBlock = (rowIndex + colIndex) % 3 == 0;
    return Container(
      width: 100,
      height: 60,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFF1F5F9), width: 0.5),
        color: const Color(0xFFF8FAFC),
      ),
      child: hasBlock
          ? Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: const Border(
                  left: BorderSide(
                    color: Color(0xFFBFDBFE),
                    width: 3,
                  ),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SkeletonBlock(
                    width: 12,
                    height: 12,
                    color: Color(0xFFCBD5E1),
                  ),
                  SizedBox(width: 4),
                  SkeletonBlock(
                    width: 38,
                    height: 9,
                    radius: 4,
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
