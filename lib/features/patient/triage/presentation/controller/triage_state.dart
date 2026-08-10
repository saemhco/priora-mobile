import 'package:priora/features/patient/triage/presentation/controller/triage_message.dart';

/// Estado del flujo de triaje del paciente.
class TriageState {
  TriageState({
    this.currentStep = 1,
    this.surgeries = '',
    this.chronicConditions = const [],
    this.otherChronicConditions = '',
    this.allergies = '',
    this.otherHistory = '',
    this.isLoading = false,
    this.errorMessage,
    this.isSubmitted = false,
    this.chatMessages = const [],
    this.isAnalyzing = false,
    this.analysisProgress = 0,
    this.isCompleted = false,
    this.sessionId,
    this.missingQuestions = const [],
    this.answers = const {},
    this.patientSafeMessage,
    this.priority,
    this.suggestedSpecialty,
    this.suggestedSpecialties = const [],
  });

  final int
      currentStep; // 1: Antecedentes, 2: Motivo, 3: Análisis, 4: Preguntas adicionales
  final String surgeries;
  final List<String> chronicConditions;
  final String otherChronicConditions;
  final String allergies;
  final String otherHistory;
  final bool isLoading;
  final String? errorMessage;
  final bool isSubmitted;
  final List<TriageMessage> chatMessages;
  final bool isAnalyzing;
  final int analysisProgress;
  final bool isCompleted;

  // Additional questions fields
  final String? sessionId;
  final List<dynamic> missingQuestions;
  final Map<String, String> answers;
  final String? patientSafeMessage;

  // Result fields
  final String? priority;
  final String? suggestedSpecialty;
  final List<String> suggestedSpecialties;

  TriageState copyWith({
    int? currentStep,
    String? surgeries,
    List<String>? chronicConditions,
    String? otherChronicConditions,
    String? allergies,
    String? otherHistory,
    bool? isLoading,
    String? errorMessage,
    bool? isSubmitted,
    List<TriageMessage>? chatMessages,
    bool? isAnalyzing,
    int? analysisProgress,
    bool? isCompleted,
    String? sessionId,
    List<dynamic>? missingQuestions,
    Map<String, String>? answers,
    String? patientSafeMessage,
    String? priority,
    String? suggestedSpecialty,
    List<String>? suggestedSpecialties,
  }) {
    return TriageState(
      currentStep: currentStep ?? this.currentStep,
      surgeries: surgeries ?? this.surgeries,
      chronicConditions: chronicConditions ?? this.chronicConditions,
      otherChronicConditions:
          otherChronicConditions ?? this.otherChronicConditions,
      allergies: allergies ?? this.allergies,
      otherHistory: otherHistory ?? this.otherHistory,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      chatMessages: chatMessages ?? this.chatMessages,
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      analysisProgress: analysisProgress ?? this.analysisProgress,
      isCompleted: isCompleted ?? this.isCompleted,
      sessionId: sessionId ?? this.sessionId,
      missingQuestions: missingQuestions ?? this.missingQuestions,
      answers: answers ?? this.answers,
      patientSafeMessage: patientSafeMessage ?? this.patientSafeMessage,
      priority: priority ?? this.priority,
      suggestedSpecialty: suggestedSpecialty ?? this.suggestedSpecialty,
      suggestedSpecialties: suggestedSpecialties ?? this.suggestedSpecialties,
    );
  }
}
