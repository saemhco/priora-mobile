import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:priora/features/patient/navigation/controller/patient_navigation_controller.dart';
import 'package:priora/features/patient/triage/controller/triage_cubit.dart';

class TriageResultView extends StatelessWidget {
  final TriageState state;

  const TriageResultView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    // Priority color mapping
    Color priorityColor;
    Color priorityBgColor;
    String priorityText;
    IconData priorityIcon;
    String prioritySubtitle;

    final priorityUpper = state.priority?.toUpperCase() ?? 'LOW';

    if (priorityUpper == 'CRITICAL' || priorityUpper == 'HIGH') {
      priorityColor = const Color(0xFFEF4444); // Red
      priorityBgColor = const Color(0xFFFEE2E2);
      priorityText = 'CRITICAL';
      priorityIcon = Icons.warning_amber_rounded;
      prioritySubtitle = 'Atención médica inmediata requerida';
    } else if (priorityUpper == 'MEDIUM') {
      priorityColor = const Color(0xFFF97316); // Orange
      priorityBgColor = const Color(0xFFFFEDD5);
      priorityText = 'MEDIUM';
      priorityIcon = Icons.warning_amber_rounded;
      prioritySubtitle = 'Requiere atención pronta';
    } else {
      priorityColor = const Color(0xFF10B981); // Green
      priorityBgColor = const Color(0xFFD1FAE5);
      priorityText = 'LOW';
      priorityIcon = Icons.check_circle_outline_rounded;
      prioritySubtitle = 'Atención general o cuidados en casa';
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    const Center(
                      child: Text(
                        'Resultado de Triaje',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Center(
                      child: Text(
                        'Hemos analizado tus síntomas con precisión clínica.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Priority Card
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: priorityColor.withOpacity(0.4),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 24,
                        horizontal: 16,
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'NIVEL DE PRIORIDAD',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF94A3B8),
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: priorityBgColor,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  priorityIcon,
                                  color: priorityColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  priorityText,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: priorityColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            prioritySubtitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF334155),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Patient Safe Message / AI Recommendation Card
                    if (state.patientSafeMessage != null &&
                        state.patientSafeMessage!.isNotEmpty)
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.all(18),
                        child: Text(
                          '"${state.patientSafeMessage}"',
                          style: const TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: Color(0xFF475569),
                            height: 1.5,
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),

                    // Suggested Specialties Section
                    Row(
                      children: const [
                        Icon(
                          Icons.medical_services_outlined,
                          color: Color(0xFF0256C2),
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Especialidades Sugeridas',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Specialties Cards List
                    if (state.suggestedSpecialties.isEmpty)
                      const Text(
                        'No hay especialidades específicas sugeridas.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                        ),
                      )
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 1.3,
                            ),
                        itemCount: state.suggestedSpecialties.length,
                        itemBuilder: (context, index) {
                          final specialtyName =
                              state.suggestedSpecialties[index];

                          // Custom Icon/Bg color per specialty type if wanted, or standard blue
                          final isFirst = index == 0;
                          final cardIcon = isFirst
                              ? Icons.favorite_border_rounded
                              : Icons.health_and_safety_outlined;
                          final cardColor = isFirst
                              ? const Color(0xFFEEF2FF)
                              : const Color(0xFFE0F7FA);
                          final iconColor = isFirst
                              ? const Color(0xFF4F46E5)
                              : const Color(0xFF00ACC1);

                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                                width: 1.2,
                              ),
                            ),
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: cardColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    cardIcon,
                                    color: iconColor,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  specialtyName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isFirst
                                      ? 'Alta prioridad'
                                      : 'Evaluación inicial',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 32),

                    // Action Button: Agendar cita
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          context.read<PatientNavigationCubit>().changeIndex(2);
                          if (Navigator.canPop(context)) {
                            Navigator.of(context).pop();
                          }
                        },
                        icon: const Icon(
                          Icons.calendar_today_outlined,
                          size: 18,
                        ),
                        label: const Text(
                          'Agendar cita',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0256C2),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Action Button: Ver historial de triaje
                    Center(
                      child: TextButton.icon(
                        onPressed: () {
                          context.read<PatientNavigationCubit>().changeIndex(1);
                          if (Navigator.canPop(context)) {
                            Navigator.of(context).pop();
                          }
                        },
                        icon: const Icon(Icons.history_rounded, size: 18),
                        label: const Text(
                          'Ver historial de triaje',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF0256C2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Dotted Info card at the bottom
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1,
                          style: BorderStyle.solid,
                        ),
                      ),
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Icon(
                            Icons.info_outline_rounded,
                            color: Color(0xFF64748B),
                            size: 18,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Este resultado es una orientación basada en tus respuestas. En caso de emergencia extrema, acude al centro de salud más cercano.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF64748B),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
