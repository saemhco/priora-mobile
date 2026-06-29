import 'package:dio/dio.dart';

class AppointmentsService {
  final Dio _dio;

  AppointmentsService(this._dio);

  Future<List<dynamic>> fetchSpecialties({required String accessToken}) async {
    final response = await _dio.get(
      '/specialties',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    if (response.statusCode == 200) {
      return response.data as List<dynamic>;
    }
    throw Exception('Error al obtener especialidades');
  }

  Future<List<dynamic>> fetchAvailableBookings() async {
    final response = await _dio.get('/booking/available');
    if (response.statusCode == 200) {
      final dynamic data = response.data;
      if (data is List) {
        return data;
      } else if (data is Map) {
        final possibleList =
            data['data'] ??
            data['items'] ??
            data['doctors'] ??
            data['professionals'] ??
            data['availabilities'];
        if (possibleList is List) {
          return possibleList;
        } else {
          return data.values.whereType<List>().firstOrNull ?? [];
        }
      }
    }
    throw Exception('Error al obtener disponibilidad');
  }

  Future<bool> bookAppointment({
    required String accessToken,
    required String doctorId,
    required String datetime,
  }) async {
    final response = await _dio.post(
      '/appointments',
      data: {"doctorId": doctorId, "datetime": datetime},
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<List<dynamic>> fetchMyAppointments({required String accessToken}) async {
    final response = await _dio.get(
      '/appointments/me',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    if (response.statusCode == 200) {
      return response.data as List<dynamic>;
    }
    throw Exception('Error al obtener mis citas');
  }
}
