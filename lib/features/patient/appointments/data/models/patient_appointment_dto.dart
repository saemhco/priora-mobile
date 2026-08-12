import 'package:priora/features/patient/appointments/domain/models/patient_appointment.dart';

/// DTO of a patient appointment (API JSON transformation).
class PatientAppointmentDto {
  const PatientAppointmentDto({
    required this.id,
    required this.doctorId,
    required this.datetime,
    required this.formattedDate,
    required this.formattedTime,
    required this.doctorName,
    required this.doctorSpecialty,
    required this.doctorAvatar,
    required this.isVirtual,
    required this.status,
  });

  /// Construye el DTO a partir del JSON crudo del endpoint /appointments/me.
  factory PatientAppointmentDto.fromApiJson(Map<String, dynamic> item) {
    final doc = item['doctor'] ?? item['professional'] ?? <String, dynamic>{};
    var docName = doc['name']?.toString() ?? '';
    if (docName.isEmpty) {
      final firstName = doc['firstName']?.toString() ?? '';
      final lastName = doc['lastName']?.toString() ?? '';
      docName = '$firstName $lastName'.trim();
    }
    if (docName.isEmpty) {
      docName = 'Doctor';
    }
    if (!docName.startsWith('Dr. ') && !docName.startsWith('Dra. ')) {
      docName = 'Dr. $docName';
    }

    var specName = 'General';
    final specData = doc['specialty'];
    if (specData != null) {
      specName = specData.toString();
    } else if (doc['specialties'] is List &&
        (doc['specialties'] as List).isNotEmpty) {
      specName =
          (doc['specialties'] as List).first['name']?.toString() ?? 'General';
    } else if (doc['professionalProfile']?['specialties'] is List &&
        (doc['professionalProfile']?['specialties'] as List).isNotEmpty) {
      specName =
          (doc['professionalProfile']?['specialties'] as List).first['name']
              ?.toString() ??
          'General';
    }

    var avatar = doc['avatarUrl']?.toString() ?? '';
    if (avatar.isEmpty) {
      avatar = doc['profilePhotoUrl']?.toString() ?? '';
    }
    if (avatar.isEmpty) {
      avatar = doc['professionalProfile']?['profilePhotoUrl']?.toString() ?? '';
    }
    if (avatar.isEmpty) {
      avatar =
          'https://images.unsplash.com/photo-1622253692010-333f2da6031d?q=80&w=256&auto=format&fit=crop';
    }

    var dateStr = '';
    var timeStr = '';
    final dtRaw = item['datetime'];
    if (dtRaw != null) {
      try {
        final dt = DateTime.parse(dtRaw.toString()).toLocal();
        dateStr =
            '${dt.day.toString().padLeft(2, '0')}/'
            '${dt.month.toString().padLeft(2, '0')}/'
            '${dt.year}';
        timeStr =
            '${dt.hour.toString().padLeft(2, '0')}:'
            '${dt.minute.toString().padLeft(2, '0')}';
      } catch (_) {
        dateStr = dtRaw.toString();
      }
    }

    return PatientAppointmentDto(
      id: item['id']?.toString() ?? '',
      doctorId: item['doctorId']?.toString() ?? '',
      datetime: dtRaw?.toString() ?? '',
      formattedDate: dateStr,
      formattedTime: timeStr,
      doctorName: docName,
      doctorSpecialty: specName,
      doctorAvatar: avatar,
      isVirtual:
          item['isVirtual'] == true ||
          item['meetingType']?.toString().toUpperCase() == 'VIRTUAL',
      status: item['status']?.toString() ?? 'Reservada',
    );
  }

  final String id;
  final String doctorId;
  final String datetime;
  final String formattedDate;
  final String formattedTime;
  final String doctorName;
  final String doctorSpecialty;
  final String doctorAvatar;
  final bool isVirtual;
  final String status;

  PatientAppointment toDomain() {
    return PatientAppointment(
      id: id,
      doctorId: doctorId,
      datetime: datetime,
      formattedDate: formattedDate,
      formattedTime: formattedTime,
      doctorName: doctorName,
      doctorSpecialty: doctorSpecialty,
      doctorAvatar: doctorAvatar,
      isVirtual: isVirtual,
      status: status,
    );
  }
}
