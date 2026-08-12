import 'package:dio/dio.dart';

/// Authentication HTTP client. Only makes API calls; no business logic.
class AuthService {
  AuthService(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post<dynamic>(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      // Handle 201 Created or 200 OK response
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Credenciales inválidas');
      }
      throw Exception(e.message ?? 'Error de conexión');
    }
    throw Exception('Error al iniciar sesión');
  }

  Future<Map<String, dynamic>> register(String email, String password) async {
    try {
      final response = await _dio.post<dynamic>(
        '/auth/register',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
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

  Future<Map<String, dynamic>> googleLogin(String idToken) async {
    try {
      final response = await _dio.post<dynamic>(
        '/auth/google',
        data: {'idToken': idToken},
      );

      // Handle 201 Created or 200 OK response
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
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
      final response = await _dio.patch<dynamic>(
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
      final detail = e.response?.data?['message'];
      if (detail is String) {
        throw Exception(detail);
      }
      throw Exception(e.message ?? 'Error de conexión');
    }
  }

  Future<Map<String, dynamic>> getProfile({
    required String accessToken,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
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

  Future<List<dynamic>> getMyAppointments({
    required String accessToken,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
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

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      final response = await _dio.post<dynamic>(
        '/auth/forgot-password',
        data: {'email': email},
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Error al enviar el correo de recuperación');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('El correo electrónico no está registrado');
      }
      final detail = e.response?.data?['message'];
      if (detail is String) {
        throw Exception(detail);
      }
      throw Exception(e.message ?? 'Error de conexión');
    }
  }
}
