import 'package:priora/features/doctor/agenda/data/services/availability_service.dart';
import 'package:priora/features/doctor/agenda/domain/interfaces/agenda_repository.dart';
import 'package:priora/features/doctor/agenda/domain/models/weekly_schedule.dart';

/// Implementation of the [AgendaRepository] contract using
/// [AvailabilityService]. Orchestrate the HTTP service and map the DTOs to
/// domain entities.
class AgendaRepositoryImpl implements AgendaRepository {
  AgendaRepositoryImpl(this._service);

  final AvailabilityService _service;

  @override
  Future<List<WeeklySchedule>> getMyWeekly({
    required String accessToken,
  }) async {
    final dtos = await _service.getMyWeekly(accessToken: accessToken);
    return dtos.map((dto) => dto.toDomain()).toList();
  }

  @override
  Future<void> createWeekly({
    required String accessToken,
    required Map<String, dynamic> data,
  }) async {
    await _service.createWeekly(accessToken: accessToken, data: data);
  }

  @override
  Future<void> deleteWeekly({
    required String accessToken,
    required String scheduleId,
  }) async {
    await _service.deleteWeekly(
      accessToken: accessToken,
      scheduleId: scheduleId,
    );
  }
}
