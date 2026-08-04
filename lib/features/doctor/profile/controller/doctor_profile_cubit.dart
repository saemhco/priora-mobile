import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:priora/features/doctor/profile/controller/doctor_profile_state.dart';
import 'package:priora/features/doctor/profile/data/doctor_profile_service.dart';

/// Controla el perfil del profesional autenticado.
/// Lo comparten la agenda (avatar) y la pantalla de perfil.
class DoctorProfileCubit extends Cubit<DoctorProfileState> {
  final DoctorProfileService _service;
  final String _accessToken;

  DoctorProfileCubit(
    this._service,
    this._accessToken,
  ) : super(const DoctorProfileState());

  /// Carga el perfil del profesional (GET /users/me/professional-profile).
  Future<void> loadProfile() async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final profile = await _service.getProfessionalProfile(
        accessToken: _accessToken,
      );
      emit(
        state.copyWith(
          profile: profile,
          isLoading: false,
          clearError: true,
        ),
      );
    } catch (e) {
      debugPrint('Error loading profile: $e');
      emit(
        state.copyWith(
          isLoading: false,
          error: 'No se pudo cargar el perfil',
        ),
      );
    }
  }
}
