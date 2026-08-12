/// Perfil del paciente (entidad de dominio, independiente de la API).
class PatientProfile {
  PatientProfile({
    required this.id,
    required this.email,
    required this.role,
    required this.name,
    required this.firstName,
    required this.lastName,
    required this.profileComplete,
    this.documentId,
    this.documentType,
    this.phone,
    this.profilePhotoUrl,
    this.dateOfBirth,
    this.biologicalSex,
    this.genderIdentity,
    this.genderIdentityOther,
    this.occupation,
    this.latitude,
    this.longitude,
    this.description,
  });

  final String id;
  final String email;
  final String role;
  final String name;
  final String firstName;
  final String lastName;
  final String? documentId;
  final String? documentType;
  final String? phone;
  final String? profilePhotoUrl;
  final String? dateOfBirth;
  final String? biologicalSex;
  final String? genderIdentity;
  final String? genderIdentityOther;
  final String? occupation;
  final double? latitude;
  final double? longitude;
  final String? description;
  final bool profileComplete;
}
