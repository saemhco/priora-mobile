/// Place of care associated with a weekly availability block (domain entity,
/// independent of the API).
class WeeklySchedulePlace {
  const WeeklySchedulePlace({
    required this.id,
    required this.name,
    this.district,
  });

  final String id;
  final String name;
  final String? district;
}
