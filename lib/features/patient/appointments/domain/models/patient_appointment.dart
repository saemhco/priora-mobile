/// Patient appointment (typed domain entity, rather than dynamic maps).
class PatientAppointment {
  const PatientAppointment({
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

  final String id;
  final String doctorId;
  final String datetime; // ISO string
  final String formattedDate;
  final String formattedTime;
  final String doctorName;
  final String doctorSpecialty;
  final String doctorAvatar;
  final bool isVirtual;
  final String status;
}
