class TriageHistoryItem {
  final String id;
  final DateTime createdAt;
  final String priority;
  final String? suggestedSpecialty;
  final List<String> suggestedSpecialties;
  final String? patientSafeMessage;
  final String? symptoms;

  TriageHistoryItem({
    required this.id,
    required this.createdAt,
    required this.priority,
    this.suggestedSpecialty,
    required this.suggestedSpecialties,
    this.patientSafeMessage,
    this.symptoms,
  });

  factory TriageHistoryItem.fromJson(Map<String, dynamic> json) {
    final rawSpecialties = json['suggestedSpecialties'];
    List<String> specs = [];
    if (rawSpecialties is List) {
      specs = rawSpecialties.map((s) => s.toString()).toList();
    } else if (json['suggestedSpecialty'] != null) {
      specs = [json['suggestedSpecialty'].toString()];
    }

    return TriageHistoryItem(
      id: json['id']?.toString() ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      priority: json['priority']?.toString() ?? 'LOW',
      suggestedSpecialty: json['suggestedSpecialty']?.toString(),
      suggestedSpecialties: specs,
      patientSafeMessage: json['patientSafeMessage']?.toString(),
      symptoms: json['symptoms']?.toString(),
    );
  }
}
