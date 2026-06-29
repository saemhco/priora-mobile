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

class AuthLoadProfileRequested extends AuthEvent {
  const AuthLoadProfileRequested();
}

class AuthRestoreSessionRequested extends AuthEvent {
  const AuthRestoreSessionRequested();
}

class AuthSessionSaved extends AuthEvent {
  final String role;
  final String accessToken;
  final bool profileComplete;
  final String? firstName;
  final String? lastName;
  final String? profilePhotoUrl;

  const AuthSessionSaved({
    required this.role,
    required this.accessToken,
    required this.profileComplete,
    this.firstName,
    this.lastName,
    this.profilePhotoUrl,
  });
}

class AuthTokenRefreshed extends AuthEvent {
  final String accessToken;
  final String refreshToken;

  const AuthTokenRefreshed({
    required this.accessToken,
    required this.refreshToken,
  });
}


