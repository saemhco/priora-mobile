import 'package:flutter/material.dart';

class TriageHeader extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final String title;

  const TriageHeader({
    required this.currentStep,
    required this.totalSteps,
    required this.title,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final progress = currentStep / totalSteps;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0256C2),
              ),
            ),
            Text(
              'Paso $currentStep de $totalSteps',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: const Color(0xFFE2E8F0),
            color: const Color(0xFF0F766E), // Teal color from design
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
