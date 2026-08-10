import 'package:priora/features/doctor/appointments/domain/models/doctor_appointment_patient.dart';

/// Patient DTO of an appointment (API serialization).
class DoctorAppointmentPatientDto {
  const DoctorAppointmentPatientDto({
    required this.id,
    this.firstName,
    this.lastName,
    this.profilePhotoUrl,
  });

  factory DoctorAppointmentPatientDto.fromJson(Map<String, dynamic> json) {
    return DoctorAppointmentPatientDto(
      id: json['id'] as String? ?? '',
      firstName: json['firstName'] as String? ?? json['name'] as String?,
      lastName: json['lastName'] as String?,
      profilePhotoUrl: json['profilePhotoUrl'] as String?,
    );
  }

  final String id;
  final String? firstName;
  final String? lastName;
  final String? profilePhotoUrl;

  DoctorAppointmentPatient toDomain() {
    return DoctorAppointmentPatient(
      id: id,
      firstName: firstName,
      lastName: lastName,
      profilePhotoUrl: profilePhotoUrl,
    );
  }
}
