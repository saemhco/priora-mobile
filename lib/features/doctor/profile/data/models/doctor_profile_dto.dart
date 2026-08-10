import 'package:priora/features/doctor/profile/data/models/doctor_profession_dto.dart';
import 'package:priora/features/doctor/profile/data/models/doctor_specialty_dto.dart';
import 'package:priora/features/doctor/profile/domain/models/doctor_profile.dart';

/// DTO of the professional's profile (API serialization).
class DoctorProfileDto {
  const DoctorProfileDto({
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

  factory DoctorProfileDto.fromJson(Map<String, dynamic> json) {
    final professional = json['professionalProfile'];
    Map<String, dynamic> professionalJson;
    if (professional is Map) {
      professionalJson = Map<String, dynamic>.from(professional);
    } else {
      professionalJson = <String, dynamic>{};
    }

    final specialtiesJson = professionalJson['specialties'];
    final professionsJson = professionalJson['professions'];

    return DoctorProfileDto(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      firstName: json['firstName']?.toString(),
      lastName: json['lastName']?.toString(),
      documentId: json['documentId']?.toString(),
      documentType: json['documentType']?.toString(),
      phone: json['phone']?.toString(),
      profilePhotoUrl: json['profilePhotoUrl']?.toString(),
      profileComplete: json['profileComplete'] == true,
      bio: professionalJson['bio']?.toString(),
      rating: professionalJson['rating'] != null
          ? double.tryParse(professionalJson['rating'].toString())
          : null,
      specialties: specialtiesJson is List
          ? specialtiesJson
                .whereType<Map<dynamic, dynamic>>()
                .map(
                  (e) =>
                      DoctorSpecialtyDto.fromJson(Map<String, dynamic>.from(e)),
                )
                .toList()
          : const [],
      professions: professionsJson is List
          ? professionsJson
                .whereType<Map<dynamic, dynamic>>()
                .map(
                  (e) => DoctorProfessionDto.fromJson(
                    Map<String, dynamic>.from(e),
                  ),
                )
                .toList()
          : const [],
    );
  }

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
  final List<DoctorSpecialtyDto> specialties;
  final List<DoctorProfessionDto> professions;

  DoctorProfile toDomain() {
    return DoctorProfile(
      id: id,
      email: email,
      role: role,
      name: name,
      firstName: firstName,
      lastName: lastName,
      documentId: documentId,
      documentType: documentType,
      phone: phone,
      profilePhotoUrl: profilePhotoUrl,
      profileComplete: profileComplete,
      bio: bio,
      rating: rating,
      specialties: specialties.map((s) => s.toDomain()).toList(),
      professions: professions.map((p) => p.toDomain()).toList(),
    );
  }
}
