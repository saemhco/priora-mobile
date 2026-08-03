import 'package:dio/dio.dart';
import 'package:priora/features/doctor/agenda/data/models/weekly_schedule_model.dart';

class AvailabilityService {
  final Dio _dio;

  AvailabilityService(this._dio);

  Future<List<dynamic>> createWeekly({
    required String accessToken,
    required Map<String, dynamic> data,
  }) async {
    final response = await _dio.post(
      '/availability/weekly',
      data: data,
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return response.data is List ? response.data as List<dynamic> : [];
    }
    throw Exception('Error al crear bloque');
  }

  Future<List<WeeklySchedule>> getMyWeekly({
    required String accessToken,
  }) async {
    final response = await _dio.get(
      '/availability/weekly/me',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    if (response.statusCode == 200) {
      final data = response.data;
      if (data is List) {
        return data.map((e) => WeeklySchedule.fromJson(e as Map<String, dynamic>)).toList();
      }
      return [];
    }
    throw Exception('Error al obtener bloques');
  }

  Future<void> deleteWeekly({
    required String accessToken,
    required String scheduleId,
  }) async {
    final response = await _dio.delete(
      '/availability/weekly/$scheduleId',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar bloque');
    }
  }
}
