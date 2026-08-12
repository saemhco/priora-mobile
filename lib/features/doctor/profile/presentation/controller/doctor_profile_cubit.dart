import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:priora/features/doctor/profile/domain/interfaces/doctor_profile_repository.dart';
import 'package:priora/features/doctor/profile/presentation/controller/doctor_profile_state.dart';
import 'package:priora/features/doctor/profile/presentation/controller/doctor_profile_update_result.dart';

/// Controla el perfil del profesional autenticado.
/// Lo comparten la agenda (avatar) y la pantalla de perfil.
class DoctorProfileCubit extends Cubit<DoctorProfileState> {
  DoctorProfileCubit(
    this._repository,
    this._accessToken,
  ) : super(const DoctorProfileState());

  final DoctorProfileRepository _repository;
  final String _accessToken;

  /// Carga el perfil del profesional (GET /users/me/professional-profile).
  Future<void> loadProfile() async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final profile = await _repository.getProfessionalProfile(
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

  /// Actualiza el perfil del profesional
  /// (PATCH /users/me/professional-profile).
  Future<DoctorProfileUpdateResult> updateProfile({
    required Map<String, dynamic> data,
  }) async {
    emit(state.copyWith(isUpdating: true, clearError: true));
    try {
      final profile = await _repository.updateProfessionalProfile(
        accessToken: _accessToken,
        data: data,
      );
      emit(
        state.copyWith(
          profile: profile,
          isUpdating: false,
          clearError: true,
        ),
      );
      return const DoctorProfileUpdateResult(success: true);
    } on DioException catch (e) {
      emit(state.copyWith(isUpdating: false));
      return DoctorProfileUpdateResult(
        success: false,
        message: _extractError(e),
      );
    } catch (e) {
      debugPrint('Error updating profile: $e');
      emit(state.copyWith(isUpdating: false));
      return const DoctorProfileUpdateResult(
        success: false,
        message: 'Error al actualizar el perfil. Inténtalo de nuevo.',
      );
    }
  }

  String _extractError(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      final msg = data['message'];
      if (msg is String && msg.isNotEmpty) return msg;
      if (msg is List && msg.isNotEmpty) return msg.join('\n');
    }
    switch (e.response?.statusCode) {
      case 400:
        return 'No se pudo actualizar el perfil. Revisa los datos ingresados.';
      case 403:
        return 'No tienes permisos para actualizar este perfil.';
      default:
        return 'Error al actualizar el perfil. Inténtalo de nuevo.';
    }
  }
}
