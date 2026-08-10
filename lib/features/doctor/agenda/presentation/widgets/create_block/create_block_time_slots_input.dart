import 'package:flutter/material.dart';
import 'package:priora/features/doctor/agenda/presentation/controller/create_block_controller.dart';

/// Input de horarios del formulario de bloque: chips de horas agregadas y
/// selector de hora (picker 24h).
class CreateBlockTimeSlotsInput extends StatelessWidget {
  const CreateBlockTimeSlotsInput({
    required this.controller,
    super.key,
  });

  final CreateBlockController controller;

  Future<void> _pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked == null) return;
    if (!context.mounted) return;
    final normalized =
        '${picked.hour.toString().padLeft(2, '0')}:'
        '${picked.minute.toString().padLeft(2, '0')}';
    if (controller.timeSlots.contains(normalized)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Esta hora ya fue agregada'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }
    controller.setPendingTime(normalized);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Added time slots chips
        if (controller.timeSlots.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: controller.timeSlots.map((time) {
              return Chip(
                label: Text(
                  controller.formatTimeDisplay(time),
                  style: const TextStyle(
                    color: Color(0xFF0256C2),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                deleteIcon: const Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: Color(0xFFEF4444),
                ),
                onDeleted: () => controller.removeTimeSlot(time),
                backgroundColor: const Color(0xFFEFF6FF),
                side: const BorderSide(color: Color(0xFFDBEAFE)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
        ],
        // Time picker button + pending confirmation
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              // Pending time display + actions
              if (controller.pendingTime != null) ...[
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.access_time_rounded,
                        color: Color(0xFF0256C2),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.formatTimeDisplay(
                              controller.pendingTime!,
                            ),
                            style: const TextStyle(
                              color: Color(0xFF1E293B),
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Text(
                            'Horario por agregar',
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => controller.setPendingTime(null),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(width: 4),
                    ElevatedButton(
                      onPressed: controller.confirmPendingTime,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D9488),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'Agregar',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
              ],
              // Select time button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _pickTime(context),
                  icon: const Icon(Icons.add_rounded, size: 20),
                  label: Text(
                    controller.pendingTime != null
                        ? 'Cambiar hora'
                        : 'Seleccionar hora',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0256C2),
                    side: BorderSide(
                      color: const Color(0xFF0256C2).withValues(alpha: 0.3),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          controller.timeSlots.isEmpty
              ? 'Toca "Seleccionar hora" para elegir un horario de atención.'
              : 'Se repite cada semana en los horarios agregados.',
          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
        ),
      ],
    );
  }
}
