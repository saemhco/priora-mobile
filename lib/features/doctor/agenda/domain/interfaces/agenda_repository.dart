import 'package:priora/features/doctor/agenda/domain/models/weekly_schedule.dart';

/// Access contract to the doctor's weekly availability. The presentation
/// layer depends solely on this abstraction; the implementation lives in
/// `data/repositories/`.
abstract interface class AgendaRepository {
  /// Obtiene los bloques de disponibilidad semanal del doctor autenticado.
  Future<List<WeeklySchedule>> getMyWeekly({required String accessToken});

  /// Crea un bloque de disponibilidad semanal.
  Future<void> createWeekly({
    required String accessToken,
    required Map<String, dynamic> data,
  });

  /// Elimina un bloque de disponibilidad semanal.
  Future<void> deleteWeekly({
    required String accessToken,
    required String scheduleId,
  });
}
