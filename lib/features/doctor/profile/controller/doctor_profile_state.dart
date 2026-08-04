import 'package:flutter/foundation.dart';
import 'package:priora/features/doctor/profile/data/models/doctor_profile_model.dart';

/// Estado del perfil del profesional autenticado.
@immutable
class DoctorProfileState {
  final DoctorProfileModel? profile;
  final bool isLoading;
  final String? error;

  const DoctorProfileState({
    this.profile,
    this.isLoading = true,
    this.error,
  });

  DoctorProfileState copyWith({
    DoctorProfileModel? profile,
    bool clearProfile = false,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return DoctorProfileState(
      profile: clearProfile ? null : (profile ?? this.profile),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
