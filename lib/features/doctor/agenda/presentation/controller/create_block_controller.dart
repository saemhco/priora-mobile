import 'package:flutter/widgets.dart';
import 'package:priora/features/doctor/agenda/domain/interfaces/agenda_repository.dart';
import 'package:priora/features/doctor/places/domain/models/place.dart';
import 'package:priora/features/doctor/places/presentation/controller/places_cubit.dart';

/// Controller of the "Create Availability Block" screen. Manage the form
/// (days, hours, validity, type of care, place) and the creation of the block.
/// The view only listens and builds the widget tree.
class CreateBlockController extends ChangeNotifier {
  CreateBlockController({
    required this._repository,
    required this._placesCubit,
    required this._accessToken,
  });

  final AgendaRepository _repository;
  final PlacesCubit _placesCubit;
  final String _accessToken;

  // Días de la semana: 1=Mon ... 7=Sun
  static const List<Map<String, dynamic>> days = [
    {'label': 'Lun', 'value': 1},
    {'label': 'Mar', 'value': 2},
    {'label': 'Mié', 'value': 3},
    {'label': 'Jue', 'value': 4},
    {'label': 'Vie', 'value': 5},
    {'label': 'Sáb', 'value': 6},
    {'label': 'Dom', 'value': 7},
  ];

  final Set<int> _selectedDays = {};
  final List<String> _timeSlots = [];
  String? _pendingTime;

  String _validity = 'unlimited'; // 'unlimited' | 'range'
  DateTime? _validFrom;
  DateTime? _validTo;
  final _fromController = TextEditingController();
  final _toController = TextEditingController();

  String _meetingType = 'VIRTUAL'; // 'VIRTUAL' | 'IN_PERSON'
  Place? _selectedPlace;

  bool _isLoading = false;

  Set<int> get selectedDays => _selectedDays;
  List<String> get timeSlots => _timeSlots;
  String? get pendingTime => _pendingTime;
  String get validity => _validity;
  DateTime? get validFrom => _validFrom;
  DateTime? get validTo => _validTo;
  TextEditingController get fromController => _fromController;
  TextEditingController get toController => _toController;
  String get meetingType => _meetingType;
  Place? get selectedPlace => _selectedPlace;
  bool get isLoading => _isLoading;

  Future<void> loadPlaces() async {
    await _placesCubit.loadPlaces(accessToken: _accessToken);
  }

  /// Toggle the selection of a day of the week.
  void toggleDay(int day) {
    if (_selectedDays.contains(day)) {
      _selectedDays.remove(day);
    } else {
      _selectedDays.add(day);
    }
    notifyListeners();
  }

  void setPendingTime(String? time) {
    _pendingTime = time;
    notifyListeners();
  }

  void confirmPendingTime() {
    if (_pendingTime == null) return;
    _timeSlots.add(_pendingTime!);
    _pendingTime = null;
    notifyListeners();
  }

  void removeTimeSlot(String time) {
    _timeSlots.remove(time);
    notifyListeners();
  }

  void setValidity(String validity) {
    _validity = validity;
    notifyListeners();
  }

  void setValidFrom(DateTime? date, {String? formatted}) {
    _validFrom = date;
    if (formatted != null) _fromController.text = formatted;
    notifyListeners();
  }

  void setValidTo(DateTime? date, {String? formatted}) {
    _validTo = date;
    if (formatted != null) _toController.text = formatted;
    notifyListeners();
  }

  void setMeetingType(String type) {
    _meetingType = type;
    if (type == 'VIRTUAL') _selectedPlace = null;
    notifyListeners();
  }

  void setSelectedPlace(Place? place) {
    _selectedPlace = place;
    notifyListeners();
  }

  /// Valida el formulario y crea el bloque.
  /// 
  /// Retorna `null` si todo fue exitoso; en caso contrario el mensaje de error.
  Future<String?> save() async {
    if (_selectedDays.isEmpty) return 'Selecciona al menos un día';
    if (_timeSlots.isEmpty) return 'Agrega al menos un horario';
    if (_validity == 'range') {
      if (_validFrom == null || _validTo == null) {
        return 'Completa las fechas de vigencia';
      }
      if (_validTo!.isBefore(_validFrom!)) {
        return 'La fecha fin debe ser posterior a la fecha inicio';
      }
    }
    if (_meetingType == 'IN_PERSON' && _selectedPlace == null) {
      return 'Selecciona un lugar de atención presencial';
    }

    _isLoading = true;
    notifyListeners();

    try {
      final data = <String, dynamic>{
        'daysOfWeek': _selectedDays.toList()..sort(),
        'timeSlots': _timeSlots,
        'validity': _validity,
        'meetingType': _meetingType,
      };

      if (_validity == 'range') {
        data['validFrom'] = _fromController.text;
        data['validTo'] = _toController.text;
      }

      if (_meetingType == 'IN_PERSON' && _selectedPlace != null) {
        data['placeId'] = _selectedPlace!.id;
      }

      await _repository.createWeekly(
        accessToken: _accessToken,
        data: data,
      );
      return null;
    } catch (e) {
      return e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Formatea una hora 24h a 12h, ej: "14:30" -> "2:30 PM".
  String formatTimeDisplay(String time24) {
    final parts = time24.split(':');
    if (parts.length != 2) return time24;
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = parts[1];
    final period = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$hour12:$minute $period';
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }
}
