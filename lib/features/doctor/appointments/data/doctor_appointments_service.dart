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

  /// Obtiene las citas de hoy del profesional
  Future<List<DoctorAppointment>> getTodayAppointments({
    required String accessToken,
  }) async {
    final all = await getMyAppointments(accessToken: accessToken);
    final now = DateTime.now();
    return all
        .where((a) =>
            a.dateTimeObj.year == now.year &&
            a.dateTimeObj.month == now.month &&
            a.dateTimeObj.day == now.day &&
            a.status != 'CANCELED')
        .toList()
      ..sort((a, b) => a.dateTimeObj.compareTo(b.dateTimeObj));
  }

  /// Obtiene las próximas citas (futuras, no canceladas)
  Future<List<DoctorAppointment>> getUpcomingAppointments({
    required String accessToken,
  }) async {
    final all = await getMyAppointments(accessToken: accessToken);
    final now = DateTime.now();
    return all
        .where((a) =>
            a.dateTimeObj.isAfter(now) && a.status != 'CANCELED' && !a.isToday)
        .toList()
      ..sort((a, b) => a.dateTimeObj.compareTo(b.dateTimeObj));
  }

  /// Obtiene citas pasadas (completadas o canceladas)
  Future<List<DoctorAppointment>> getPastAppointments({
    required String accessToken,
  }) async {
    final all = await getMyAppointments(accessToken: accessToken);
    return all
        .where((a) => a.isPast && !a.isToday)
        .toList()
      ..sort((a, b) => b.dateTimeObj.compareTo(a.dateTimeObj)); // más recientes primero
  }
}
