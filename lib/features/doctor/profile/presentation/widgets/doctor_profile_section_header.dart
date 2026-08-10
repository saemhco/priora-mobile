import 'package:flutter/material.dart';

/// Professionals Profile Section Header.
class DoctorProfileSectionHeader extends StatelessWidget {
  const DoctorProfileSectionHeader({
    required this.icon, required this.title, super.key,
  });

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF0256C2)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
