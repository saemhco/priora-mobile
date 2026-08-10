import 'package:dio/dio.dart';
import 'package:priora/features/doctor/places/data/models/place_dto.dart';

/// HTTP client of the doctor's places of care. Only makes API calls and
/// serializes responses into DTOs; no business logic.
class PlacesService {
  PlacesService(this._dio);

  final Dio _dio;

  Future<List<PlaceDto>> fetchMyPlaces({
    required String accessToken,
  }) async {
    final response = await _dio.get<dynamic>(
      '/places/me',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    if (response.statusCode == 200) {
      final data = response.data;
      if (data is List) {
        return data
            .map((e) => PlaceDto.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    }
    throw Exception('Error al obtener lugares');
  }

  Future<PlaceDto> createPlace({
    required String accessToken,
    required Map<String, dynamic> data,
  }) async {
    final response = await _dio.post<dynamic>(
      '/places',
      data: data,
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return PlaceDto.fromJson(response.data as Map<String, dynamic>);
    }
    throw Exception('Error al crear lugar');
  }

  Future<PlaceDto> updatePlace({
    required String accessToken,
    required String placeId,
    required Map<String, dynamic> data,
  }) async {
    final response = await _dio.patch<dynamic>(
      '/places/$placeId',
      data: data,
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    if (response.statusCode == 200) {
      return PlaceDto.fromJson(response.data as Map<String, dynamic>);
    }
    throw Exception('Error al actualizar lugar');
  }

  Future<void> deletePlace({
    required String accessToken,
    required String placeId,
  }) async {
    final response = await _dio.delete<dynamic>(
      '/places/$placeId',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar lugar');
    }
  }
}
