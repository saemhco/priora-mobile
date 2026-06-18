import 'package:flutter/material.dart';
import 'package:priora/features/patient/appointments/controller/appointments_controller.dart';
import 'package:priora/features/patient/appointments/presentation/widgets/appointment_search_bar.dart';
import 'package:priora/features/patient/appointments/presentation/widgets/specialty_filter_chips.dart';
import 'package:priora/features/patient/appointments/presentation/widgets/doctor_card.dart';
import 'package:priora/features/patient/appointments/presentation/widgets/notification_banner.dart';

class PatientAppointmentsScreen extends StatefulWidget {
  const PatientAppointmentsScreen({super.key});

  @override
  State<PatientAppointmentsScreen> createState() =>
      _PatientAppointmentsScreenState();
}

class _PatientAppointmentsScreenState extends State<PatientAppointmentsScreen> {
  late final AppointmentsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AppointmentsController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        final doctors = _controller.filteredDoctors;

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Reserva tu cita',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Encuentra al especialista ideal para tu cuidado preventivo.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  AppointmentSearchBar(
                    onChanged: _controller.updateSearchQuery,
                  ),
                  const SizedBox(height: 16),
                  SpecialtyFilterChips(
                    specialties: _controller.specialties,
                    selectedSpecialty: _controller.selectedSpecialty,
                    onSelected: _controller.selectSpecialty,
                  ),
                  const SizedBox(height: 20),
                  if (doctors.isEmpty)
                    Container(
                      height: 150,
                      alignment: Alignment.center,
                      child: const Text(
                        'No se encontraron especialistas',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  else
                    ...doctors.map(
                      (doctor) => DoctorCard(
                        doctor: doctor,
                        onSelectSlot: (slot) =>
                            _controller.selectTimeSlot(doctor.id, slot),
                        onViewCalendar: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Abriendo calendario de ${doctor.name}',
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 16),
                  NotificationBanner(
                    enabled: _controller.notificationsEnabled,
                    onTap: () {
                      _controller.toggleNotifications();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            _controller.notificationsEnabled
                                ? 'Notificaciones activadas'
                                : 'Notificaciones desactivadas',
                          ),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: _controller.notificationsEnabled
                              ? const Color(0xFF0E5FD9)
                              : const Color(0xFF64748B),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
