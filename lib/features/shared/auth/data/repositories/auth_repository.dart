import 'package:priora/features/shared/auth/data/services/auth_service.dart';
import 'package:priora/features/shared/auth/domain/interfaces/auth_repository.dart';
import 'package:priora/features/shared/auth/domain/models/auth_response.dart';
import 'package:priora/features/shared/auth/domain/models/email_verification_pending.dart';

/// Implementation of the contract [AuthRepository] using [AuthService].
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._service);

  final AuthService _service;

  @override
  Future<AuthResponse> login(String email, String password) async {
    final data = await _service.login(email, password);
    return AuthResponse.fromJson(data);
  }

  @override
  Future<EmailVerificationPending> register(
    String email,
    String password,
  ) {
    return _service.register(email, password);
  }

  @override
  Future<AuthResponse> verifyEmail({
    required String email,
    required String code,
  }) async {
    final data = await _service.verifyEmail(email, code);
    return AuthResponse.fromJson(data);
  }

  @override
  Future<EmailVerificationPending> resendVerification(String email) {
    return _service.resendVerification(email);
  }

  @override
  Future<AuthResponse> googleLogin(String idToken) async {
    final data = await _service.googleLogin(idToken);
    return AuthResponse.fromJson(data);
  }

  @override
  Future<void> updateProfile({
    required String accessToken,
    required Map<String, dynamic> data,
  }) {
    return _service.updateProfile(accessToken: accessToken, data: data);
  }

  @override
  Future<Map<String, dynamic>> getProfile({
    required String accessToken,
  }) {
    return _service.getProfile(accessToken: accessToken);
  }

  @override
  Future<List<dynamic>> getMyAppointments({
    required String accessToken,
  }) {
    return _service.getMyAppointments(accessToken: accessToken);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) {
    return _service.sendPasswordResetEmail(email);
  }
}
