import 'package:priora/features/doctor/appointments/data/services/doctor_appointments_service.dart';
import 'package:priora/features/doctor/appointments/domain/interfaces/doctor_appointments_repository.dart';
import 'package:priora/features/doctor/appointments/domain/models/doctor_appointment.dart';

/// Implementation of the [DoctorAppointmentsRepository] contract using
/// [DoctorAppointmentsService]. Map DTOs to domain entities.
class DoctorAppointmentsRepositoryImpl implements DoctorAppointmentsRepository {
  DoctorAppointmentsRepositoryImpl(this._service);

  final DoctorAppointmentsService _service;

  @override
  Future<List<DoctorAppointment>> getMyAppointments({
    required String accessToken,
  }) async {
    final dtos = await _service.getMyAppointments(accessToken: accessToken);
    return dtos.map((dto) => dto.toDomain()).toList();
  }

  @override
  Future<void> registerAttendance({
    required String accessToken,
    required String appointmentId,
    required String attendanceNote,
  }) {
    return _service.registerAttendance(
      accessToken: accessToken,
      appointmentId: appointmentId,
      attendanceNote: attendanceNote,
    );
  }

  @override
  Future<void> cancelAppointment({
    required String accessToken,
    required String appointmentId,
    String? cancelReason,
  }) {
    return _service.cancelAppointment(
      accessToken: accessToken,
      appointmentId: appointmentId,
      cancelReason: cancelReason,
    );
  }
}
