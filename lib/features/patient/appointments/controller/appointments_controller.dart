import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:priora/core/network/network.dart';

class DoctorModel {
  final String id;
  final String name;
  final String specialty;
  final double rating;
  final String location;
  final bool isVirtual;
  final String avatarUrl;
  final String nextDateLabel;
  final List<String> timeSlots;
  final List<String> originalSlots;
  String? selectedTimeSlot;

  DoctorModel({
    required this.id,
    required this.name,
    required this.specialty,
    required this.rating,
    required this.location,
    required this.isVirtual,
    required this.avatarUrl,
    required this.nextDateLabel,
    required this.timeSlots,
    required this.originalSlots,
    this.selectedTimeSlot,
  });
}

class AppointmentsController extends ChangeNotifier {
  final String accessToken;
  String searchQuery = '';
  String selectedSpecialty = 'Todos';
  bool isLoading = false;
  String? errorMessage;

  List<String> specialties = ['Todos'];
  List<DoctorModel> _allDoctors = [];

  AppointmentsController({required this.accessToken}) {
    fetchSpecialties();
  }

  List<DoctorModel> get filteredDoctors {
    return _allDoctors.where((doc) {
      final matchesSpecialty = selectedSpecialty == 'Todos' || doc.specialty == selectedSpecialty;

      final matchesSearch = searchQuery.isEmpty ||
          doc.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          doc.specialty.toLowerCase().contains(searchQuery.toLowerCase()) ||
          doc.location.toLowerCase().contains(searchQuery.toLowerCase());

      return matchesSpecialty && matchesSearch;
    }).toList();
  }

  void updateSearchQuery(String query) {
    searchQuery = query;
    notifyListeners();
  }

  void selectSpecialty(String specialty) {
    selectedSpecialty = specialty;
    fetchAvailableBookings();
  }

  void selectTimeSlot(String doctorId, String timeSlot) {
    final docIndex = _allDoctors.indexWhere((doc) => doc.id == doctorId);
    if (docIndex != -1) {
      _allDoctors[docIndex].selectedTimeSlot = timeSlot;
      notifyListeners();
    }
  }

  bool notificationsEnabled = false;
  void toggleNotifications() {
    notificationsEnabled = !notificationsEnabled;
    notifyListeners();
  }

  Future<void> fetchSpecialties() async {
    try {
      final response = await dio.get(
        '/specialties',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      if (response.statusCode == 200) {
        final list = response.data as List;
        specialties = ['Todos', ...list.map((s) => s['name'].toString())];
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching specialties: $e');
    }
  }

  Future<void> fetchAvailableBookings() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final queryParams = <String, dynamic>{};
      if (selectedSpecialty != 'Todos') {
        queryParams['specialty'] = selectedSpecialty;
      }

      final response = await dio.get(
        '/booking/available',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final dynamic data = response.data;
        List<dynamic> list = [];
        if (data is List) {
          list = data;
        } else if (data is Map) {
          // If the API returns { "data": [...] } or { "doctors": [...] }, extract the list
          final possibleList = data['data'] ?? data['items'] ?? data['doctors'] ?? data['professionals'] ?? data['availabilities'];
          if (possibleList is List) {
            list = possibleList;
          } else {
            // fallback if it contains values
            list = data.values.whereType<List>().firstOrNull ?? [];
          }
        }

        _allDoctors = list.map((item) {
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
          final specData = item['specialty'];
          if (specData != null) {
            specName = specData.toString();
          } else if (item['specialties'] is List && (item['specialties'] as List).isNotEmpty) {
            specName = (item['specialties'] as List).first['name']?.toString() ?? 'General';
          } else if (item['professionalProfile']?['specialties'] is List && 
                     (item['professionalProfile']?['specialties'] as List).isNotEmpty) {
            specName = (item['professionalProfile']?['specialties'] as List).first['name']?.toString() ?? 'General';
          }

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
            avatar = item['professionalProfile']?['profilePhotoUrl']?.toString() ?? '';
          }
          if (avatar.isEmpty) {
            avatar = 'https://images.unsplash.com/photo-1622253692010-333f2da6031d?q=80&w=256&auto=format&fit=crop';
          }

          final rawSlots = item['slots'] ?? item['timeSlots'] ?? [];
          List<String> slots = [];
          if (rawSlots is List) {
            slots = rawSlots.map((s) {
              if (s is Map && s['datetime'] != null) {
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
              if (dt.day == now.day && dt.month == now.month && dt.year == now.year) {
                nextDate = 'HOY, ${_formatDayMonth(dt)}';
              } else if (dt.day == now.day + 1 && dt.month == now.month && dt.year == now.year) {
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
            rating: double.tryParse(item['rating']?.toString() ?? '') ?? 4.8,
            location: loc,
            isVirtual: virtual,
            avatarUrl: avatar,
            nextDateLabel: nextDate,
            timeSlots: formattedSlots.take(4).toList(),
            originalSlots: slots,
          );
        }).toList();
        isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      errorMessage = e.toString().replaceAll('Exception: ', '');
      isLoading = false;
      notifyListeners();
    }
  }

  String _formatDayMonth(DateTime dt) {
    final months = ['ENE', 'FEB', 'MAR', 'ABR', 'MAY', 'JUN', 'JUL', 'AGO', 'SEP', 'OCT', 'NOV', 'DIC'];
    return '${dt.day} ${months[dt.month - 1]}';
  }

  Future<bool> bookAppointment(String doctorId, String timeSlot) async {
    final doctor = _allDoctors.firstWhere((doc) => doc.id == doctorId);
    final selectedIso = doctor.originalSlots.firstWhere(
      (s) => s.contains(timeSlot),
      orElse: () => '',
    );

    if (selectedIso.isEmpty) return false;

    try {
      final body = {
        "doctorId": doctorId,
        "datetime": selectedIso,
      };

      final response = await dio.post(
        '/appointments',
        data: body,
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Refresh bookings list
        fetchAvailableBookings();
        return true;
      }
    } catch (e) {
      print('Error booking appointment: $e');
    }
    return false;
  }
}
