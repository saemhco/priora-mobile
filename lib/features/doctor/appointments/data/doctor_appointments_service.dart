import 'package:dio/dio.dart';
import 'package:priora/features/doctor/appointments/data/models/doctor_appointment_model.dart';

class DoctorAppointmentsService {
  final Dio _dio;

  DoctorAppointmentsService(this._dio);

  /// Obtiene las citas del profesional autenticado
  /// Endpoint: GET /appointments/doctor
  Future<List<DoctorAppointment>> getMyAppointments({
    required String accessToken,
  }) async {
    final response = await _dio.get(
      '/appointments/doctor',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );

    if (response.statusCode == 200) {
      final data = response.data;
      if (data is List) {
        return data
            .map((e) => DoctorAppointment.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    }
    throw Exception('Error al obtener citas');
  }

  /// Registra la atención de una cita (profesional)
  /// Endpoint: PATCH /appointments/{id}/attendance
  /// Body: RegisterAttendanceDto { attendanceNote: string (mín. 10 caracteres) }
  Future<void> registerAttendance({
    required String accessToken,
    required String appointmentId,
    required String attendanceNote,
  }) async {
    final response = await _dio.patch(
      '/appointments/$appointmentId/attendance',
      data: {'attendanceNote': attendanceNote},
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al registrar atención');
    }
  }

  /// Cancela una cita (profesional o paciente de la cita)
  /// Endpoint: PATCH /appointments/{id}/cancel
  /// Body: CancelAppointmentDto { cancelReason?: string }
  Future<void> cancelAppointment({
    required String accessToken,
    required String appointmentId,
    String? cancelReason,
  }) async {
    final response = await _dio.patch(
      '/appointments/$appointmentId/cancel',
      data: {
        if (cancelReason != null && cancelReason.isNotEmpty)
          'cancelReason': cancelReason,
      },
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al cancelar la cita');
    }
  }
}
