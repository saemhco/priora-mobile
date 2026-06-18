import 'package:flutter/material.dart';

class SpecialtyFilterChips extends StatelessWidget {
  final List<String> specialties;
  final String selectedSpecialty;
  final ValueChanged<String> onSelected;

  const SpecialtyFilterChips({
    required this.specialties,
    required this.selectedSpecialty,
    required this.onSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: specialties.map((specialty) {
            final isSelected = specialty == selectedSpecialty;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => onSelected(specialty),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF0E5FD9) : const Color(0xFFE2E8F0).withOpacity(0.6),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    specialty,
                    style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF64748B),
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
