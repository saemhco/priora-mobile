/// Patient Triage History Item (Domain Entity).
class TriageHistoryItem {
  TriageHistoryItem({
    required this.id,
    required this.createdAt,
    required this.priority,
    required this.suggestedSpecialties,
    this.suggestedSpecialty,
    this.patientSafeMessage,
    this.symptoms,
  });

  final String id;
  final DateTime createdAt;
  final String priority;
  final String? suggestedSpecialty;
  final List<String> suggestedSpecialties;
  final String? patientSafeMessage;
  final String? symptoms;
}
