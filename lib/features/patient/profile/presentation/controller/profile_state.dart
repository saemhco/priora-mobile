import 'package:priora/features/patient/profile/domain/models/patient_profile.dart';

/// Estados del cubit del perfil del paciente.
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
  const ProfileLoaded(this.profile);

  final PatientProfile profile;
}

class ProfileError extends ProfileState {
  const ProfileError(this.message);

  final String message;
}

class ProfileUpdating extends ProfileState {
  const ProfileUpdating(this.currentProfile);

  final PatientProfile currentProfile;
}

class ProfileUpdated extends ProfileState {
  const ProfileUpdated(this.updatedProfile);

  final PatientProfile updatedProfile;
}
