import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:priora/features/doctor/places/presentation/controller/places_cubit.dart' show PlacesCubit;
import 'package:priora/features/doctor/places/presentation/widgets/places_body.dart';

/// Doctor's places of care screen. It only composes the widget tree; the
/// state and logic live in [PlacesCubit] and [PlacesBody].
class DoctorPlacesScreen extends StatelessWidget {
  const DoctorPlacesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lugares de Atención',
                          style: TextStyle(
                            color: Color(0xFF1E293B),
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Gestiona tus consultorios y clínicas.',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final result = await context.push<bool>('/create-place');
                      if (result == true) {
                        // La lista se recarga vía PlacesCubit al volver.
                      }
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Añadir lugar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0256C2),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Expanded(child: PlacesBody()),
          ],
        ),
      ),
    );
  }
}
