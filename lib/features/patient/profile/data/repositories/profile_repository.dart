import 'package:priora/features/patient/profile/data/services/profile_service.dart';
import 'package:priora/features/patient/profile/domain/interfaces/profile_repository.dart';
import 'package:priora/features/patient/profile/domain/models/patient_profile.dart';

/// Implementation of the [ProfileRepository] contract using [ProfileService].
/// Map DTOs to domain entities.
class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._service);

  final ProfileService _service;

  @override
  Future<PatientProfile> getProfile({required String accessToken}) async {
    final dto = await _service.getProfile(accessToken: accessToken);
    return dto.toDomain();
  }

  @override
  Future<void> updateProfile({
    required String accessToken,
    required Map<String, dynamic> data,
  }) {
    return _service.updateProfile(accessToken: accessToken, data: data);
  }
}
