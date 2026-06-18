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
  final String role;
  final String accessToken;
  final bool profileComplete;
  final String? firstName;
  final String? lastName;
  final String? profilePhotoUrl;

  const AuthAuthenticated({
    required this.role,
    required this.accessToken,
    this.profileComplete = true,
    this.firstName,
    this.lastName,
    this.profilePhotoUrl,
  });
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);
}
