import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:priora/features/patient/triage/data/triage_repository.dart';

class TriageMessage {
  final String text;
  final bool isUser;
  final String time;
  final List<String>? options;
  final String? imagePath;

  TriageMessage({
    required this.text,
    required this.isUser,
    required this.time,
    this.options,
    this.imagePath,
  });
}

class TriageState {
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

class TriageCubit extends Cubit<TriageState> {
  final TriageRepository _triageRepository;
  Timer? _progressTimer;

  TriageCubit({required TriageRepository triageRepository})
    : _triageRepository = triageRepository,
      super(TriageState()) {
    _initChat();
  }

  void _initChat() {
    emit(
      state.copyWith(
        chatMessages: [
          TriageMessage(
            text:
                'Hola, soy tu asistente de salud Priora. Para ayudarte mejor, cuéntame:\n\n¿Qué síntomas estás experimentando hoy y desde cuándo empezaron?',
            isUser: false,
            time: _getCurrentTime(),
          ),
        ],
      ),
    );
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    final hour = now.hour > 12
        ? now.hour - 12
        : (now.hour == 0 ? 12 : now.hour);
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  void changeStep(int step) {
    emit(state.copyWith(currentStep: step, isSubmitted: false));
  }

  void updateSurgeries(String value) {
    emit(state.copyWith(surgeries: value));
  }

  void toggleChronicCondition(String condition) {
    final updated = List<String>.from(state.chronicConditions);
    if (updated.contains(condition)) {
      updated.remove(condition);
    } else {
      updated.add(condition);
    }
    emit(state.copyWith(chronicConditions: updated));
  }

  void updateOtherChronicConditions(String value) {
    emit(state.copyWith(otherChronicConditions: value));
  }

  void updateAllergies(String value) {
    emit(state.copyWith(allergies: value));
  }

  void updateOtherHistory(String value) {
    emit(state.copyWith(otherHistory: value));
  }

  void updateAnswer(String questionId, String answer) {
    final updatedAnswers = Map<String, String>.from(state.answers)
      ..addAll({questionId: answer});
    emit(state.copyWith(answers: updatedAnswers));
  }

  Future<void> saveDraft(String accessToken) async {
    emit(state.copyWith(isLoading: true));
    try {
      final conditions = List<String>.from(state.chronicConditions);
      if (state.otherChronicConditions.isNotEmpty) {
        conditions.add(state.otherChronicConditions);
      }

      final body = {
        "step": state.currentStep,
        "medicalHistory": {
          "previousSurgeries": state.surgeries,
          "allergies": state.allergies,
          "chronicConditions": conditions.isEmpty
              ? "Ninguna"
              : conditions.join(', '),
          "other": state.otherHistory,
        },
      };

      await _triageRepository.saveTriageDraft(
        accessToken: accessToken,
        data: body,
      );
      emit(state.copyWith(isLoading: false, isSubmitted: true, currentStep: 2));
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> sendMessage(String accessToken, String text) async {
    if (text.trim().isEmpty) return;

    final userMsg = TriageMessage(
      text: text,
      isUser: true,
      time: _getCurrentTime(),
    );

    final updatedMessages = List<TriageMessage>.from(state.chatMessages)
      ..add(userMsg);
    emit(state.copyWith(chatMessages: updatedMessages));

    // Submit triage automatically to the real API
    await submitTriage(accessToken);
  }

  Future<void> sendImageMessage(
    String accessToken,
    String imagePath, {
    String? text,
  }) async {
    final userMsg = TriageMessage(
      text: text ?? 'Imagen adjunta',
      isUser: true,
      time: _getCurrentTime(),
      imagePath: imagePath,
    );

    final updatedMessages = List<TriageMessage>.from(state.chatMessages)
      ..add(userMsg);
    emit(state.copyWith(chatMessages: updatedMessages));

    // Submit triage automatically to the real API
    await submitTriage(accessToken);
  }

  Future<void> submitTriage(String accessToken) async {
    emit(state.copyWith(isAnalyzing: true));

    try {
      final userMessages = state.chatMessages
          .where((msg) => msg.isUser)
          .map((msg) => msg.text)
          .join(', ');
      final body = {
        "symptoms": userMessages.isEmpty
            ? "Evaluación general de síntomas"
            : userMessages,
      };

      final result = await _triageRepository.completeTriage(
        accessToken: accessToken,
        data: body,
      );
      final isReady = result['ready'] == true;

      if (isReady) {
        final rawSpecialties = result['suggestedSpecialties'];
        List<String> specs = [];
        if (rawSpecialties is List) {
          specs = rawSpecialties.map((s) => s.toString()).toList();
        }

        emit(
          state.copyWith(
            isCompleted: true,
            isAnalyzing: false,
            currentStep: 4,
            priority: result['priority']?.toString(),
            suggestedSpecialty: result['suggestedSpecialty']?.toString(),
            suggestedSpecialties: specs,
            patientSafeMessage: result['patientSafeMessage']?.toString(),
          ),
        );
      } else {
        // Stay on step 2 (chat) and append questions as options in the chat
        final missingQuestionsList = result['missingInfoQuestions'] ?? [];
        final String title =
            result['patientSafeMessage'] ??
            'Por favor, selecciona o responde lo siguiente:';

        final List<String> questionTexts = [];
        for (var q in missingQuestionsList) {
          questionTexts.add(q['question']?.toString() ?? '');
        }

        final aiResponse = TriageMessage(
          text: title,
          isUser: false,
          time: _getCurrentTime(),
          options: questionTexts.isNotEmpty ? questionTexts : null,
        );

        final updatedMessages = List<TriageMessage>.from(state.chatMessages)
          ..add(aiResponse);

        emit(
          state.copyWith(
            isAnalyzing: false,
            currentStep: 2,
            sessionId: result['sessionId'],
            missingQuestions: missingQuestionsList,
            chatMessages: updatedMessages,
            answers: {},
          ),
        );
      }
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      final shouldGoBack = errorMsg.contains('Complete los pasos anteriores');
      emit(
        state.copyWith(
          isAnalyzing: false,
          errorMessage: errorMsg,
          currentStep: shouldGoBack ? 1 : state.currentStep,
          chatMessages: shouldGoBack
              ? [
                  TriageMessage(
                    text:
                        'Hola, soy tu asistente de salud Priora. Para ayudarte mejor, cuéntame:\n\n¿Qué síntomas estás experimentando hoy y desde cuándo empezaron?',
                    isUser: false,
                    time: _getCurrentTime(),
                  ),
                ]
              : state.chatMessages,
        ),
      );
    }
  }

  Future<void> submitChatAnswers(String accessToken) async {
    final answersSummary = state.missingQuestions
        .map((q) {
          final qText = q['question']?.toString() ?? '';
          final qId = q['id']?.toString() ?? '';
          final ans = state.answers[qId] ?? '';
          return '$qText: $ans';
        })
        .join('\n');

    final userMsg = TriageMessage(
      text: answersSummary,
      isUser: true,
      time: _getCurrentTime(),
    );

    List<TriageMessage> updatedMessages = List<TriageMessage>.from(
      state.chatMessages,
    );
    if (updatedMessages.isNotEmpty) {
      final lastMsg = updatedMessages.last;
      updatedMessages[updatedMessages.length - 1] = TriageMessage(
        text: lastMsg.text,
        isUser: lastMsg.isUser,
        time: lastMsg.time,
        options: null,
        imagePath: lastMsg.imagePath,
      );
    }
    updatedMessages.add(userMsg);

    emit(
      state.copyWith(
        currentStep: 3,
        analysisProgress: 0,
        chatMessages: updatedMessages,
      ),
    );

    Map<String, dynamic>? result;
    Object? error;
    bool isTimerFinished = false;

    void checkCompletion() {
      print(
        "[debug] checkCompletion: isTimerFinished=$isTimerFinished, result=$result, error=$error",
      );
      if (!isTimerFinished || (result == null && error == null)) {
        print("[debug] checkCompletion: returning early");
        return;
      }

      if (error != null) {
        print("[debug] checkCompletion: emitting error and going to step 2");
        emit(
          state.copyWith(
            currentStep: 2,
            errorMessage: error.toString().replaceAll('Exception: ', ''),
          ),
        );
        return;
      }

      if (result != null) {
        final isReady = result!['ready'] == true;
        print("[debug] checkCompletion: isReady=$isReady");
        if (isReady) {
          final rawSpecialties = result!['suggestedSpecialties'];
          List<String> specs = [];
          if (rawSpecialties is List) {
            specs = rawSpecialties.map((s) => s.toString()).toList();
          }

          print(
            "[debug] checkCompletion: emitting completed state, currentStep=4",
          );
          emit(
            state.copyWith(
              isCompleted: true,
              currentStep: 4,
              priority: result!['priority']?.toString(),
              suggestedSpecialty: result!['suggestedSpecialty']?.toString(),
              suggestedSpecialties: specs,
              patientSafeMessage: result!['patientSafeMessage']?.toString(),
            ),
          );
        } else {
          final missingQuestionsList = result!['missingInfoQuestions'] ?? [];
          final String title =
              result!['patientSafeMessage'] ??
              'Por favor, selecciona o responde lo siguiente:';

          final List<String> questionTexts = [];
          for (var q in missingQuestionsList) {
            questionTexts.add(q['question']?.toString() ?? '');
          }

          final aiResponse = TriageMessage(
            text: title,
            isUser: false,
            time: _getCurrentTime(),
            options: questionTexts.isNotEmpty ? questionTexts : null,
          );

          final chatWithAi = List<TriageMessage>.from(state.chatMessages)
            ..add(aiResponse);

          print(
            "[debug] checkCompletion: emitting new questions state, currentStep=2",
          );
          emit(
            state.copyWith(
              currentStep: 2,
              sessionId: result!['sessionId'],
              missingQuestions: missingQuestionsList,
              chatMessages: chatWithAi,
              answers: {},
            ),
          );
        }
      }
    }

    _startProgressTimer(0, () {
      print("[debug] timer finished");
      isTimerFinished = true;
      checkCompletion();
    });

    try {
      final body = {"sessionId": state.sessionId, "answers": state.answers};
      print("[debug] sending continueTriage: $body");

      result = await _triageRepository.continueTriage(
        accessToken: accessToken,
        data: body,
      );
      print("[debug] continueTriage response: $result");
    } catch (e, stack) {
      error = e;
      print("[debug] continueTriage error: $e\n$stack");
    } finally {
      print("[debug] finally block");
      checkCompletion();
    }
  }

  Future<void> answerQuestionAndContinue(
    String accessToken,
    String questionId,
    String answer,
  ) async {
    final updatedAnswers = Map<String, String>.from(state.answers)
      ..addAll({questionId: answer});
    emit(state.copyWith(answers: updatedAnswers, isAnalyzing: true));

    // Show user's answer in the chat
    final userMsg = TriageMessage(
      text: answer,
      isUser: true,
      time: _getCurrentTime(),
    );
    final chatWithUserAnswer = List<TriageMessage>.from(state.chatMessages)
      ..add(userMsg);
    emit(state.copyWith(chatMessages: chatWithUserAnswer));

    try {
      final body = {"sessionId": state.sessionId, "answers": updatedAnswers};

      final result = await _triageRepository.continueTriage(
        accessToken: accessToken,
        data: body,
      );

      final isReady = result['ready'] == true;
      if (isReady) {
        final rawSpecialties = result['suggestedSpecialties'];
        List<String> specs = [];
        if (rawSpecialties is List) {
          specs = rawSpecialties.map((s) => s.toString()).toList();
        }

        emit(
          state.copyWith(
            isCompleted: true,
            isAnalyzing: false,
            currentStep: 4,
            priority: result['priority']?.toString(),
            suggestedSpecialty: result['suggestedSpecialty']?.toString(),
            suggestedSpecialties: specs,
            patientSafeMessage: result['patientSafeMessage']?.toString(),
          ),
        );
      } else {
        // AI still has more questions
        final missingQuestionsList = result['missingInfoQuestions'] ?? [];
        final String title =
            result['patientSafeMessage'] ??
            'Por favor, selecciona o responde lo siguiente:';

        final List<String> questionTexts = [];
        for (var q in missingQuestionsList) {
          questionTexts.add(q['question']?.toString() ?? '');
        }

        final aiResponse = TriageMessage(
          text: title,
          isUser: false,
          time: _getCurrentTime(),
          options: questionTexts.isNotEmpty ? questionTexts : null,
        );

        final updatedMessages = List<TriageMessage>.from(state.chatMessages)
          ..add(aiResponse);

        emit(
          state.copyWith(
            isAnalyzing: false,
            sessionId: result['sessionId'],
            missingQuestions: missingQuestionsList,
            chatMessages: updatedMessages,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          isAnalyzing: false,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  void _startProgressTimer(int startVal, Function() onComplete) {
    _progressTimer?.cancel();
    emit(state.copyWith(analysisProgress: startVal));

    _progressTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      final current = state.analysisProgress;
      if (current < 100) {
        emit(state.copyWith(analysisProgress: current + 1));
      } else {
        timer.cancel();
        onComplete();
      }
    });
  }

  void loadDraft(Map<String, dynamic> draftData) {
    final medicalHistory = draftData['medicalHistory'] as Map<String, dynamic>? ?? {};
    final step = draftData['step'] as int? ?? 1;

    final surgeries = medicalHistory['previousSurgeries']?.toString() ?? '';
    final allergies = medicalHistory['allergies']?.toString() ?? '';
    final otherHistory = medicalHistory['other']?.toString() ?? '';

    final String chronicConditionsStr = medicalHistory['chronicConditions']?.toString() ?? '';
    List<String> conditions = [];
    String otherChronic = '';
    if (chronicConditionsStr.isNotEmpty && chronicConditionsStr != 'Ninguna') {
      final parts = chronicConditionsStr.split(',').map((s) => s.trim()).toList();
      const common = ['Diabetes', 'Hipertensión', 'Asma', 'Tiroides'];
      for (var part in parts) {
        if (common.contains(part)) {
          conditions.add(part);
        } else {
          otherChronic = otherChronic.isEmpty ? part : '$otherChronic, $part';
        }
      }
    }

    emit(state.copyWith(
      currentStep: step,
      surgeries: surgeries,
      allergies: allergies,
      otherHistory: otherHistory,
      chronicConditions: conditions,
      otherChronicConditions: otherChronic,
    ));
  }

  void reset() {
    emit(TriageState());
    _initChat();
  }

  @override
  Future<void> close() {
    _progressTimer?.cancel();
    return super.close();
  }
}
