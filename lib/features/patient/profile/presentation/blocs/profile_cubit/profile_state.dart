import 'package:priora/features/patient/profile/data/models/patient_profile_model.dart';

abstract class ProfileState {
  const ProfileState();
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final PatientProfileModel profile;

  const ProfileLoaded(this.profile);
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);
}

class ProfileUpdating extends ProfileState {
  final PatientProfileModel currentProfile;

  const ProfileUpdating(this.currentProfile);
}

class ProfileUpdated extends ProfileState {
  final PatientProfileModel updatedProfile;

  const ProfileUpdated(this.updatedProfile);
}
