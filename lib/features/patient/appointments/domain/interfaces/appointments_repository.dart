import 'package:priora/features/patient/appointments/domain/models/booking_result.dart';
import 'package:priora/features/patient/appointments/domain/models/doctor.dart';
import 'package:priora/features/patient/appointments/domain/models/patient_appointment.dart';

/// Contract for access to patient appointments. The presentation layer
/// depends solely on this abstraction; the implementation lives in
/// `data/repositories/`.
abstract interface class AppointmentsRepository {
  /// Obtiene la lista de especialidades disponibles.
  Future<List<String>> fetchSpecialties({required String accessToken});

  /// Obtiene los doctores con disponibilidad para reservar.
  Future<List<Doctor>> fetchAvailableBookings();

  /// Reserva una cita con un doctor.
  Future<BookingResult> bookAppointment({
    required String accessToken,
    required String doctorId,
    required String datetime,
    String? meetingType,
    String? placeId,
    String? triageSessionId,
    String? specialty,
    bool acknowledgeDuplicateSpecialty = false,
  });

  /// Obtiene las citas del paciente.
  Future<List<PatientAppointment>> fetchMyAppointments({
    required String accessToken,
  });
}
