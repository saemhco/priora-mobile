import 'package:priora/features/patient/profile/data/models/patient_profile_model.dart';
import 'package:priora/features/patient/profile/data/profile_service.dart';

class ProfileRepository {
  final ProfileService _service;

  ProfileRepository(this._service);

  Future<PatientProfileModel> getProfile({required String accessToken}) async {
    final rawProfile = await _service.getProfile(accessToken: accessToken);
    return PatientProfileModel.fromJson(rawProfile);
  }

  Future<void> updateProfile({
    required String accessToken,
    required Map<String, dynamic> data,
  }) async {
    await _service.updateProfile(accessToken: accessToken, data: data);
  }
}
