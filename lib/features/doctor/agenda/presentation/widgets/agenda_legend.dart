import 'package:flutter/material.dart';
import 'package:priora/features/doctor/agenda/presentation/widgets/agenda_theme.dart';

/// Leyenda del calendario de la agenda (virtual / presencial / sin disponibilidad).
class AgendaLegend extends StatelessWidget {
  const AgendaLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendDot(
          MeetingTypeTheme.virtual.primary,
          Icons.videocam_rounded,
          'Virtual',
        ),
        const SizedBox(width: 20),
        _legendDot(
          MeetingTypeTheme.inPerson.primary,
          Icons.business_rounded,
          'Presencial',
        ),
        const SizedBox(width: 20),
        _legendDot(const Color(0xFFE2E8F0), null, 'Sin disponibilidad'),
      ],
    );
  }

  Widget _legendDot(Color color, IconData? icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null)
          Icon(icon, size: 14, color: color)
        else
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
