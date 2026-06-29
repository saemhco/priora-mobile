import 'package:flutter/material.dart';
import 'package:priora/features/patient/appointments/data/models/doctor_model.dart';
import 'package:priora/features/patient/appointments/data/appointments_repository.dart';
import 'package:priora/features/patient/triage/data/triage_repository.dart';

export 'package:priora/features/patient/appointments/data/models/doctor_model.dart';

class AppointmentsController extends ChangeNotifier {
  final AppointmentsRepository _repository;
  final TriageRepository _triageRepository;
  final String accessToken;
  String searchQuery = '';
  String selectedSpecialty = 'Todos';
  bool isLoading = false;
  String? errorMessage;

  List<String> specialties = ['Todos'];
  List<DoctorModel> _allDoctors = [];
  List<Map<String, dynamic>> myAppointments = [];
  bool isLoadingMyAppointments = false;
  int selectedSubTab = 0;

  void changeSubTab(int index) {
    selectedSubTab = index;
    notifyListeners();
  }

  AppointmentsController({
    required this._repository,
    required TriageRepository triageRepository,
    required this.accessToken,
  }) : _triageRepository = triageRepository {
    fetchSpecialties();
    fetchMyAppointments();
  }

  List<DoctorModel> get filteredDoctors {
    return _allDoctors.where((doc) {
      final hasSlots = doc.timeSlots.isNotEmpty;

      final matchesSpecialty =
          selectedSpecialty == 'Todos' ||
          doc.specialties.any(
            (s) => s.toLowerCase() == selectedSpecialty.toLowerCase(),
          );

      final matchesSearch =
          searchQuery.isEmpty ||
          doc.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          doc.specialty.toLowerCase().contains(searchQuery.toLowerCase()) ||
          doc.location.toLowerCase().contains(searchQuery.toLowerCase()) ||
          doc.specialties.any(
            (s) => s.toLowerCase().contains(searchQuery.toLowerCase()),
          );

      return hasSlots && matchesSpecialty && matchesSearch;
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

  Future<void> fetchSpecialties() async {
    try {
      final list = await _repository.fetchSpecialties(accessToken: accessToken);
      specialties = ['Todos', ...list];
      notifyListeners();
    } catch (e) {
      print('Error fetching specialties: $e');
    }
  }

  bool isTriageCompleted = true;

  Future<void> fetchAvailableBookings() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final hasTriage = await checkTriageCompleted();
      isTriageCompleted = hasTriage;
      if (!hasTriage) {
        _allDoctors = [];
        isLoading = false;
        notifyListeners();
        return;
      }

      _allDoctors = await _repository.fetchAvailableBookings();
      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString().replaceAll('Exception: ', '');
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> checkTriageCompleted() async {
    try {
      final history = await _triageRepository.getTriageHistory(accessToken: accessToken);
      return history.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> fetchMyAppointments() async {
    isLoadingMyAppointments = true;
    notifyListeners();
    try {
      myAppointments = await _repository.fetchMyAppointments(accessToken: accessToken);
      isLoadingMyAppointments = false;
      notifyListeners();
    } catch (e) {
      print('Error fetching my appointments: $e');
      isLoadingMyAppointments = false;
      notifyListeners();
    }
  }

  Future<bool> bookAppointment(String doctorId, String timeSlot) async {
    final doctor = _allDoctors.firstWhere((doc) => doc.id == doctorId);
    final selectedIso = doctor.originalSlots.firstWhere(
      (s) => s.contains(timeSlot),
      orElse: () => '',
    );

    if (selectedIso.isEmpty) return false;

    try {
      final success = await _repository.bookAppointment(
        accessToken: accessToken,
        doctorId: doctorId,
        datetime: selectedIso,
      );

      if (success) {
        // Refresh bookings list and my appointments
        fetchAvailableBookings();
        fetchMyAppointments();
        return true;
      }
    } catch (e) {
      print('Error booking appointment: $e');
    }
    return false;
  }
}
