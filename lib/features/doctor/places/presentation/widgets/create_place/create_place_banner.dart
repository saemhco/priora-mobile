import 'package:flutter/material.dart';

/// Banner decorativo del formulario de crear/editar lugar.
class CreatePlaceBanner extends StatelessWidget {
  const CreatePlaceBanner({required this.isEditing, super.key});

  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF0256C2), Color(0xFF0D9488)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(
              Icons.local_hospital_rounded,
              size: 130,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          Positioned(
            left: 24,
            bottom: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.business_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      isEditing ? 'Editar Sede' : 'Registro de Sedes',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  isEditing
                      ? 'Actualiza la información de tu consultorio o clínica.'
                      : 'Añade los consultorios o clínicas\ndonde brindas atención médica.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
