import 'package:flutter/material.dart';
import 'package:priora/features/doctor/appointments/presentation/controller/doctor_appointments_cubit.dart';

/// Error status with appointment screen retry button.
class AppointmentsError extends StatelessWidget {
  const AppointmentsError({required this.cubit, super.key});

  final DoctorAppointmentsCubit cubit;

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
              cubit.state.loadError ?? 'Error al cargar las citas',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: cubit.loadAppointments,
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
