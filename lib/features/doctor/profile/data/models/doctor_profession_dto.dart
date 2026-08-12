import 'package:priora/features/doctor/profile/domain/models/doctor_profession.dart';

/// DTO of a professional profession (API serialization).
class DoctorProfessionDto {
  const DoctorProfessionDto({
    required this.id,
    required this.name,
  });

  factory DoctorProfessionDto.fromJson(Map<String, dynamic> json) {
    return DoctorProfessionDto(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }

  final String id;
  final String name;

  DoctorProfession toDomain() {
    return DoctorProfession(
      id: id,
      name: name,
    );
  }
}
