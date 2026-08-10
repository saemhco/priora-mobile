import 'package:priora/features/doctor/appointments/domain/models/doctor_appointment_patient.dart';

/// Cita del doctor (entidad de dominio, independiente de la API).
class DoctorAppointment {
  const DoctorAppointment({
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

  final String id;
  final DoctorAppointmentPatient patient;
  final String datetime; // ISO string
  final String meetingType; // VIRTUAL | IN_PERSON
  final String? placeName;
  final String status; // PENDING | CONFIRMED | COMPLETED | CANCELED
  final String? specialty;
  final String? triageSessionId;
  final String createdAt;

  bool get isVirtual => meetingType == 'VIRTUAL';

  DateTime get dateTimeObj => DateTime.parse(datetime);

  String get formattedTime {
    final dt = dateTimeObj;
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String get formattedDate {
    final dt = dateTimeObj;
    const months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
    ];
    return '${dt.day} ${months[dt.month - 1]}';
  }

  String get statusLabel {
    switch (status) {
      case 'CONFIRMED':
        return 'Confirmada';
      case 'PENDING':
        return 'Pendiente';
      case 'COMPLETED':
        return 'Completada';
      case 'CANCELED':
        return 'Cancelada';
      default:
        return status;
    }
  }

  bool get isPast {
    return dateTimeObj.isBefore(DateTime.now());
  }

  bool get isToday {
    final now = DateTime.now();
    final apptDate = dateTimeObj;
    return apptDate.year == now.year &&
        apptDate.month == now.month &&
        apptDate.day == now.day;
  }
}
