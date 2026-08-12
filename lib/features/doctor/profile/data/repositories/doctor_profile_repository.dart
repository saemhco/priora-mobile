import 'package:priora/features/doctor/profile/data/services/doctor_profile_service.dart';
import 'package:priora/features/doctor/profile/domain/interfaces/doctor_profile_repository.dart';
import 'package:priora/features/doctor/profile/domain/models/doctor_profile.dart';

/// Implementation of the [DoctorProfileRepository] contract using
/// [DoctorProfileService]. Map DTOs to domain entities.
class DoctorProfileRepositoryImpl implements DoctorProfileRepository {
  DoctorProfileRepositoryImpl(this._service);

  final DoctorProfileService _service;

  @override
  Future<DoctorProfile> getProfessionalProfile({
    required String accessToken,
  }) async {
    final dto = await _service.getProfessionalProfile(
      accessToken: accessToken,
    );
    return dto.toDomain();
  }

  @override
  Future<DoctorProfile> updateProfessionalProfile({
    required String accessToken,
    required Map<String, dynamic> data,
  }) async {
    final dto = await _service.updateProfessionalProfile(
      accessToken: accessToken,
      data: data,
    );
    return dto.toDomain();
  }
}
