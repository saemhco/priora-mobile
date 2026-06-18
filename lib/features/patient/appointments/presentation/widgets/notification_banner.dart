import 'package:flutter/material.dart';

class NotificationBanner extends StatelessWidget {
  final bool enabled;
  final VoidCallback onTap;

  const NotificationBanner({
    required this.enabled,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0E5FD9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '¿No encuentras horario?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Activa las notificaciones para avisarte cuando haya nuevas citas disponibles.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: onTap,
            child: Container(
              height: 48,
              width: 48,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                enabled ? Icons.notifications_active : Icons.notifications_none_rounded,
                color: const Color(0xFF0E5FD9),
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
