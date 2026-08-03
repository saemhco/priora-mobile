import 'package:dio/dio.dart';

class PlacesService {
  final Dio _dio;

  PlacesService(this._dio);

  Future<List<dynamic>> fetchMyPlaces({required String accessToken}) async {
    final response = await _dio.get(
      '/places/me',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    if (response.statusCode == 200) {
      return response.data as List<dynamic>;
    }
    throw Exception('Error al obtener lugares');
  }

  Future<Map<String, dynamic>> createPlace({
    required String accessToken,
    required Map<String, dynamic> data,
  }) async {
    final response = await _dio.post(
      '/places',
      data: data,
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.data as Map<String, dynamic>;
    }
    throw Exception('Error al crear lugar');
  }

  Future<Map<String, dynamic>> updatePlace({
    required String accessToken,
    required String placeId,
    required Map<String, dynamic> data,
  }) async {
    final response = await _dio.patch(
      '/places/$placeId',
      data: data,
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    if (response.statusCode == 200) {
      return response.data as Map<String, dynamic>;
    }
    throw Exception('Error al actualizar lugar');
  }

  Future<void> deletePlace({
    required String accessToken,
    required String placeId,
  }) async {
    final response = await _dio.delete(
      '/places/$placeId',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar lugar');
    }
  }
}
