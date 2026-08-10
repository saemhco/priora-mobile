import 'package:dio/dio.dart';
import 'package:priora/features/doctor/agenda/data/models/weekly_schedule_dto.dart';

/// HTTP client of the doctor's weekly availability. Only makes API calls and
/// serializes responses into DTOs; no business logic.
class AvailabilityService {
  AvailabilityService(this._dio);

  final Dio _dio;

  Future<List<dynamic>> createWeekly({
    required String accessToken,
    required Map<String, dynamic> data,
  }) async {
    final response = await _dio.post<dynamic>(
      '/availability/weekly',
      data: data,
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return response.data is List ? response.data as List<dynamic> : [];
    }
    throw Exception('Error al crear bloque');
  }

  Future<List<WeeklyScheduleDto>> getMyWeekly({
    required String accessToken,
  }) async {
    final response = await _dio.get<dynamic>(
      '/availability/weekly/me',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    if (response.statusCode == 200) {
      final data = response.data;
      if (data is List) {
        return data
            .map((e) => WeeklyScheduleDto.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    }
    throw Exception('Error al obtener bloques');
  }

  Future<void> deleteWeekly({
    required String accessToken,
    required String scheduleId,
  }) async {
    final response = await _dio.delete<dynamic>(
      '/availability/weekly/$scheduleId',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    final status = response.statusCode;
    if (status == null || status < 200 || status >= 300) {
      throw Exception('Error al eliminar bloque');
    }
  }
}
