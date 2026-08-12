import 'package:priora/features/doctor/appointments/data/models/doctor_appointment_patient_dto.dart';
import 'package:priora/features/doctor/appointments/domain/models/doctor_appointment.dart';

/// DTO of a doctor's appointment (API serialization).
class DoctorAppointmentDto {
  const DoctorAppointmentDto({
    required this.id,
    required this.patient,
    required this.datetime,
    required this.meetingType,
    required this.status,
    required this.createdAt,
    this.placeName,
    this.specialty,
    this.triageSessionId,
  });

  factory DoctorAppointmentDto.fromJson(Map<String, dynamic> json) {
    // Parse patient data - could be at root level or nested
    DoctorAppointmentPatientDto patient;
    if (json['patient'] != null) {
      patient = DoctorAppointmentPatientDto.fromJson(
        json['patient'] as Map<String, dynamic>,
      );
    } else {
      // Try to build from root fields
      patient = DoctorAppointmentPatientDto(
        id: json['patientId'] as String? ?? '',
        firstName: json['patientFirstName'] as String?,
        lastName: json['patientLastName'] as String?,
        profilePhotoUrl: json['patientPhotoUrl'] as String?,
      );
    }

    // Parse place info
    String? placeName;
    if (json['place'] != null) {
      final place = json['place'] as Map<String, dynamic>;
      placeName = place['name'] as String?;
    } else {
      placeName = json['placeName'] as String?;
    }

    return DoctorAppointmentDto(
      id: json['id'] as String? ?? '',
      patient: patient,
      datetime: json['datetime'] as String? ?? '',
      meetingType: json['meetingType'] as String? ?? 'VIRTUAL',
      placeName: placeName,
      status: json['status'] as String? ?? 'PENDING',
      specialty: json['specialty'] as String?,
      triageSessionId: json['triageSessionId'] as String?,
      createdAt: json['createdAt'] as String? ?? '',
    );
  }

  final String id;
  final DoctorAppointmentPatientDto patient;
  final String datetime; // ISO string
  final String meetingType; // VIRTUAL | IN_PERSON
  final String? placeName;
  final String status; // PENDING | CONFIRMED | COMPLETED | CANCELED
  final String? specialty;
  final String? triageSessionId;
  final String createdAt;

  DoctorAppointment toDomain() {
    return DoctorAppointment(
      id: id,
      patient: patient.toDomain(),
      datetime: datetime,
      meetingType: meetingType,
      placeName: placeName,
      status: status,
      specialty: specialty,
      triageSessionId: triageSessionId,
      createdAt: createdAt,
    );
  }
}
