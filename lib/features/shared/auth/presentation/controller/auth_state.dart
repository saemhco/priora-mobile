abstract class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated({
    required this.role,
    required this.accessToken,
    this.profileComplete = true,
    this.firstName,
    this.lastName,
    this.profilePhotoUrl,
  });
  final String role;
  final String accessToken;
  final bool profileComplete;
  final String? firstName;
  final String? lastName;
  final String? profilePhotoUrl;
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// The account exists but the email still needs OTP confirmation
/// (returned by register or by login with 403 EMAIL_NOT_VERIFIED).
class AuthEmailVerificationRequired extends AuthState {
  const AuthEmailVerificationRequired({
    required this.email,
    this.sent = true,
    this.retryAfterSeconds = 600,
    this.remainingToday = 5,
  });
  final String email;
  final bool sent;
  final int retryAfterSeconds;
  final int remainingToday;
}

class AuthError extends AuthState {
  const AuthError(this.message);
  final String message;
}
