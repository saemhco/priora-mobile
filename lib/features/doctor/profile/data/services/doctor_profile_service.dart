import 'package:dio/dio.dart';
import 'package:priora/features/doctor/profile/data/models/doctor_profile_dto.dart';

/// HTTP client of the professional's profile. Only makes API calls and
/// serializes responses into DTOs; no business logic.
class DoctorProfileService {
  DoctorProfileService(this._dio);

  final Dio _dio;

  /// Obtiene el perfil del profesional autenticado
  /// Endpoint: GET /users/me/professional-profile
  Future<DoctorProfileDto> getProfessionalProfile({
    required String accessToken,
  }) async {
    final response = await _dio.get<dynamic>(
      '/users/me/professional-profile',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );

    if (response.statusCode == 200) {
      return DoctorProfileDto.fromJson(
        response.data as Map<String, dynamic>,
      );
    }
    throw Exception('Error al obtener el perfil');
  }

  /// Actualiza el perfil del profesional autenticado
  /// Endpoint: PATCH /users/me/professional-profile
  /// Body: UpdateProfessionalProfileDto
  Future<DoctorProfileDto> updateProfessionalProfile({
    required String accessToken,
    required Map<String, dynamic> data,
  }) async {
    final response = await _dio.patch<dynamic>(
      '/users/me/professional-profile',
      data: data,
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );

    if (response.statusCode == 200) {
      return DoctorProfileDto.fromJson(
        response.data as Map<String, dynamic>,
      );
    }
    throw Exception('Error al actualizar el perfil');
  }
}
