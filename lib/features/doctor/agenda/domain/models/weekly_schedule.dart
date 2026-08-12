import 'package:priora/features/doctor/agenda/domain/models/weekly_schedule_place.dart';

/// Bloque de disponibilidad semanal del doctor (entidad de dominio,
/// independiente de la API).
class WeeklySchedule {
  const WeeklySchedule({
    required this.id,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.slotDurationMinutes,
    required this.meetingType,
    required this.createdAt,
    this.validFrom,
    this.validTo,
    this.place,
  });

  final String id;
  final int dayOfWeek; // 1=Mon … 7=Sun
  final String startTime; // HH:mm
  final String endTime; // HH:mm
  final String? validFrom; // YYYY-MM-DD
  final String? validTo; // YYYY-MM-DD
  final int slotDurationMinutes;
  final String meetingType; // VIRTUAL | IN_PERSON
  final WeeklySchedulePlace? place;
  final String createdAt;
}
