import 'package:flutter/material.dart';

class AddPlaceCard extends StatelessWidget {

  const AddPlaceCard({super.key, this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF0256C2).withValues(alpha: 0.25),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.local_hospital_rounded,
                color: Color(0xFF0256C2),
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '¿Atiendes en otro lugar?',
              style: TextStyle(
                color: Color(0xFF0256C2),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Registra tus sedes para que tus pacientes\npuedan encontrarte fácilmente.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF475569),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
