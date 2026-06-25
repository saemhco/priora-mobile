import 'package:flutter/material.dart';
import 'package:priora/features/patient/triage/controller/triage_cubit.dart';

class TriageStep3Analysis extends StatelessWidget {
  final TriageState state;

  const TriageStep3Analysis({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Title
            const Text(
              'Estamos analizando tus síntomas...',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0256C2),
              ),
            ),
            const SizedBox(height: 16),
            // Subtitle
            const Text(
              'Nuestro sistema está procesando tu información para brindarte la mejor recomendación de salud.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 48),

            // Premium Circular Progress Indicator
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 140,
                  height: 140,
                  child: CircularProgressIndicator(
                    value: state.analysisProgress / 100,
                    strokeWidth: 8,
                    color: const Color(0xFF0E5FD9),
                    backgroundColor: const Color(0xFFE2E8F0),
                  ),
                ),
                Text(
                  '${state.analysisProgress}%',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0E5FD9),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Completion message
            if (state.isCompleted)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.green,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '¡Análisis completado!',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
