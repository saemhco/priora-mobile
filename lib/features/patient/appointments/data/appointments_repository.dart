import 'package:priora/features/patient/appointments/data/appointments_service.dart';
import 'package:priora/features/patient/appointments/data/models/doctor_model.dart';

class AppointmentsRepository {
  final AppointmentsService _service;

  AppointmentsRepository(this._service);

  Future<List<String>> fetchSpecialties({required String accessToken}) async {
    final list = await _service.fetchSpecialties(accessToken: accessToken);
    return list
        .map((s) => s['name']?.toString() ?? '')
        .where((name) => name.isNotEmpty)
        .toList();
  }

  Future<List<DoctorModel>> fetchAvailableBookings() async {
    final list = await _service.fetchAvailableBookings();

    return list.map((item) {
      String docName = item['name']?.toString() ?? '';
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

      String specName = 'General';
      List<String> specialtiesList = [];

      final specData = item['specialty'];
      if (specData != null) {
        specName = specData.toString();
        specialtiesList.add(specName);
      }

      if (item['specialties'] is List) {
        final listSpecs = item['specialties'] as List;
        if (listSpecs.isNotEmpty) {
          specName = listSpecs.first['name']?.toString() ?? 'General';
          for (var s in listSpecs) {
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
          for (var s in listSpecs) {
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

      String loc = item['location']?.toString() ?? '';
      if (loc.isEmpty) {
        loc = item['professionalProfile']?['description']?.toString() ?? '';
      }
      if (loc.isEmpty) {
        loc = 'Teleconsulta disponible';
      }
      bool virtual = item['isVirtual'] == true;
      if (item['meetingType']?.toString().toUpperCase() == 'VIRTUAL') {
        virtual = true;
      }

      String avatar = item['avatarUrl']?.toString() ?? '';
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

      final rawSlots = item['slots'] ?? item['timeSlots'] ?? [];
      List<String> slots = [];
      List<Map<String, dynamic>> rawSlotsList = [];
      if (rawSlots is List) {
        slots = rawSlots.map((s) {
          if (s is Map && s['datetime'] != null) {
            rawSlotsList.add(Map<String, dynamic>.from(s));
            return s['datetime'].toString();
          }
          return s.toString();
        }).toList();
      }

      String nextDate = 'Siguiente cita';
      if (slots.isNotEmpty) {
        try {
          final dt = DateTime.parse(slots.first);
          final now = DateTime.now();
          if (dt.day == now.day &&
              dt.month == now.month &&
              dt.year == now.year) {
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

      List<String> formattedSlots = [];
      for (var s in slots) {
        try {
          final dt = DateTime.parse(s);
          final hour = dt.hour.toString().padLeft(2, '0');
          final min = dt.minute.toString().padLeft(2, '0');
          formattedSlots.add('$hour:$min');
        } catch (_) {
          formattedSlots.add(s);
        }
      }

      return DoctorModel(
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
    }).toList();
  }

  Future<bool> bookAppointment({
    required String accessToken,
    required String doctorId,
    required String datetime,
  }) async {
    return _service.bookAppointment(
      accessToken: accessToken,
      doctorId: doctorId,
      datetime: datetime,
    );
  }

  Future<List<Map<String, dynamic>>> fetchMyAppointments({required String accessToken}) async {
    final list = await _service.fetchMyAppointments(accessToken: accessToken);
    return list.map((item) {
      final doc = item['doctor'] ?? item['professional'] ?? {};
      String docName = doc['name']?.toString() ?? '';
      if (docName.isEmpty) {
        final firstName = doc['firstName']?.toString() ?? '';
        final lastName = doc['lastName']?.toString() ?? '';
        docName = '$firstName $lastName'.trim();
      }
      if (docName.isEmpty) {
        docName = 'Doctor';
      }
      if (!docName.startsWith('Dr. ') && !docName.startsWith('Dra. ')) {
        docName = 'Dr. $docName';
      }

      String specName = 'General';
      final specData = doc['specialty'];
      if (specData != null) {
        specName = specData.toString();
      } else if (doc['specialties'] is List && (doc['specialties'] as List).isNotEmpty) {
        specName = (doc['specialties'] as List).first['name']?.toString() ?? 'General';
      } else if (doc['professionalProfile']?['specialties'] is List &&
          (doc['professionalProfile']?['specialties'] as List).isNotEmpty) {
        specName = (doc['professionalProfile']?['specialties'] as List).first['name']?.toString() ?? 'General';
      }

      String avatar = doc['avatarUrl']?.toString() ?? '';
      if (avatar.isEmpty) {
        avatar = doc['profilePhotoUrl']?.toString() ?? '';
      }
      if (avatar.isEmpty) {
        avatar = doc['professionalProfile']?['profilePhotoUrl']?.toString() ?? '';
      }
      if (avatar.isEmpty) {
        avatar = 'https://images.unsplash.com/photo-1622253692010-333f2da6031d?q=80&w=256&auto=format&fit=crop';
      }

      String dateStr = '';
      String timeStr = '';
      final dtRaw = item['datetime'];
      if (dtRaw != null) {
        try {
          final dt = DateTime.parse(dtRaw.toString()).toLocal();
          dateStr = '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
          timeStr = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
        } catch (_) {
          dateStr = dtRaw.toString();
        }
      }

      return {
        'id': item['id']?.toString() ?? '',
        'doctorId': item['doctorId']?.toString() ?? '',
        'datetime': dtRaw?.toString() ?? '',
        'formattedDate': dateStr,
        'formattedTime': timeStr,
        'doctorName': docName,
        'doctorSpecialty': specName,
        'doctorAvatar': avatar,
        'isVirtual': item['isVirtual'] == true || item['meetingType']?.toString().toUpperCase() == 'VIRTUAL',
        'status': item['status']?.toString() ?? 'Reservada',
      };
    }).toList();
  }

  String _formatDayMonth(DateTime dt) {
    final months = [
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
