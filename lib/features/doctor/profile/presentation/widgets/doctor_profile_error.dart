import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:priora/features/doctor/profile/presentation/controller/doctor_profile_cubit.dart';

/// Error status with profile screen retry button.
class DoctorProfileError extends StatelessWidget {
  const DoctorProfileError({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 44,
              color: Color(0xFFCBD5E1),
            ),
            const SizedBox(height: 12),
            Text(
              context.read<DoctorProfileCubit>().state.error ??
                  'Error al cargar el perfil',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  context.read<DoctorProfileCubit>().loadProfile(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0256C2),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
