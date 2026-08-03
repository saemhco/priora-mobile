class WeeklySchedulePlace {
  final String id;
  final String name;
  final String? district;

  const WeeklySchedulePlace({
    required this.id,
    required this.name,
    this.district,
  });

  factory WeeklySchedulePlace.fromJson(Map<String, dynamic> json) {
    return WeeklySchedulePlace(
      id: json['id'] as String,
      name: json['name'] as String,
      district: json['district'] as String?,
    );
  }
}

class WeeklySchedule {
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

  const WeeklySchedule({
    required this.id,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.validFrom,
    this.validTo,
    required this.slotDurationMinutes,
    required this.meetingType,
    this.place,
    required this.createdAt,
  });

  factory WeeklySchedule.fromJson(Map<String, dynamic> json) {
    return WeeklySchedule(
      id: json['id'] as String,
      dayOfWeek: json['dayOfWeek'] as int,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      validFrom: json['validFrom'] as String?,
      validTo: json['validTo'] as String?,
      slotDurationMinutes: (json['slotDurationMinutes'] as num).toInt(),
      meetingType: json['meetingType'] as String,
      place: json['place'] != null
          ? WeeklySchedulePlace.fromJson(json['place'] as Map<String, dynamic>)
          : null,
      createdAt: json['createdAt'] as String,
    );
  }
}
