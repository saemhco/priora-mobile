import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:priora/features/doctor/agenda/presentation/widgets/agenda_appointment_card.dart';
import 'package:priora/features/doctor/agenda/presentation/widgets/today_appointments_skeleton.dart';
import 'package:priora/features/doctor/appointments/presentation/controller/doctor_appointments_cubit.dart';
import 'package:priora/features/doctor/appointments/presentation/controller/doctor_appointments_state.dart';
import 'package:priora/features/doctor/navigation/controller/doctor_navigation_controller.dart';

/// “Today's Appointments” section of the agenda. Listen to the shared status
/// of the [DoctorAppointmentsCubit] and show skeleton/cards/empty statuses.
class TodayAppointmentsSection extends StatelessWidget {
  const TodayAppointmentsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DoctorAppointmentsCubit, DoctorAppointmentsState>(
      builder: (context, state) {
        final todayAppointments = state.todayAppointments;
        final upcomingAppointments = state.upcomingAppointments
            .take(5)
            .toList();
        final isLoading = state.isLoading && todayAppointments.isEmpty;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Citas de hoy',
                  style: TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (todayAppointments.isNotEmpty)
                  GestureDetector(
                    // Va al tab de Citas, que muestra todas con su pestaña "Hoy"
                    onTap: () =>
                        context.read<DoctorNavigationCubit>().changeIndex(1),
                    child: const Text(
                      'Ver todas',
                      style: TextStyle(
                        color: Color(0xFF0256C2),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            if (isLoading)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const TodayAppointmentsSkeleton(),
              )
            else if (todayAppointments.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.event_available_rounded,
                        size: 32,
                        color: Color(0xFFCBD5E1),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Sin citas para hoy',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...todayAppointments.map(
                (appt) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AgendaAppointmentCard(appointment: appt),
                ),
              ),
            if (upcomingAppointments.isNotEmpty) ...[
              const SizedBox(height: 6),
              const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Text(
                  'Próximas citas',
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ...upcomingAppointments.map(
                (appt) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AgendaAppointmentCard(
                    appointment: appt,
                    compact: true,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
