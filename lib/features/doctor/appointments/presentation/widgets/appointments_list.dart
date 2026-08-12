import 'package:flutter/material.dart';
import 'package:priora/features/doctor/appointments/domain/models/doctor_appointment.dart';
import 'package:priora/features/doctor/appointments/presentation/widgets/appointment_card.dart';

/// List of appointments with empty and pull-to-refresh status.
class AppointmentsList extends StatelessWidget {
  const AppointmentsList({
    required this.appointments, required this.onRefresh, super.key,
  });

  final List<DoctorAppointment> appointments;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) {
      return RefreshIndicator(
        color: const Color(0xFF0256C2),
        onRefresh: onRefresh,
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: constraints.maxHeight,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.event_available_rounded,
                      size: 40,
                      color: Color(0xFFCBD5E1),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'No hay citas',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Desliza hacia abajo para actualizar',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF0256C2),
      onRefresh: onRefresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        itemCount: appointments.length,
        separatorBuilder: (_, _) => const SizedBox(height: 16),
        itemBuilder: (context, index) =>
            AppointmentCard(appointment: appointments[index]),
      ),
    );
  }
}
