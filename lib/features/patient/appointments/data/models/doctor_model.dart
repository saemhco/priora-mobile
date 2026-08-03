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

  /// Devuelve el tipo de reunión (VIRTUAL / IN_PERSON) del slot que coincide
  /// con la hora dada (formato HH:mm), o null si no se encuentra.
  String? meetingTypeForSlot(String hour) {
    for (final slot in rawSlots) {
      final datetimeStr = slot['datetime']?.toString() ?? '';
      if (datetimeStr.isEmpty) continue;
      try {
        final dt = DateTime.parse(datetimeStr).toLocal();
        final h = dt.hour.toString().padLeft(2, '0');
        final m = dt.minute.toString().padLeft(2, '0');
        if ('$h:$m' == hour) {
          return slot['meetingType']?.toString().toUpperCase();
        }
      } catch (_) {
        // Ignorar slots con fecha inválida
      }
    }
    return null;
  }

  /// Devuelve el datetime ISO completo del slot que coincide con la hora dada
  /// (formato HH:mm en hora local), o una cadena vacía si no se encuentra.
  String originalSlotForHour(String hour) {
    for (final slot in originalSlots) {
      try {
        final dt = DateTime.parse(slot).toLocal();
        final h = dt.hour.toString().padLeft(2, '0');
        final m = dt.minute.toString().padLeft(2, '0');
        if ('$h:$m' == hour) {
          return slot;
        }
      } catch (_) {
        // Ignorar slots con fecha inválida
      }
    }
    return '';
  }
}
