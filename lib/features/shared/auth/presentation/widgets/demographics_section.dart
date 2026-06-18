import 'package:flutter/material.dart';
import 'package:priora/features/shared/auth/controller/complete_profile_controller.dart';

class DemographicsSection extends StatelessWidget {
  final CompleteProfileController controller;
  final bool isLoading;

  const DemographicsSection({
    super.key,
    required this.controller,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: 24.0),
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFF1F5F9)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x050F172A),
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.wc_outlined, color: Color(0xFF0256C2), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Datos Demográficos',
                    style: TextStyle(
                      color: Color(0xFF0256C2),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              const Text(
                'Sexo Biológico',
                style: TextStyle(
                  color: Color(0xFF475569),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isLoading
                          ? null
                          : () => controller.setBiologicalSex('Femenino'),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: controller.biologicalSex == 'Femenino'
                            ? const Color(0xFFEEF2F6)
                            : Colors.white,
                        side: BorderSide(
                          color: controller.biologicalSex == 'Femenino'
                              ? const Color(0xFF0256C2)
                              : const Color(0xFFE2E8F0),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        'Femenino',
                        style: TextStyle(
                          color: controller.biologicalSex == 'Femenino'
                              ? const Color(0xFF0256C2)
                              : const Color(0xFF1E293B),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isLoading
                          ? null
                          : () => controller.setBiologicalSex('Masculino'),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: controller.biologicalSex == 'Masculino'
                            ? const Color(0xFFEEF2F6)
                            : Colors.white,
                        side: BorderSide(
                          color: controller.biologicalSex == 'Masculino'
                              ? const Color(0xFF0256C2)
                              : const Color(0xFFE2E8F0),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        'Masculino',
                        style: TextStyle(
                          color: controller.biologicalSex == 'Masculino'
                              ? const Color(0xFF0256C2)
                              : const Color(0xFF1E293B),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              const Text(
                'Identidad de Género',
                style: TextStyle(
                  color: Color(0xFF475569),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  'Mujer',
                  'Hombre',
                  'No binario',
                  'Otro',
                  'Prefiero no decir'
                ].map((gender) {
                  final isSelected = controller.genderIdentity == gender;
                  return OutlinedButton(
                    onPressed: isLoading
                        ? null
                        : () => controller.setGenderIdentity(gender),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: isSelected ? const Color(0xFFEEF2F6) : Colors.white,
                      side: BorderSide(
                        color: isSelected ? const Color(0xFF0256C2) : const Color(0xFFE2E8F0),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    child: Text(
                      gender,
                      style: TextStyle(
                        color: isSelected ? const Color(0xFF0256C2) : const Color(0xFF1E293B),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),

              const Text(
                'Ocupación (opcional)',
                style: TextStyle(
                  color: Color(0xFF475569),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: controller.occupation,
                    hint: const Text('Seleccionar...'),
                    isExpanded: true,
                    style: const TextStyle(color: Color(0xFF1E293B), fontSize: 15),
                    icon: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: Color(0xFF64748B)),
                    onChanged: isLoading ? null : controller.setOccupation,
                    items: controller.occupationsList
                        .map(
                          (o) => DropdownMenuItem(
                            value: o,
                            child: Text(o),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
