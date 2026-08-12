import 'package:flutter/material.dart';

/// Navegador de semana de la agenda (rango de fechas actual).
class AgendaDateNavigator extends StatelessWidget {
  const AgendaDateNavigator({required this.weekRange, super.key});

  final String weekRange;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(
            Icons.chevron_left_rounded,
            color: Color(0xFF0256C2),
          ),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
        Text(
          weekRange,
          style: const TextStyle(
            color: Color(0xFF0256C2),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFF0256C2),
          ),
          onPressed: () {},
        ),
      ],
    );
  }
}
