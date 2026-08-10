import 'package:flutter/material.dart';
import 'package:priora/features/patient/appointments/presentation/controller/appointments_controller.dart';

/// Toggle para mostrar u ocultar citas pasadas en "Mis citas".
class PastAppointmentsToggle extends StatelessWidget {
  const PastAppointmentsToggle({
    required this.controller, super.key,
  });

  final AppointmentsController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.history_rounded,
            color: Color(0xFF64748B),
            size: 20,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mostrar citas pasadas',
                  style: TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Actívalo para ver citas que ya se realizaron',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                ),
              ],
            ),
          ),
          Switch(
            value: controller.showPastAppointments,
            onChanged: (_) => controller.toggleShowPastAppointments(),
            activeTrackColor: const Color(0xFF0256C2),
            activeThumbColor: Colors.white,
          ),
        ],
      ),
    );
  }
}
