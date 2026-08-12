import 'package:priora/features/doctor/profile/domain/models/doctor_specialty.dart';

/// DTO of a specialty of the professional (API serialization).
class DoctorSpecialtyDto {
  const DoctorSpecialtyDto({
    required this.id,
    required this.name,
    this.professionName,
  });

  factory DoctorSpecialtyDto.fromJson(Map<String, dynamic> json) {
    final profession = json['profession'];
    return DoctorSpecialtyDto(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      professionName: profession is Map ? profession['name']?.toString() : null,
    );
  }

  final String id;
  final String name;
  final String? professionName;

  DoctorSpecialty toDomain() {
    return DoctorSpecialty(
      id: id,
      name: name,
      professionName: professionName,
    );
  }
}
