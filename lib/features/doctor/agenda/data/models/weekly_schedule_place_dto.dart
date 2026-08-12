import 'package:priora/features/doctor/agenda/domain/models/weekly_schedule_place.dart';

/// DTO of the place of care associated with a weekly block (API
/// serialization).
class WeeklySchedulePlaceDto {
  const WeeklySchedulePlaceDto({
    required this.id,
    required this.name,
    this.district,
  });

  factory WeeklySchedulePlaceDto.fromJson(Map<String, dynamic> json) {
    return WeeklySchedulePlaceDto(
      id: json['id'] as String,
      name: json['name'] as String,
      district: json['district'] as String?,
    );
  }

  final String id;
  final String name;
  final String? district;

  WeeklySchedulePlace toDomain() {
    return WeeklySchedulePlace(
      id: id,
      name: name,
      district: district,
    );
  }
}
