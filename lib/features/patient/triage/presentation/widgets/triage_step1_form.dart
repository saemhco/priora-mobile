import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:priora/features/patient/triage/controller/triage_cubit.dart';
import 'package:priora/features/patient/triage/presentation/widgets/triage_header.dart';
import 'package:priora/features/patient/triage/presentation/widgets/triage_input_card.dart';

class TriageStep1Form extends StatefulWidget {
  final String accessToken;
  final TriageState state;

  const TriageStep1Form({
    super.key,
    required this.accessToken,
    required this.state,
  });

  @override
  State<TriageStep1Form> createState() => _TriageStep1FormState();
}

class _TriageStep1FormState extends State<TriageStep1Form> {
  late final TriageCubit _cubit;
  final _surgeriesController = TextEditingController();
  final _otherChronicController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _otherHistoryController = TextEditingController();

  final List<String> _commonConditions = const [
    'Diabetes',
    'Hipertensión',
    'Asma',
    'Tiroides',
  ];

  @override
  void initState() {
    super.initState();
    _cubit = context.read<TriageCubit>();

    // Initialize text fields with current values from state if any
    _surgeriesController.text = widget.state.surgeries;
    _otherChronicController.text = widget.state.otherChronicConditions;
    _allergiesController.text = widget.state.allergies;
    _otherHistoryController.text = widget.state.otherHistory;

    _surgeriesController.addListener(() {
      _cubit.updateSurgeries(_surgeriesController.text);
    });
    _otherChronicController.addListener(() {
      _cubit.updateOtherChronicConditions(_otherChronicController.text);
    });
    _allergiesController.addListener(() {
      _cubit.updateAllergies(_allergiesController.text);
    });
    _otherHistoryController.addListener(() {
      _cubit.updateOtherHistory(_otherHistoryController.text);
    });
  }

  @override
  void dispose() {
    _surgeriesController.dispose();
    _otherChronicController.dispose();
    _allergiesController.dispose();
    _otherHistoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(
            left: 20.0,
            right: 20.0,
            top: 16.0,
            bottom: 140.0, // Space for bottom buttons
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header progress
              const TriageHeader(
                currentStep: 1,
                totalSteps: 2,
                title: 'Antecedentes de Salud',
              ),
              const SizedBox(height: 24),

              // Title
              const Text(
                'Ayúdanos a conocerte mejor',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Esta información es opcional, pero permite que nuestros médicos te brinden una atención más precisa y personalizada.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),

              // 1. Cirugías previas
              TriageInputCard(
                title: 'Cirugías previas',
                child: TextField(
                  controller: _surgeriesController,
                  maxLines: 3,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1E293B),
                  ),
                  decoration: InputDecoration(
                    hintText:
                        'Ej. Apendicectomía (2015), Cirugía de rodilla (2018)...',
                    hintStyle: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 13,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF1F5F9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
              ),

              // 2. Condiciones Crónicas
              TriageInputCard(
                title: 'Condiciones Crónicas',
                subtitle: 'Selecciona si padeces alguna o escribe otra debajo.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _commonConditions.map((condition) {
                        final isSelected = widget.state.chronicConditions.contains(
                          condition,
                        );
                        return GestureDetector(
                          onTap: () => _cubit.toggleChronicCondition(condition),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF0E5FD9)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.transparent
                                    : const Color(0xFFE2E8F0),
                                width: 1.2,
                              ),
                            ),
                            child: Text(
                              condition,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF475569),
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _otherChronicController,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF1E293B),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Otras condiciones...',
                        hintStyle: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 13,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF1F5F9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 3. Alergias
              TriageInputCard(
                title: 'Alergias',
                child: TextField(
                  controller: _allergiesController,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1E293B),
                  ),
                  decoration: InputDecoration(
                    hintText:
                        'Medicamentos, alimentos o factores ambientales...',
                    hintStyle: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 13,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF1F5F9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                ),
              ),

              // 4. Otros antecedentes
              TriageInputCard(
                title: 'Otros antecedentes',
                icon: Icons.assignment_outlined,
                child: TextField(
                  controller: _otherHistoryController,
                  maxLines: 3,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1E293B),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Fuma, antecedentes familiares relevantes, etc.',
                    hintStyle: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 13,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF1F5F9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
              ),

              // Bottom Illustration Image
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/images/onboarding_hero.png',
                  width: double.infinity,
                  height: 160,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),

        // Fixed Bottom Buttons
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: widget.state.isLoading
                        ? null
                        : () => _cubit.saveDraft(widget.accessToken),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0256C2),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: widget.state.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Continuar',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: TextButton(
                    onPressed: () {
                      _cubit.changeStep(2);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF0256C2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Omitir por ahora',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
