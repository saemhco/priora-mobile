import 'package:priora/features/patient/profile/domain/models/patient_profile.dart';

/// Patient profile access contract. The presentation layer depends solely on
/// this abstraction; the implementation lives in `data/repositories/`.
abstract interface class ProfileRepository {
  /// Obtiene el perfil del paciente autenticado.
  Future<PatientProfile> getProfile({required String accessToken});

  /// Actualiza el perfil del paciente autenticado.
  Future<void> updateProfile({
    required String accessToken,
    required Map<String, dynamic> data,
  });
}
