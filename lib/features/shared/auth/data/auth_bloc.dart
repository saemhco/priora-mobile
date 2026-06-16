import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final result = await _authRepository.register(event.email, event.password);
      emit(
        AuthAuthenticated(
          role: result.user.role.toLowerCase(),
          accessToken: result.accessToken,
          profileComplete: result.user.profileComplete,
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
      emit(
        AuthAuthenticated(
          role: result.user.role.toLowerCase(),
          accessToken: result.accessToken,
          profileComplete: result.user.profileComplete,
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
      emit(
        AuthAuthenticated(
          role: standardizedRole,
          accessToken: result.accessToken,
          profileComplete: result.user.profileComplete,
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
      emit(
        AuthAuthenticated(
          role: event.role,
          accessToken: event.accessToken,
          profileComplete: true,
        ),
      );
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  void _onLogoutRequested(AuthLogoutRequested event, Emitter<AuthState> emit) {
    emit(const AuthUnauthenticated());
  }
}
