import 'package:flutter/material.dart';
import 'package:priora/features/doctor/agenda/presentation/controller/create_block_controller.dart';

/// Block Form Day of the Week Picker.
class CreateBlockDaysSelector extends StatelessWidget {
  const CreateBlockDaysSelector({required this.controller, super.key});

  final CreateBlockController controller;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: CreateBlockController.days.map((day) {
        final value = day['value'] as int;
        final label = day['label'] as String;
        final selected = controller.selectedDays.contains(value);
        return GestureDetector(
          onTap: () => controller.toggleDay(value),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFEFF6FF) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected
                    ? const Color(0xFF0256C2)
                    : const Color(0xFFE2E8F0),
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: selected
                    ? const Color(0xFF0256C2)
                    : const Color(0xFF64748B),
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
