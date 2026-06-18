import 'package:flutter/material.dart';

class RegisterHeader extends StatelessWidget {
  const RegisterHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Crea tu cuenta',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: const Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Únete a la nueva era de salud preventiva en el Perú.',
          style: TextStyle(
            color: Color(0xFF64748B),
            fontSize: 15,
            fontWeight: FontWeight.w400,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
