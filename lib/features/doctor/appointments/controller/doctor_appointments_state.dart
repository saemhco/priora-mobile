import 'package:flutter/foundation.dart';
import 'package:priora/features/doctor/appointments/data/models/doctor_appointment_model.dart';

/// Resultado del registro de atención de una cita.
@immutable
class RegisterAttendanceResult {
  final bool success;
  final String? message;

  const RegisterAttendanceResult({required this.success, this.message});
}

/// Resultado de la cancelación de una cita.
@immutable
class CancelAppointmentResult {
  final bool success;
  final String? message;

  const CancelAppointmentResult({required this.success, this.message});
}

/// Estado de la pantalla de citas del profesional.
@immutable
class DoctorAppointmentsState {
  final List<DoctorAppointment> todayAppointments;
  final List<DoctorAppointment> upcomingAppointments;
  final List<DoctorAppointment> pastAppointments;
  final bool isLoading;
  final String? loadError;

  const DoctorAppointmentsState({
    this.todayAppointments = const [],
    this.upcomingAppointments = const [],
    this.pastAppointments = const [],
    this.isLoading = true,
    this.loadError,
  });

  DoctorAppointmentsState copyWith({
    List<DoctorAppointment>? todayAppointments,
    List<DoctorAppointment>? upcomingAppointments,
    List<DoctorAppointment>? pastAppointments,
    bool? isLoading,
    String? loadError,
    bool clearLoadError = false,
  }) {
    return DoctorAppointmentsState(
      todayAppointments: todayAppointments ?? this.todayAppointments,
      upcomingAppointments: upcomingAppointments ?? this.upcomingAppointments,
      pastAppointments: pastAppointments ?? this.pastAppointments,
      isLoading: isLoading ?? this.isLoading,
      loadError: clearLoadError ? null : (loadError ?? this.loadError),
    );
  }
}
