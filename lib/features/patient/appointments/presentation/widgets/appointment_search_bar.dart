import 'package:flutter/material.dart';

class AppointmentSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const AppointmentSearchBar({
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        onChanged: onChanged,
        style: const TextStyle(
          fontSize: 15,
          color: Color(0xFF1E293B),
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'Especialidad, nombre o clínica',
          hintStyle: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 15,
            fontWeight: FontWeight.normal,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: Color(0xFF64748B),
            size: 22,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}
