abstract class AuthEvent {
  const AuthEvent();
}

class AuthLoginRequested extends AuthEvent {
  const AuthLoginRequested({required this.email, required this.password});
  final String email;
  final String password;
}

class AuthRegisterRequested extends AuthEvent {
  const AuthRegisterRequested({required this.email, required this.password});
  final String email;
  final String password;
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

class AuthGoogleLoginRequested extends AuthEvent {
  const AuthGoogleLoginRequested();
}

class AuthUpdateProfileRequested extends AuthEvent {
  const AuthUpdateProfileRequested({
    required this.profileData,
    required this.accessToken,
    required this.role,
  });
  final Map<String, dynamic> profileData;
  final String accessToken;
  final String role;
}

class AuthLoadProfileRequested extends AuthEvent {
  const AuthLoadProfileRequested();
}

class AuthRestoreSessionRequested extends AuthEvent {
  const AuthRestoreSessionRequested();
}

class AuthSessionSaved extends AuthEvent {
  const AuthSessionSaved({
    required this.role,
    required this.accessToken,
    required this.profileComplete,
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

class AuthTokenRefreshed extends AuthEvent {
  const AuthTokenRefreshed({
    required this.accessToken,
    required this.refreshToken,
  });
  final String accessToken;
  final String refreshToken;
}
