import 'package:priora/features/patient/appointments/data/models/doctor_dto.dart';
import 'package:priora/features/patient/appointments/data/models/patient_appointment_dto.dart';
import 'package:priora/features/patient/appointments/data/services/appointments_service.dart';
import 'package:priora/features/patient/appointments/domain/interfaces/appointments_repository.dart';
import 'package:priora/features/patient/appointments/domain/models/booking_result.dart';
import 'package:priora/features/patient/appointments/domain/models/doctor.dart';
import 'package:priora/features/patient/appointments/domain/models/patient_appointment.dart';

/// Implementation of the [AppointmentsRepository] contract using
/// [AppointmentsService]. Transforms API responses into DTOs and maps to
/// domain entities.
class AppointmentsRepositoryImpl implements AppointmentsRepository {
  AppointmentsRepositoryImpl(this._service);

  final AppointmentsService _service;

  @override
  Future<List<String>> fetchSpecialties({
    required String accessToken,
  }) async {
    final list = await _service.fetchSpecialties(accessToken: accessToken);
    return list
        .map((s) => s['name']?.toString() ?? '')
        .where((name) => name.isNotEmpty)
        .toList();
  }

  @override
  Future<List<Doctor>> fetchAvailableBookings() async {
    final list = await _service.fetchAvailableBookings();
    return list
        .map((item) => DoctorDto.fromApiJson(item as Map<String, dynamic>))
        .map((dto) => dto.toDomain())
        .toList();
  }

  @override
  Future<BookingResult> bookAppointment({
    required String accessToken,
    required String doctorId,
    required String datetime,
    String? meetingType,
    String? placeId,
    String? triageSessionId,
    String? specialty,
    bool acknowledgeDuplicateSpecialty = false,
  }) {
    return _service.bookAppointment(
      accessToken: accessToken,
      doctorId: doctorId,
      datetime: datetime,
      meetingType: meetingType,
      placeId: placeId,
      triageSessionId: triageSessionId,
      specialty: specialty,
      acknowledgeDuplicateSpecialty: acknowledgeDuplicateSpecialty,
    );
  }

  @override
  Future<List<PatientAppointment>> fetchMyAppointments({
    required String accessToken,
  }) async {
    final list = await _service.fetchMyAppointments(accessToken: accessToken);
    return list
        .map(
          (item) =>
              PatientAppointmentDto.fromApiJson(item as Map<String, dynamic>),
        )
        .map((dto) => dto.toDomain())
        .toList();
  }
}
