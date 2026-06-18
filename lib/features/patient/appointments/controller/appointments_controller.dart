import 'package:flutter/material.dart';

class DoctorModel {
  final String id;
  final String name;
  final String specialty;
  final double rating;
  final String location;
  final bool isVirtual; // Video camera icon vs pin icon
  final String avatarUrl;
  final String nextDateLabel; // e.g., "HOY, 24 OCT", "MAÑANA, 25 OCT"
  final List<String> timeSlots;
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
    this.selectedTimeSlot,
  });
}

class AppointmentsController extends ChangeNotifier {
  String searchQuery = '';
  String selectedSpecialty = 'Todos';

  final List<String> specialties = const [
    'Todos',
    'Cardiología',
    'Dermatología',
    'Pediatría',
  ];

  final List<DoctorModel> _allDoctors = [
    DoctorModel(
      id: '1',
      name: 'Dr. Roberto Méndez',
      specialty: 'Cardiología',
      rating: 4.9,
      location: 'Clínica San Borja',
      isVirtual: false,
      avatarUrl: 'https://images.unsplash.com/photo-1622253692010-333f2da6031d?q=80&w=256&auto=format&fit=crop',
      nextDateLabel: 'HOY, 24 OCT',
      timeSlots: ['09:00', '10:30', '14:00', '16:30'],
      selectedTimeSlot: '14:00',
    ),
    DoctorModel(
      id: '2',
      name: 'Dra. Elena Vizcarra',
      specialty: 'Dermatología',
      rating: 4.8,
      location: 'Teleconsulta disponible',
      isVirtual: true,
      avatarUrl: 'https://images.unsplash.com/photo-1594824813573-246434de83fb?q=80&w=256&auto=format&fit=crop',
      nextDateLabel: 'MAÑANA, 25 OCT',
      timeSlots: ['08:00', '08:45', '11:15', '15:00'],
    ),
  ];

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
    notifyListeners();
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
}
