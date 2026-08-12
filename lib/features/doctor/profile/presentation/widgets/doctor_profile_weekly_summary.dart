import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:priora/features/doctor/appointments/presentation/controller/doctor_appointments_cubit.dart';
import 'package:priora/features/doctor/appointments/presentation/controller/doctor_appointments_state.dart';
import 'package:priora/features/doctor/profile/domain/models/doctor_profile.dart';

/// Resumen semanal del perfil: citas, pacientes y rating.
class DoctorProfileWeeklySummary extends StatelessWidget {
  const DoctorProfileWeeklySummary({required this.profile, super.key});

  final DoctorProfile profile;

  @override
  Widget build(BuildContext context) {
    final rating = profile.rating != null
        ? profile.rating!.toStringAsFixed(1)
        : '—';
    return BlocBuilder<DoctorAppointmentsCubit, DoctorAppointmentsState>(
      builder: (context, state) {
        final allAppointments = [
          ...state.todayAppointments,
          ...state.upcomingAppointments,
          ...state.pastAppointments,
        ];
        final totalAppointments = allAppointments.length;
        final totalPatients = allAppointments
            .map((a) => a.patient.id)
            .where((id) => id.isNotEmpty)
            .toSet()
            .length;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF0256C2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Resumen',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildMetric('$totalAppointments', 'Citas'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetric('$totalPatients', 'Pacientes'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: _buildMetric(rating, 'Rating')),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetric(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1D4ED8).withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
