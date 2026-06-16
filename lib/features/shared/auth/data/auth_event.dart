abstract class AuthEvent {
  const AuthEvent();
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({required this.email, required this.password});
}

class AuthRegisterRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthRegisterRequested({required this.email, required this.password});
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

class AuthGoogleLoginRequested extends AuthEvent {
  const AuthGoogleLoginRequested();
}

class AuthUpdateProfileRequested extends AuthEvent {
  final Map<String, dynamic> profileData;
  final String accessToken;
  final String role;

  const AuthUpdateProfileRequested({
    required this.profileData,
    required this.accessToken,
    required this.role,
  });
}
