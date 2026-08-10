/// Paciente de una cita del doctor (entidad de dominio).
class DoctorAppointmentPatient {
  const DoctorAppointmentPatient({
    required this.id,
    this.firstName,
    this.lastName,
    this.profilePhotoUrl,
  });

  final String id;
  final String? firstName;
  final String? lastName;
  final String? profilePhotoUrl;

  String get fullName {
    if (firstName != null && lastName != null) return '$firstName $lastName';
    if (firstName != null) return firstName!;
    if (lastName != null) return lastName!;
    return 'Paciente';
  }

  String get initials {
    final parts = fullName.split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
  }
}
