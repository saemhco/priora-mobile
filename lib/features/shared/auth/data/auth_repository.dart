import 'package:dio/dio.dart';
import 'package:priora/features/shared/auth/data/models/auth_response.dart';

class AuthRepository {
  final Dio _dio;

  AuthRepository(this._dio);

  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      // Handle 201 Created or 200 OK response
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        print('Login response: $data');
        return AuthResponse.fromJson(data);
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Credenciales inválidas');
      }
      throw Exception(e.message ?? 'Error de conexión');
    }
    throw Exception('Error al iniciar sesión');
  }

  Future<AuthResponse> register(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {'email': email, 'password': password, 'role': 'patient'},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        print('Register response: $data');
        return AuthResponse.fromJson(data);
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw Exception('El correo electrónico ya está registrado');
      }
      if (e.response?.statusCode == 400) {
        final detail = e.response?.data?['message'];
        if (detail is List) {
          throw Exception(detail.join(', '));
        }
        throw Exception(detail ?? 'Datos de registro inválidos');
      }
      throw Exception(e.message ?? 'Error de conexión');
    }
    throw Exception('Error al registrar la cuenta');
  }

  Future<AuthResponse> googleLogin(String idToken) async {
    try {
      final response = await _dio.post(
        '/auth/google',
        data: {'idToken': idToken},
      );

      // Handle 201 Created or 200 OK response
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        print('Google Login response: $data');
        return AuthResponse.fromJson(data);
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Credenciales de Google inválidas');
      }
      throw Exception(e.message ?? 'Error de conexión');
    }
    throw Exception('Error al iniciar sesión con Google');
  }

  Future<void> updateProfile({
    required String accessToken,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _dio.patch(
        '/users/me/profile',
        data: data,
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Error al actualizar el perfil');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Sesión expirada o no autorizada');
      }
      throw Exception(e.message ?? 'Error de conexión');
    }
  }

  Future<Map<String, dynamic>> getProfile({required String accessToken}) async {
    try {
      final response = await _dio.get(
        '/users/me/profile',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Sesión expirada o no autorizada');
      }
      throw Exception(e.message ?? 'Error de conexión');
    }
    throw Exception('Error al obtener el perfil');
  }

  Future<List<dynamic>> getMyAppointments({required String accessToken}) async {
    try {
      final response = await _dio.get(
        '/appointments/me',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Sesión expirada o no autorizada');
      }
      throw Exception(e.message ?? 'Error de conexión');
    }
    throw Exception('Error al obtener las citas');
  }
}
