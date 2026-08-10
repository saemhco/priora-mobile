import 'package:priora/features/patient/triage/domain/models/triage_history_item.dart';

/// Patient Triage Access Agreement. The presentation layer depends solely on
/// this abstraction; the implementation lives in `data/repositories/`.
abstract interface class TriageRepository {
  /// Obtiene el borrador de triaje guardado, o null si no existe.
  Future<Map<String, dynamic>?> getTriageDraft({
    required String accessToken,
  });

  /// Guarda el borrador de triaje.
  Future<void> saveTriageDraft({
    required String accessToken,
    required Map<String, dynamic> data,
  });

  /// Complete the triage (symptom assessment).
  Future<Map<String, dynamic>> completeTriage({
    required String accessToken,
    required Map<String, dynamic> data,
  });

  /// Ongoing triage continues (answers to additional questions).
  Future<Map<String, dynamic>> continueTriage({
    required String accessToken,
    required Map<String, dynamic> data,
  });

  /// Obtiene el historial de triajes del paciente.
  Future<List<TriageHistoryItem>> getTriageHistory({
    required String accessToken,
  });

  /// Gets the result of a specific triage.
  Future<Map<String, dynamic>> getTriageResult({
    required String accessToken,
    required String id,
  });
}
