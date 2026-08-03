import 'package:flutter/material.dart';
import 'package:priora/features/patient/appointments/data/models/doctor_model.dart';
import 'package:priora/features/patient/appointments/data/appointments_repository.dart';
import 'package:priora/features/patient/appointments/data/appointments_service.dart';
import 'package:priora/features/patient/triage/data/triage_repository.dart';

export 'package:priora/features/patient/appointments/data/models/doctor_model.dart';
export 'package:priora/features/patient/appointments/data/appointments_service.dart';

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

  /// Si es false, solo se muestran citas vigentes (que aún no han pasado).
  bool showPastAppointments = false;

  void toggleShowPastAppointments() {
    showPastAppointments = !showPastAppointments;
    notifyListeners();
  }

  /// Citas del paciente filtradas según el toggle de pasadas.
  List<Map<String, dynamic>> get filteredMyAppointments {
    if (showPastAppointments) return myAppointments;

    final now = DateTime.now();
    return myAppointments.where((appointment) {
      final raw = appointment['datetime']?.toString() ?? '';
      if (raw.isEmpty) return true;
      try {
        final dt = DateTime.parse(raw).toLocal();
        return !dt.isBefore(now);
      } catch (_) {
        return true;
      }
    }).toList();
  }

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

  Future<BookingResult> bookAppointment({
    required String doctorId,
    required String timeSlot,
    String? meetingType,
    bool acknowledgeDuplicateSpecialty = false,
  }) async {
    final doctor = _allDoctors.firstWhere((doc) => doc.id == doctorId);
    final selectedIso = doctor.originalSlotForHour(timeSlot);

    if (selectedIso.isEmpty) {
      return const BookingResult(
        success: false,
        message: 'No se pudo determinar la fecha de la cita.',
      );
    }

    // Tipo de cita: se respeta el del selector, o se deriva del slot
    final effectiveMeetingType =
        meetingType ??
        doctor.meetingTypeForSlot(timeSlot) ??
        'VIRTUAL';

    // Lugar del slot presencial (si aplica)
    String? placeId;
    final matchingRawSlot = doctor.rawSlots.firstWhere((s) {
      final datetimeStr = s['datetime']?.toString() ?? '';
      if (datetimeStr.isEmpty) return false;
      try {
        final dt = DateTime.parse(datetimeStr).toLocal();
        final h = dt.hour.toString().padLeft(2, '0');
        final m = dt.minute.toString().padLeft(2, '0');
        return '$h:$m' == timeSlot;
      } catch (_) {
        return false;
      }
    }, orElse: () => <String, dynamic>{});
    if (matchingRawSlot.isNotEmpty) {
      final place = matchingRawSlot['place'];
      if (place is Map) {
        placeId = place['id']?.toString();
      }
    }

    // Triaje COMPLETED más reciente como triageSessionId
    String? triageSessionId;
    try {
      final history = await _triageRepository.getTriageHistory(
        accessToken: accessToken,
      );
      if (history.isNotEmpty && history.first.id.isNotEmpty) {
        triageSessionId = history.first.id;
      }
    } catch (e) {
      debugPrint('Error fetching triage history for booking: $e');
    }

    try {
      final result = await _repository.bookAppointment(
        accessToken: accessToken,
        doctorId: doctorId,
        datetime: selectedIso,
        meetingType: effectiveMeetingType,
        placeId: placeId,
        triageSessionId: triageSessionId,
        specialty: doctor.specialty,
        acknowledgeDuplicateSpecialty: acknowledgeDuplicateSpecialty,
      );

      if (result.success) {
        // Refresh bookings list and my appointments
        fetchAvailableBookings();
        fetchMyAppointments();
      }
      return result;
    } catch (e) {
      print('Error booking appointment: $e');
      return const BookingResult(
        success: false,
        message: 'Error al reservar la cita. Por favor, reintenta.',
      );
    }
  }
}
