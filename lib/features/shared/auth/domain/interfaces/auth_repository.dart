import 'package:priora/features/shared/auth/domain/models/auth_response.dart';
import 'package:priora/features/shared/auth/domain/models/email_not_verified_exception.dart';
import 'package:priora/features/shared/auth/domain/models/email_verification_pending.dart';

/// Authentication access contract. The presentation layer depends solely on
/// this abstraction; the implementation lives in `data/repositories/`.
abstract interface class AuthRepository {
  /// Log in with your email and password.
  /// Throws [EmailNotVerifiedException] when the email is not verified yet.
  Future<AuthResponse> login(String email, String password);

  /// Registers a new account. Returns the email verification status;
  /// no tokens are issued until [verifyEmail] succeeds.
  Future<EmailVerificationPending> register(String email, String password);

  /// Validates the 6-digit OTP and returns the auth tokens.
  Future<AuthResponse> verifyEmail({
    required String email,
    required String code,
  });

  /// Sends another OTP to [email] if it is still pending verification.
  Future<EmailVerificationPending> resendVerification(String email);

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
