import 'package:priora/features/doctor/profile/domain/models/doctor_profile.dart';

/// Contract for access to the professional's profile. The presentation layer
/// depends solely on this abstraction; the implementation lives in
/// `data/repositories/`.
abstract interface class DoctorProfileRepository {
  /// Obtiene el perfil del profesional autenticado.
  Future<DoctorProfile> getProfessionalProfile({
    required String accessToken,
  });

  /// Actualiza el perfil del profesional autenticado.
  Future<DoctorProfile> updateProfessionalProfile({
    required String accessToken,
    required Map<String, dynamic> data,
  });
}
