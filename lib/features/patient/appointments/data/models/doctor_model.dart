class DoctorModel {
  final String id;
  final String name;
  final String specialty;
  final List<String> specialties;
  final double rating;
  final String location;
  final bool isVirtual;
  final String avatarUrl;
  final String nextDateLabel;
  final List<String> timeSlots;
  final List<String> originalSlots;
  final List<Map<String, dynamic>> rawSlots;
  String? selectedTimeSlot;

  DoctorModel({
    required this.id,
    required this.name,
    required this.specialty,
    required this.specialties,
    required this.rating,
    required this.location,
    required this.isVirtual,
    required this.avatarUrl,
    required this.nextDateLabel,
    required this.timeSlots,
    required this.originalSlots,
    required this.rawSlots,
    this.selectedTimeSlot,
  });
}
