import 'package:flutter/material.dart';
import 'package:priora/features/shared/auth/controller/complete_profile_controller.dart';

class LocationSection extends StatelessWidget {
  final CompleteProfileController controller;
  final bool isLoading;

  const LocationSection({
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
                  Icon(Icons.location_on_outlined, color: Color(0xFF0256C2), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Ubicación (opcional)',
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
                'Referencia de tu zona o dirección. Útil para orientar la atención presencial.',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Buscar dirección o lugar',
                style: TextStyle(
                  color: Color(0xFF475569),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: controller.addressController,
                enabled: !isLoading,
                style: const TextStyle(color: Color(0xFF1E293B), fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Buscar...',
                  hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8)),
                  fillColor: const Color(0xFFF1F5F9),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF0256C2), width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2F6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.map_outlined,
                      size: 36,
                      color: const Color(0xFF64748B).withOpacity(0.5),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Visualización del Mapa',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: isLoading || controller.fetchingLocation
                        ? null
                        : () => controller.getCurrentLocation(context),
                    icon: controller.fetchingLocation
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.5,
                              color: Color(0xFF0256C2),
                            ),
                          )
                        : const Icon(Icons.my_location, size: 16, color: Color(0xFF0256C2)),
                    label: Text(
                      controller.fetchingLocation ? 'Obteniendo...' : 'Mi ubicación actual',
                      style: const TextStyle(
                        color: Color(0xFF0256C2),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: isLoading ? null : () {},
                    child: const Text(
                      'Editar coordenadas',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
