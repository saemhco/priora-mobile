import 'package:dio/dio.dart';
import 'package:priora/features/patient/triage/data/triage_history_item.dart';

class TriageRepository {
  final Dio _dio;

  TriageRepository(this._dio);

  Future<Map<String, dynamic>?> getTriageDraft({
    required String accessToken,
  }) async {
    try {
      final response = await _dio.get(
        '/triage/draft',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>?;
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw Exception(e.message ?? 'Error al obtener el borrador de triaje');
    }
    return null;
  }

  Future<void> saveTriageDraft({
    required String accessToken,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _dio.patch(
        '/triage/draft',
        data: data,
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Error al guardar el borrador');
      }
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Error al guardar el borrador de triaje');
    }
  }

  Future<Map<String, dynamic>> completeTriage({
    required String accessToken,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _dio.post(
        '/triage',
        data: data,
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      }
    } on DioException catch (e) {
      final responseData = e.response?.data;
      if (responseData is Map && responseData['message'] != null) {
        throw Exception(responseData['message'].toString());
      }
      throw Exception(e.message ?? 'Error al completar el triaje');
    }
    throw Exception('Error al completar el triaje');
  }

  Future<Map<String, dynamic>> continueTriage({
    required String accessToken,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _dio.post(
        '/triage/continue',
        data: data,
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      }
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Error al continuar el triaje');
    }
    throw Exception('Error al continuar el triaje');
  }

  Future<List<TriageHistoryItem>> getTriageHistory({
    required String accessToken,
  }) async {
    try {
      final response = await _dio.get(
        '/triage/history',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      if (response.statusCode == 200) {
        final list = response.data as List;
        return list.map((item) => TriageHistoryItem.fromJson(item)).toList();
      }
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Error al obtener el historial de triaje');
    }
    throw Exception('Error al obtener el historial de triaje');
  }

  Future<Map<String, dynamic>> getTriageResult({
    required String accessToken,
    required String id,
  }) async {
    try {
      final response = await _dio.get(
        '/triage/$id',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Error al obtener el resultado del triaje');
    }
    throw Exception('Error al obtener el resultado del triaje');
  }
}
