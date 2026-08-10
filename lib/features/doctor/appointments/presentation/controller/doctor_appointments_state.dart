import 'package:flutter/foundation.dart';
import 'package:priora/features/doctor/appointments/domain/models/doctor_appointment.dart';

/// Estado de la pantalla de citas del profesional.
@immutable
class DoctorAppointmentsState {
  const DoctorAppointmentsState({
    this.todayAppointments = const [],
    this.upcomingAppointments = const [],
    this.pastAppointments = const [],
    this.isLoading = true,
    this.loadError,
  });

  final List<DoctorAppointment> todayAppointments;
  final List<DoctorAppointment> upcomingAppointments;
  final List<DoctorAppointment> pastAppointments;
  final bool isLoading;
  final String? loadError;

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
