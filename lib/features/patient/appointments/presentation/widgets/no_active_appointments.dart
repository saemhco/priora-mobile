import 'package:flutter/material.dart';

/// Message when there are appointments but none are current (all passes and
/// the pass toggle is disabled).
class NoActiveAppointments extends StatelessWidget {
  const NoActiveAppointments({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.event_available_rounded,
            color: Color(0xFFCBD5E1),
            size: 32,
          ),
          SizedBox(height: 10),
          Text(
            'No tienes citas vigentes',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Activa "Mostrar citas pasadas" para ver el historial.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }
}
