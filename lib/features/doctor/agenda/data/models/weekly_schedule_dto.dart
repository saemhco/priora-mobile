import 'package:priora/features/doctor/agenda/data/models/weekly_schedule_place_dto.dart';
import 'package:priora/features/doctor/agenda/domain/models/weekly_schedule.dart';

/// DTO of the weekly availability block (API serialization).
class WeeklyScheduleDto {
  const WeeklyScheduleDto({
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

  factory WeeklyScheduleDto.fromJson(Map<String, dynamic> json) {
    return WeeklyScheduleDto(
      id: json['id'] as String,
      dayOfWeek: json['dayOfWeek'] as int,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      validFrom: json['validFrom'] as String?,
      validTo: json['validTo'] as String?,
      slotDurationMinutes: (json['slotDurationMinutes'] as num).toInt(),
      meetingType: json['meetingType'] as String,
      place: json['place'] != null
          ? WeeklySchedulePlaceDto.fromJson(
              json['place'] as Map<String, dynamic>,
            )
          : null,
      createdAt: json['createdAt'] as String,
    );
  }

  final String id;
  final int dayOfWeek; // 1=Mon … 7=Sun
  final String startTime; // HH:mm
  final String endTime; // HH:mm
  final String? validFrom; // YYYY-MM-DD
  final String? validTo; // YYYY-MM-DD
  final int slotDurationMinutes;
  final String meetingType; // VIRTUAL | IN_PERSON
  final WeeklySchedulePlaceDto? place;
  final String createdAt;

  WeeklySchedule toDomain() {
    return WeeklySchedule(
      id: id,
      dayOfWeek: dayOfWeek,
      startTime: startTime,
      endTime: endTime,
      validFrom: validFrom,
      validTo: validTo,
      slotDurationMinutes: slotDurationMinutes,
      meetingType: meetingType,
      place: place?.toDomain(),
      createdAt: createdAt,
    );
  }
}
