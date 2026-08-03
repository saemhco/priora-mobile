import 'package:dio/dio.dart';
import 'package:priora/features/doctor/profile/data/models/doctor_profile_model.dart';

class DoctorProfileService {
  final Dio _dio;

  DoctorProfileService(this._dio);

  /// Obtiene el perfil del profesional autenticado
  /// Endpoint: GET /users/me/professional-profile
  Future<DoctorProfileModel> getProfessionalProfile({
    required String accessToken,
  }) async {
    final response = await _dio.get(
      '/users/me/professional-profile',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );

    if (response.statusCode == 200) {
      return DoctorProfileModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    }
    throw Exception('Error al obtener el perfil');
  }
}
