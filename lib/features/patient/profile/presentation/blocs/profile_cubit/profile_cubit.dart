import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:priora/features/patient/profile/presentation/blocs/profile_cubit/profile_state.dart';
import 'package:priora/features/patient/profile/data/models/patient_profile_model.dart';
import 'package:priora/features/patient/profile/data/profile_repository.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _repository;

  ProfileCubit(this._repository) : super(const ProfileInitial());

  Future<void> loadProfile({required String accessToken}) async {
    emit(const ProfileLoading());
    try {
      final profile = await _repository.getProfile(accessToken: accessToken);
      emit(ProfileLoaded(profile));
    } catch (e) {
      emit(ProfileError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> updateProfile({
    required String accessToken,
    required Map<String, dynamic> data,
  }) async {
    final currentState = state;
    PatientProfileModel? currentModel;
    if (currentState is ProfileLoaded) {
      currentModel = currentState.profile;
    } else if (currentState is ProfileUpdating) {
      currentModel = currentState.currentProfile;
    }

    if (currentModel != null) {
      emit(ProfileUpdating(currentModel));
    } else {
      emit(const ProfileLoading());
    }

    try {
      await _repository.updateProfile(accessToken: accessToken, data: data);
      final updatedProfile = await _repository.getProfile(
        accessToken: accessToken,
      );
      emit(ProfileUpdated(updatedProfile));
      emit(ProfileLoaded(updatedProfile));
    } catch (e) {
      emit(ProfileError(e.toString().replaceAll('Exception: ', '')));
      if (currentModel != null) {
        emit(ProfileLoaded(currentModel));
      }
    }
  }
}
