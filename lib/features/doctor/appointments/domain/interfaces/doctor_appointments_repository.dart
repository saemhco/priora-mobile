import 'package:priora/features/doctor/appointments/domain/models/doctor_appointment.dart';

/// Contract for access to doctor's appointments. The presentation layer
/// depends solely on this abstraction; the implementation lives in
/// `data/repositories/`.
abstract interface class DoctorAppointmentsRepository {
  /// Obtiene todas las citas del doctor autenticado.
  Future<List<DoctorAppointment>> getMyAppointments({
    required String accessToken,
  });

  /// Record the attention of an appointment.
  Future<void> registerAttendance({
    required String accessToken,
    required String appointmentId,
    required String attendanceNote,
  });

  /// Cancela una cita.
  Future<void> cancelAppointment({
    required String accessToken,
    required String appointmentId,
    String? cancelReason,
  });
}
