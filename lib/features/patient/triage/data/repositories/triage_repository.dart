import 'package:priora/features/patient/triage/data/services/triage_service.dart';
import 'package:priora/features/patient/triage/domain/interfaces/triage_repository.dart';
import 'package:priora/features/patient/triage/domain/models/triage_history_item.dart';

/// Implementation of the [TriageRepository] contract using [TriageService].
/// Map DTOs to domain entities.
class TriageRepositoryImpl implements TriageRepository {
  TriageRepositoryImpl(this._service);

  final TriageService _service;

  @override
  Future<Map<String, dynamic>?> getTriageDraft({
    required String accessToken,
  }) {
    return _service.getTriageDraft(accessToken: accessToken);
  }

  @override
  Future<void> saveTriageDraft({
    required String accessToken,
    required Map<String, dynamic> data,
  }) {
    return _service.saveTriageDraft(accessToken: accessToken, data: data);
  }

  @override
  Future<Map<String, dynamic>> completeTriage({
    required String accessToken,
    required Map<String, dynamic> data,
  }) {
    return _service.completeTriage(accessToken: accessToken, data: data);
  }

  @override
  Future<Map<String, dynamic>> continueTriage({
    required String accessToken,
    required Map<String, dynamic> data,
  }) {
    return _service.continueTriage(accessToken: accessToken, data: data);
  }

  @override
  Future<List<TriageHistoryItem>> getTriageHistory({
    required String accessToken,
  }) async {
    final dtos = await _service.getTriageHistory(accessToken: accessToken);
    return dtos.map((dto) => dto.toDomain()).toList();
  }

  @override
  Future<Map<String, dynamic>> getTriageResult({
    required String accessToken,
    required String id,
  }) {
    return _service.getTriageResult(accessToken: accessToken, id: id);
  }
}
