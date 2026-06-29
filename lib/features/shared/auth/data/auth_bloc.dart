import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:priora/features/shared/auth/data/auth_event.dart';
import 'package:priora/features/shared/auth/data/auth_repository.dart';
import 'package:priora/features/shared/auth/data/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(const AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthGoogleLoginRequested>(_onGoogleLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthUpdateProfileRequested>(_onUpdateProfileRequested);
    on<AuthLoadProfileRequested>(_onLoadProfileRequested);
    on<AuthRestoreSessionRequested>(_onRestoreSessionRequested);
    on<AuthTokenRefreshed>(_onTokenRefreshed);
  }

  Future<void> _saveSession({
    required String accessToken,
    String? refreshToken,
    required String role,
    required bool profileComplete,
    String? firstName,
    String? lastName,
    String? profilePhotoUrl,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('accessToken', accessToken);
      if (refreshToken != null) {
        await prefs.setString('refreshToken', refreshToken);
      }
      await prefs.setString('role', role);
      await prefs.setBool('profileComplete', profileComplete);
      if (firstName != null) await prefs.setString('firstName', firstName);
      if (lastName != null) await prefs.setString('lastName', lastName);
      if (profilePhotoUrl != null) await prefs.setString('profilePhotoUrl', profilePhotoUrl);
    } catch (e) {
      print('Error saving session: $e');
    }
  }

  Future<void> _clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('accessToken');
      await prefs.remove('refreshToken');
      await prefs.remove('role');
      await prefs.remove('profileComplete');
      await prefs.remove('firstName');
      await prefs.remove('lastName');
      await prefs.remove('profilePhotoUrl');
    } catch (e) {
      print('Error clearing session: $e');
    }
  }

  Future<void> _onRestoreSessionRequested(
    AuthRestoreSessionRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');
      final role = prefs.getString('role');
      final profileComplete = prefs.getBool('profileComplete') ?? false;

      if (token != null && token.isNotEmpty && role != null) {
        final firstName = prefs.getString('firstName');
        final lastName = prefs.getString('lastName');
        final profilePhotoUrl = prefs.getString('profilePhotoUrl');

        emit(
          AuthAuthenticated(
            role: role,
            accessToken: token,
            profileComplete: profileComplete,
            firstName: firstName,
            lastName: lastName,
            profilePhotoUrl: profilePhotoUrl,
          ),
        );
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final result = await _authRepository.register(event.email, event.password);
      final role = result.user.role.toLowerCase();
      final token = result.accessToken;
      final profileComplete = result.user.profileComplete;

      await _saveSession(
        accessToken: token,
        refreshToken: result.refreshToken,
        role: role,
        profileComplete: profileComplete,
      );

      emit(
        AuthAuthenticated(
          role: role,
          accessToken: token,
          profileComplete: profileComplete,
        ),
      );
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final result = await _authRepository.login(event.email, event.password);
      String? firstName;
      String? lastName;
      String? profilePhotoUrl;

      if (result.user.profileComplete) {
        try {
          final profile = await _authRepository.getProfile(accessToken: result.accessToken);
          firstName = profile['firstName'];
          lastName = profile['lastName'];
          profilePhotoUrl = profile['profilePhotoUrl'];
        } catch (_) {}
      }

      final role = result.user.role.toLowerCase();
      await _saveSession(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
        role: role,
        profileComplete: result.user.profileComplete,
        firstName: firstName,
        lastName: lastName,
        profilePhotoUrl: profilePhotoUrl,
      );

      emit(
        AuthAuthenticated(
          role: role,
          accessToken: result.accessToken,
          profileComplete: result.user.profileComplete,
          firstName: firstName,
          lastName: lastName,
          profilePhotoUrl: profilePhotoUrl,
        ),
      );
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onGoogleLoginRequested(
    AuthGoogleLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email']);

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        // User cancelled the sign-in flow
        emit(const AuthInitial());
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null || idToken.isEmpty) {
        throw Exception('No se pudo obtener el token de Google');
      }

      final result = await _authRepository.googleLogin(idToken);
      final role = result.user.role.toLowerCase();
      final standardizedRole = (role == 'medico' || role == 'doctor')
          ? 'doctor'
          : 'patient';

      String? firstName;
      String? lastName;
      String? profilePhotoUrl;

      if (result.user.profileComplete) {
        try {
          final profile = await _authRepository.getProfile(accessToken: result.accessToken);
          firstName = profile['firstName'];
          lastName = profile['lastName'];
          profilePhotoUrl = profile['profilePhotoUrl'];
        } catch (_) {}
      }

      await _saveSession(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
        role: standardizedRole,
        profileComplete: result.user.profileComplete,
        firstName: firstName,
        lastName: lastName,
        profilePhotoUrl: profilePhotoUrl,
      );

      emit(
        AuthAuthenticated(
          role: standardizedRole,
          accessToken: result.accessToken,
          profileComplete: result.user.profileComplete,
          firstName: firstName,
          lastName: lastName,
          profilePhotoUrl: profilePhotoUrl,
        ),
      );
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onUpdateProfileRequested(
    AuthUpdateProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _authRepository.updateProfile(
        accessToken: event.accessToken,
        data: event.profileData,
      );
      
      final firstName = event.profileData['firstName']?.toString();
      final lastName = event.profileData['lastName']?.toString();
      final profilePhotoUrl = event.profileData['profilePhotoUrl']?.toString();

      await _saveSession(
        accessToken: event.accessToken,
        role: event.role,
        profileComplete: true,
        firstName: firstName,
        lastName: lastName,
        profilePhotoUrl: profilePhotoUrl,
      );

      emit(
        AuthAuthenticated(
          role: event.role,
          accessToken: event.accessToken,
          profileComplete: true,
          firstName: firstName,
          lastName: lastName,
          profilePhotoUrl: profilePhotoUrl,
        ),
      );
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
      emit(
        AuthAuthenticated(
          role: event.role,
          accessToken: event.accessToken,
          profileComplete: false,
        ),
      );
    }
  }

  Future<void> _onLoadProfileRequested(
    AuthLoadProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    final currentState = state;
    if (currentState is AuthAuthenticated) {
      try {
        final profile = await _authRepository.getProfile(accessToken: currentState.accessToken);
        
        final firstName = profile['firstName']?.toString();
        final lastName = profile['lastName']?.toString();
        final profilePhotoUrl = profile['profilePhotoUrl']?.toString();

        await _saveSession(
          accessToken: currentState.accessToken,
          role: currentState.role,
          profileComplete: currentState.profileComplete,
          firstName: firstName,
          lastName: lastName,
          profilePhotoUrl: profilePhotoUrl,
        );

        emit(
          AuthAuthenticated(
            role: currentState.role,
            accessToken: currentState.accessToken,
            profileComplete: currentState.profileComplete,
            firstName: firstName,
            lastName: lastName,
            profilePhotoUrl: profilePhotoUrl,
          ),
        );
      } catch (_) {}
    }
  }

  Future<void> _onLogoutRequested(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    await _clearSession();
    emit(const AuthUnauthenticated());
  }

  Future<void> _onTokenRefreshed(AuthTokenRefreshed event, Emitter<AuthState> emit) async {
    final currentState = state;
    if (currentState is AuthAuthenticated) {
      emit(
        AuthAuthenticated(
          role: currentState.role,
          accessToken: event.accessToken,
          profileComplete: currentState.profileComplete,
          firstName: currentState.firstName,
          lastName: currentState.lastName,
          profilePhotoUrl: currentState.profilePhotoUrl,
        ),
      );
    }
  }
}

