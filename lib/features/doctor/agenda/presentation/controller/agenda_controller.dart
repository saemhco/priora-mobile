import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:priora/features/doctor/agenda/domain/interfaces/agenda_repository.dart';
import 'package:priora/features/doctor/agenda/domain/models/weekly_schedule.dart';
import 'package:priora/features/doctor/agenda/presentation/controller/delete_block_result.dart';
import 'package:priora/features/doctor/agenda/presentation/widgets/agenda_theme.dart';
import 'package:priora/features/doctor/appointments/presentation/controller/doctor_appointments_cubit.dart';
import 'package:priora/features/doctor/places/domain/models/place.dart';
import 'package:priora/features/doctor/places/presentation/controller/places_cubit.dart';

/// Controller of the doctor's agenda screen. Handles the status of
/// availability blocks, filters (all, virtual, by location), and load/delete
/// operations. The view only listens to changes and builds the widget tree.
class AgendaController extends ChangeNotifier {
  AgendaController({
    required this._repository,
    required this._placesCubit,
    required this._appointmentsCubit,
    required this._accessToken,
  });

  final AgendaRepository _repository;
  final PlacesCubit _placesCubit;
  final DoctorAppointmentsCubit _appointmentsCubit;
  final String _accessToken;

  List<WeeklySchedule> _schedules = [];
  List<String> _hours = [];
  Set<String> _availableSlots = {};
  Map<String, String> _slotTypes = {}; // "col_row" -> "VIRTUAL" | "IN_PERSON"

  Place? _selectedPlace;
  bool _isLoadingBlocks = false;

  // Filtro: null = todos, kVirtualFilterId = solo virtual, place.id = lugar.
  String? _selectedFilterId;

  List<WeeklySchedule> get schedules => _schedules;
  List<String> get hours => _hours;
  Set<String> get availableSlots => _availableSlots;
  Map<String, String> get slotTypes => _slotTypes;
  Place? get selectedPlace => _selectedPlace;
  bool get isLoadingBlocks => _isLoadingBlocks;
  String? get selectedFilterId => _selectedFilterId;

  bool get isVirtualSelected => _selectedFilterId == kVirtualFilterId;

  /// Carga lugares y bloques al iniciar la pantalla.
  void loadData() {
    loadPlaces();
    loadBlocks();
  }

  /// Recarga todos los datos de la agenda (lugares, bloques y citas).
  Future<void> refreshData() async {
    await Future.wait([
      loadBlocks(),
      _appointmentsCubit.loadAppointments(),
    ]);
    loadPlaces();
  }

  void loadPlaces() {
    _placesCubit.loadPlaces(accessToken: _accessToken);
  }

  Future<void> loadBlocks() async {
    _isLoadingBlocks = true;
    notifyListeners();
    try {
      final schedules = await _repository.getMyWeekly(
        accessToken: _accessToken,
      );
      _applyFilter(schedules);
    } catch (e) {
      debugPrint('Error loading blocks: $e');
      _schedules = [];
      _hours = [];
      _availableSlots = {};
      _slotTypes = {};
      notifyListeners();
    } finally {
      _isLoadingBlocks = false;
      notifyListeners();
    }
  }

  /// Aplica el filtro actual sobre [schedules] (o los ya cargados si es null)
  /// y recalcula horas, slots y tipos para el calendario.
  void _applyFilter(List<WeeklySchedule>? schedules) {
    final allSchedules = schedules ?? _schedules;
    _schedules = allSchedules;

    // Filtro por selectedFilterId
    List<WeeklySchedule> filtered;
    if (_selectedFilterId == null) {
      filtered = allSchedules;
    } else if (isVirtualSelected) {
      filtered = allSchedules.where((s) => s.meetingType == 'VIRTUAL').toList();
    } else {
      filtered = allSchedules
          .where(
            (s) =>
                s.meetingType == 'IN_PERSON' &&
                s.place?.id == _selectedFilterId,
          )
          .toList();
    }

    if (filtered.isNotEmpty) {
      // Horas únicas ordenadas
      final sortedHours = filtered.map((s) => s.startTime).toSet().toList()
        ..sort();

      // Mapa de slots y tipos
      final slots = <String>{};
      final types = <String, String>{};
      for (final s in filtered) {
        final col = s.dayOfWeek - 1; // 0=Mon .. 6=Sun
        final row = sortedHours.indexOf(s.startTime);
        if (row >= 0) {
          final key = '${col}_$row';
          slots.add(key);
          types[key] = s.meetingType;
        }
      }

      _hours = sortedHours;
      _availableSlots = slots;
      _slotTypes = types;
    } else {
      _hours = [];
      _availableSlots = {};
      _slotTypes = {};
    }
    notifyListeners();
  }

  /// Selecciona el filtro "Todos".
  void selectFilterAll() {
    _selectedFilterId = null;
    _selectedPlace = null;
    _applyFilter(null);
  }

  /// Selecciona el filtro "Virtual".
  void selectFilterVirtual() {
    _selectedFilterId = kVirtualFilterId;
    _selectedPlace = null;
    _applyFilter(null);
  }

  /// Select the filter for a specific location.
  void selectFilterPlace(Place place) {
    _selectedPlace = place;
    _selectedFilterId = place.id;
    _applyFilter(null);
  }

  /// Elimina un bloque de disponibilidad.
  Future<DeleteBlockResult> deleteBlock(String blockId) async {
    try {
      await _repository.deleteWeekly(
        accessToken: _accessToken,
        scheduleId: blockId,
      );
      return const DeleteBlockResult(success: true);
    } on DioException catch (e) {
      return DeleteBlockResult(
        success: false,
        message: _extractError(e),
      );
    } catch (e) {
      debugPrint('Error deleting block: $e');
      return const DeleteBlockResult(
        success: false,
        message: 'Error al eliminar el bloque. Inténtalo de nuevo.',
      );
    }
  }

  String _extractError(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      final msg = data['message'];
      if (msg is String && msg.isNotEmpty) return msg;
      if (msg is List && msg.isNotEmpty) return msg.join('\n');
    }
    switch (e.response?.statusCode) {
      case 400:
        return 'No se puede eliminar este bloque.';
      case 404:
        return 'El bloque no fue encontrado.';
      default:
        return 'Error al eliminar el bloque. Inténtalo de nuevo.';
    }
  }

  /// Rango de fechas de la semana actual, ej: "Agosto 3-9, 2026".
  String formatWeekRange() {
    final now = DateTime.now();
    final daysFromMonday = now.weekday - DateTime.monday;
    final monday = now.subtract(Duration(days: daysFromMonday));
    final sunday = monday.add(const Duration(days: 6));

    const months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];

    if (monday.month == sunday.month) {
      return '${months[monday.month - 1]} ${monday.day}-${sunday.day}, ${monday.year}';
    }
    return '${months[monday.month - 1]} ${monday.day} - '
        '${months[sunday.month - 1]} ${sunday.day}, ${sunday.year}';
  }
}
