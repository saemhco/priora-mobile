import 'package:dio/dio.dart';
import 'package:priora/features/patient/profile/data/models/patient_profile_dto.dart';

/// HTTP client of the patient's profile. Only makes API calls and serializes
/// responses into DTOs; no business logic.
class ProfileService {
  ProfileService(this._dio);

  final Dio _dio;

  Future<PatientProfileDto> getProfile({
    required String accessToken,
  }) async {
    final response = await _dio.get<dynamic>(
      '/users/me/profile',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    if (response.statusCode == 200) {
      return PatientProfileDto.fromJson(
        response.data as Map<String, dynamic>,
      );
    }
    throw Exception('Error al obtener el perfil');
  }

  Future<void> updateProfile({
    required String accessToken,
    required Map<String, dynamic> data,
  }) async {
    final response = await _dio.patch<dynamic>(
      '/users/me/profile',
      data: data,
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Error al actualizar el perfil');
    }
  }
}
