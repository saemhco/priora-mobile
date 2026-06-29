import 'package:dio/dio.dart';

class ProfileService {
  final Dio _dio;

  ProfileService(this._dio);

  Future<Map<String, dynamic>> getProfile({required String accessToken}) async {
    final response = await _dio.get(
      '/users/me/profile',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    if (response.statusCode == 200) {
      return response.data as Map<String, dynamic>;
    }
    throw Exception('Error al obtener el perfil');
  }

  Future<void> updateProfile({
    required String accessToken,
    required Map<String, dynamic> data,
  }) async {
    final response = await _dio.patch(
      '/users/me/profile',
      data: data,
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Error al actualizar el perfil');
    }
  }
}
