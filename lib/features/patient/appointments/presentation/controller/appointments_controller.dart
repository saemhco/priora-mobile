import 'package:flutter/foundation.dart';
import 'package:priora/features/patient/appointments/domain/interfaces/appointments_repository.dart';
import 'package:priora/features/patient/appointments/domain/models/booking_result.dart';
import 'package:priora/features/patient/appointments/domain/models/doctor.dart';
import 'package:priora/features/patient/appointments/domain/models/patient_appointment.dart';
import 'package:priora/features/patient/triage/domain/interfaces/triage_repository.dart';

class AppointmentsController extends ChangeNotifier {
  AppointmentsController({
    required this._repository,
    required this._triageRepository,
    required this.accessToken,
  }) {
    fetchSpecialties();
    fetchMyAppointments();
  }

  final AppointmentsRepository _repository;
  final TriageRepository _triageRepository;
  final String accessToken;
  String searchQuery = '';
  String selectedSpecialty = 'Todos';
  bool isLoading = false;
  String? errorMessage;

  List<String> specialties = ['Todos'];
  List<Doctor> _allDoctors = [];
  List<PatientAppointment> myAppointments = [];
  bool isLoadingMyAppointments = false;
  int selectedSubTab = 0;

  /// If false, only current appointments (that have not yet passed) are shown.
  bool showPastAppointments = false;

  void toggleShowPastAppointments() {
    showPastAppointments = !showPastAppointments;
    notifyListeners();
  }

  /// Patient quotes filtered by pass toggle.
  List<PatientAppointment> get filteredMyAppointments {
    if (showPastAppointments) return myAppointments;

    final now = DateTime.now();
    return myAppointments.where((appointment) {
      final raw = appointment.datetime;
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

  List<Doctor> get filteredDoctors {
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
      final list = await _repository.fetchSpecialties(
        accessToken: accessToken,
      );
      specialties = ['Todos', ...list];
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching specialties: $e');
      }
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
      final history = await _triageRepository.getTriageHistory(
        accessToken: accessToken,
      );
      return history.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> fetchMyAppointments() async {
    isLoadingMyAppointments = true;
    notifyListeners();
    try {
      myAppointments = await _repository.fetchMyAppointments(
        accessToken: accessToken,
      );
      isLoadingMyAppointments = false;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching my appointments: $e');
      }
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
        meetingType ?? doctor.meetingTypeForSlot(timeSlot) ?? 'VIRTUAL';

    // Lugar del slot presencial (si aplica)
    String? placeId;
    final matchingRawSlot = doctor.rawSlots.firstWhere((s) {
      final startTime = s['startTime']?.toString();
      if (startTime != null && startTime.isNotEmpty) {
        return startTime == timeSlot;
      }
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
        await fetchAvailableBookings();
        await fetchMyAppointments();
      }
      return result;
    } catch (e) {
      debugPrint('Error booking appointment: $e');
      return const BookingResult(
        success: false,
        message: 'Error al reservar la cita. Por favor, reintenta.',
      );
    }
  }
}
