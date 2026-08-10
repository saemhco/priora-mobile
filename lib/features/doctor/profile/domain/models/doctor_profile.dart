import 'package:priora/features/doctor/profile/domain/models/doctor_profession.dart';
import 'package:priora/features/doctor/profile/domain/models/doctor_specialty.dart';

/// Perfil del profesional autenticado (entidad de dominio, independiente de la
/// API). Endpoint: GET /users/me/professional-profile.
class DoctorProfile {
  const DoctorProfile({
    required this.id,
    required this.email,
    required this.role,
    required this.name,
    required this.profileComplete,
    this.firstName,
    this.lastName,
    this.documentId,
    this.documentType,
    this.phone,
    this.profilePhotoUrl,
    this.bio,
    this.rating,
    this.specialties = const [],
    this.professions = const [],
  });

  final String id;
  final String email;
  final String role;
  final String name;
  final String? firstName;
  final String? lastName;
  final String? documentId;
  final String? documentType;
  final String? phone;
  final String? profilePhotoUrl;
  final bool profileComplete;
  final String? bio;
  final double? rating;
  final List<DoctorSpecialty> specialties;
  final List<DoctorProfession> professions;

  String get displayName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName'.trim();
    }
    return name.isNotEmpty ? name : 'Profesional de salud';
  }

  String? get primarySpecialty =>
      specialties.isNotEmpty ? specialties.first.name : null;

  int get completionPercent {
    var completed = 0;
    if (bio != null && bio!.trim().isNotEmpty) completed++;
    if (profilePhotoUrl != null && profilePhotoUrl!.isNotEmpty) completed++;
    if (phone != null && phone!.trim().isNotEmpty) completed++;
    if (specialties.isNotEmpty) completed++;
    return (completed / 4 * 100).round();
  }
}
