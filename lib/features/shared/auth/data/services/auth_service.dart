import 'package:dio/dio.dart';
import 'package:priora/features/shared/auth/domain/models/email_not_verified_exception.dart';
import 'package:priora/features/shared/auth/domain/models/email_verification_pending.dart';

/// Authentication HTTP client. Only makes API calls; no business logic.
class AuthService {
  AuthService(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post<Object?>(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      // Handle 201 Created or 200 OK response
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          return data;
        }
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Credenciales inválidas');
      }
      if (e.response?.statusCode == 403) {
        // The account exists but the email was never verified.
        final data = e.response?.data;
        final emailFromResponse = data?['email']?.toString();
        final emailToVerify =
            (emailFromResponse == null || emailFromResponse.isEmpty)
            ? email
            : emailFromResponse;
        final retryAfterSeconds =
            (data?['retryAfterSeconds'] as num?)?.toInt() ?? 600;
        throw EmailNotVerifiedException(
          email: emailToVerify,
          retryAfterSeconds: retryAfterSeconds,
        );
      }
      throw Exception(e.message ?? 'Error de conexión');
    }
    throw Exception('Error al iniciar sesión');
  }

  /// Registers the account and returns the email verification status.
  /// No tokens are issued until [verifyEmail] succeeds.
  Future<EmailVerificationPending> register(
    String email,
    String password,
  ) async {
    try {
      final response = await _dio.post<Object?>(
        '/auth/register',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          return EmailVerificationPending.fromJson(data);
        }
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

  /// Validates the 6-digit OTP and returns the auth tokens.
  Future<Map<String, dynamic>> verifyEmail(String email, String code) async {
    try {
      final response = await _dio.post<Object?>(
        '/auth/verify-email',
        data: {'email': email, 'code': code},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          return data;
        }
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final code = e.response?.data?['code']?.toString();
        final message = e.response?.data?['message']?.toString();
        throw Exception(_otpErrorMessage(code, message));
      }
      throw Exception(e.message ?? 'Error de conexión');
    }
    throw Exception('Error al verificar el código');
  }

  /// Sends another OTP to [email] if it is still pending verification.
  Future<EmailVerificationPending> resendVerification(String email) async {
    try {
      final response = await _dio.post<Object?>(
        '/auth/resend-verification',
        data: {'email': email},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          return EmailVerificationPending.fromJson(data);
        }
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('No hay una cuenta pendiente de verificación');
      }
      if (e.response?.statusCode == 429) {
        final code = e.response?.data?['code']?.toString();
        final message = e.response?.data?['message']?.toString();
        throw Exception(_resendErrorMessage(code, message));
      }
      throw Exception(e.message ?? 'Error de conexión');
    }
    throw Exception('Error al reenviar el código');
  }

  String _otpErrorMessage(String? code, String? message) {
    switch (code) {
      case 'OTP_INVALID':
        return 'El código ingresado es incorrecto. Verifica e intenta nuevamente.';
      case 'OTP_EXPIRED':
        return 'El código caducó. Solicita uno nuevo.';
      case 'OTP_LOCKED':
        return 'Demasiados intentos fallidos. Solicita un nuevo código.';
      default:
        return message ?? 'Código inválido. Verifica e intenta nuevamente.';
    }
  }

  String _resendErrorMessage(String? code, String? message) {
    switch (code) {
      case 'OTP_COOLDOWN':
        return 'Debes esperar 10 minutos antes de solicitar otro código.';
      case 'OTP_DAILY_LIMIT':
        return 'Alcanzaste el límite de códigos de hoy (máximo 5).';
      default:
        return message ?? 'Espera unos minutos antes de reenviar el código.';
    }
  }

  Future<Map<String, dynamic>> googleLogin(String idToken) async {
    try {
      final response = await _dio.post<Object?>(
        '/auth/google',
        data: {'idToken': idToken},
      );

      // Handle 201 Created or 200 OK response
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          return data;
        }
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
      final response = await _dio.patch<Object?>(
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
      final response = await _dio.get<Object?>(
        '/users/me/profile',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          return data;
        }
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
      final response = await _dio.get<Object?>(
        '/appointments/me',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data;
        }
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
      final response = await _dio.post<Object?>(
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
