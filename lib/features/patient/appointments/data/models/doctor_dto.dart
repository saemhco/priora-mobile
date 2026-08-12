import 'package:priora/features/patient/appointments/domain/models/doctor.dart';

/// DTO of a doctor with availability (transformation of the JSON of the API).
class DoctorDto {
  const DoctorDto({
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
  });

  /// Construye el DTO a partir del JSON crudo del endpoint de disponibilidad.
  factory DoctorDto.fromApiJson(Map<String, dynamic> item) {
    var docName = item['name']?.toString() ?? '';
    if (docName.isEmpty) {
      final firstName = item['firstName']?.toString() ?? '';
      final lastName = item['lastName']?.toString() ?? '';
      docName = '$firstName $lastName'.trim();
    }
    if (docName.isEmpty) {
      docName = 'Doctor';
    }
    if (!docName.startsWith('Dr. ') && !docName.startsWith('Dra. ')) {
      docName = 'Dr. $docName';
    }

    var specName = 'General';
    var specialtiesList = <String>[];

    final specData = item['specialty'];
    if (specData != null) {
      specName = specData.toString();
      specialtiesList.add(specName);
    }

    if (item['specialties'] is List) {
      final listSpecs = item['specialties'] as List;
      if (listSpecs.isNotEmpty) {
        specName = listSpecs.first['name']?.toString() ?? 'General';
        for (final s in listSpecs) {
          final name = s['name']?.toString();
          if (name != null && name.isNotEmpty) {
            specialtiesList.add(name);
          }
        }
      }
    } else if (item['professionalProfile']?['specialties'] is List) {
      final listSpecs = item['professionalProfile']['specialties'] as List;
      if (listSpecs.isNotEmpty) {
        specName = listSpecs.first['name']?.toString() ?? 'General';
        for (final s in listSpecs) {
          final name = s['name']?.toString();
          if (name != null && name.isNotEmpty) {
            specialtiesList.add(name);
          }
        }
      }
    }

    if (specialtiesList.isEmpty) {
      specialtiesList.add(specName);
    }
    // Remove duplicates
    specialtiesList = specialtiesList.toSet().toList();

    var loc = item['location']?.toString() ?? '';
    if (loc.isEmpty) {
      loc = item['professionalProfile']?['description']?.toString() ?? '';
    }
    if (loc.isEmpty) {
      loc = 'Teleconsulta disponible';
    }
    var virtual = item['isVirtual'] == true;
    if (item['meetingType']?.toString().toUpperCase() == 'VIRTUAL') {
      virtual = true;
    }

    var avatar = item['avatarUrl']?.toString() ?? '';
    if (avatar.isEmpty) {
      avatar = item['profilePhotoUrl']?.toString() ?? '';
    }
    if (avatar.isEmpty) {
      avatar =
          item['professionalProfile']?['profilePhotoUrl']?.toString() ?? '';
    }
    if (avatar.isEmpty) {
      avatar =
          'https://images.unsplash.com/photo-1622253692010-333f2da6031d?q=80&w=256&auto=format&fit=crop';
    }

    final rawSlots = item['slots'] ?? item['timeSlots'] ?? <dynamic>[];
    final slots = <String>[];
    final formattedSlots = <String>[];
    final rawSlotsList = <Map<String, dynamic>>[];
    if (rawSlots is List) {
      for (final s in rawSlots) {
        if (s is Map) {
          final map = Map<String, dynamic>.from(s);
          final datetimeStr = map['datetime']?.toString();
          if (datetimeStr == null || datetimeStr.isEmpty) continue;
          slots.add(datetimeStr);
          rawSlotsList.add(map);
          // El backend ya envía startTime/date en hora local del médico,
          // usarlos evita que .toLocal() del datetime UTC desvíe la hora.
          final startTime = map['startTime']?.toString();
          formattedSlots.add(
            startTime != null && startTime.isNotEmpty
                ? startTime
                : _formatIsoTime(datetimeStr),
          );
        } else {
          final str = s.toString();
          slots.add(str);
          formattedSlots.add(_formatIsoTime(str));
        }
      }
    }

    var nextDate = 'Siguiente cita';
    if (rawSlotsList.isNotEmpty) {
      try {
        final dateStr = rawSlotsList.first['date']?.toString() ?? '';
        final dt = dateStr.isNotEmpty
            ? DateTime.parse(dateStr)
            : DateTime.parse(slots.first).toLocal();
        final now = DateTime.now();
        if (dt.day == now.day && dt.month == now.month && dt.year == now.year) {
          nextDate = 'HOY, ${_formatDayMonth(dt)}';
        } else if (dt.day == now.day + 1 &&
            dt.month == now.month &&
            dt.year == now.year) {
          nextDate = 'MAÑANA, ${_formatDayMonth(dt)}';
        } else {
          nextDate = _formatDayMonth(dt);
        }
      } catch (_) {}
    }

    return DoctorDto(
      id: item['id']?.toString() ?? item['userId']?.toString() ?? '',
      name: docName,
      specialty: specName,
      specialties: specialtiesList,
      rating: double.tryParse(item['rating']?.toString() ?? '') ?? 4.8,
      location: loc,
      isVirtual: virtual,
      avatarUrl: avatar,
      nextDateLabel: nextDate,
      timeSlots: formattedSlots.take(4).toList(),
      originalSlots: slots,
      rawSlots: rawSlotsList,
    );
  }

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

  Doctor toDomain() {
    return Doctor(
      id: id,
      name: name,
      specialty: specialty,
      specialties: specialties,
      rating: rating,
      location: location,
      isVirtual: isVirtual,
      avatarUrl: avatarUrl,
      nextDateLabel: nextDateLabel,
      timeSlots: timeSlots,
      originalSlots: originalSlots,
      rawSlots: rawSlots,
    );
  }

  static String _formatIsoTime(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      final hour = dt.hour.toString().padLeft(2, '0');
      final min = dt.minute.toString().padLeft(2, '0');
      return '$hour:$min';
    } catch (_) {
      return iso;
    }
  }

  static String _formatDayMonth(DateTime dt) {
    const months = [
      'ENE',
      'FEB',
      'MAR',
      'ABR',
      'MAY',
      'JUN',
      'JUL',
      'AGO',
      'SEP',
      'OCT',
      'NOV',
      'DIC',
    ];
    return '${dt.day} ${months[dt.month - 1]}';
  }
}
