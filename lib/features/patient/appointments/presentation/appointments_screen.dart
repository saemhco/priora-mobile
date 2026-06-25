import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:priora/features/patient/appointments/controller/appointments_controller.dart';
import 'package:priora/features/patient/appointments/presentation/widgets/appointment_search_bar.dart';
import 'package:priora/features/patient/appointments/presentation/widgets/specialty_filter_chips.dart';
import 'package:priora/features/patient/appointments/presentation/widgets/doctor_card.dart';
import 'package:priora/features/patient/appointments/presentation/widgets/notification_banner.dart';
import 'package:priora/features/shared/auth/data/auth_bloc.dart';
import 'package:priora/features/shared/auth/data/auth_state.dart';

class PatientAppointmentsScreen extends StatefulWidget {
  const PatientAppointmentsScreen({super.key});

  @override
  State<PatientAppointmentsScreen> createState() =>
      _PatientAppointmentsScreenState();
}

class _PatientAppointmentsScreenState extends State<PatientAppointmentsScreen> {
  AppointmentsController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller == null) {
      final authState = context.read<AuthBloc>().state;
      final accessToken = authState is AuthAuthenticated ? authState.accessToken : '';
      _controller = AppointmentsController(accessToken: accessToken);
      _controller!.fetchAvailableBookings();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _confirmBooking(BuildContext context, DoctorModel doctor, String slot) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.calendar_today_rounded, color: Color(0xFF0256C2), size: 28),
              SizedBox(width: 10),
              Text(
                'Confirmar Cita',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          content: Text(
            '¿Deseas reservar tu cita con el ${doctor.name} para la hora $slot?',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Close dialog
                
                // Show loading spinner
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => Dialog(
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            height: 40,
                            width: 40,
                            child: CircularProgressIndicator(
                              color: Color(0xFF0256C2),
                              strokeWidth: 4,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Reservando Cita',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Registrando tu cita con el ${doctor.name}...',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );

                final success = await _controller!.bookAppointment(doctor.id, slot);

                if (context.mounted) {
                  Navigator.of(context).pop(); // Close loading spinner
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success 
                          ? '¡Cita reservada con éxito!' 
                          : 'Error al reservar la cita. Por favor, reintenta.',
                      ),
                      backgroundColor: success ? Colors.green : Colors.redAccent,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0256C2),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Confirmar',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF0256C2),
          ),
        ),
      );
    }

    return ListenableBuilder(
      listenable: _controller!,
      builder: (context, child) {
        final doctors = _controller!.filteredDoctors;

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: _controller!.fetchAvailableBookings,
              color: const Color(0xFF0256C2),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
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
                      onChanged: _controller!.updateSearchQuery,
                    ),
                    const SizedBox(height: 16),
                    SpecialtyFilterChips(
                      specialties: _controller!.specialties,
                      selectedSpecialty: _controller!.selectedSpecialty,
                      onSelected: _controller!.selectSpecialty,
                    ),
                    const SizedBox(height: 20),
                    if (_controller!.isLoading)
                      Container(
                        height: 200,
                        alignment: Alignment.center,
                        child: const CircularProgressIndicator(
                          color: Color(0xFF0256C2),
                        ),
                      )
                    else if (_controller!.errorMessage != null)
                      Container(
                        height: 200,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          _controller!.errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    else if (doctors.isEmpty)
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
                          onSelectSlot: (slot) {
                            _controller!.selectTimeSlot(doctor.id, slot);
                            _confirmBooking(context, doctor, slot);
                          },
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
                      enabled: _controller!.notificationsEnabled,
                      onTap: () {
                        _controller!.toggleNotifications();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              _controller!.notificationsEnabled
                                  ? 'Notificaciones activadas'
                                  : 'Notificaciones desactivadas',
                            ),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: _controller!.notificationsEnabled
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
          ),
        );
      },
    );
  }
}
