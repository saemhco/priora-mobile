import 'package:priora/features/shared/auth/domain/models/auth_response.dart';

/// Authentication access contract. The presentation layer depends solely on
/// this abstraction; the implementation lives in `data/repositories/`.
abstract interface class AuthRepository {
  /// Log in with your email and password
  Future<AuthResponse> login(String email, String password);

  /// Registra una nueva cuenta.
  Future<AuthResponse> register(String email, String password);

  /// Sign in with Google (token id).
  Future<AuthResponse> googleLogin(String idToken);

  /// Actualiza el perfil del usuario autenticado.
  Future<void> updateProfile({
    required String accessToken,
    required Map<String, dynamic> data,
  });

  /// Obtiene el perfil del usuario autenticado.
  Future<Map<String, dynamic>> getProfile({required String accessToken});

  /// Obtiene las citas del usuario autenticado.
  Future<List<dynamic>> getMyAppointments({required String accessToken});

  /// Send the password recovery email.
  Future<void> sendPasswordResetEmail(String email);
}
