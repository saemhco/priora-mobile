import 'package:flutter/material.dart';

/// Rectangular placeholder block used by all loading skeletons across the app
/// (shared/reusable widget).
class SkeletonBlock extends StatelessWidget {
  const SkeletonBlock({
    super.key,
    this.width,
    this.height = 14,
    this.radius = 6,
    this.color = const Color(0xFFE2E8F0),
  });

  final double? width;
  final double height;
  final double radius;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
