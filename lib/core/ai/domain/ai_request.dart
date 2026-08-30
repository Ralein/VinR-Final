import 'ai_context.dart';
import 'ai_task.dart';

/// Task priority constants for the scheduler.
class AiPriority {
  static const int interactive = 100;
  static const int voice = 90;
  static const int glint = 50;
  static const int background = 20;
  static const int maintenance = 5;
}

/// Token to facilitate cooperative generation cancellation.
class AiCancellationToken {
  bool _isCancelled = false;
  final List<void Function()> _listeners = [];

  bool get isCancelled => _isCancelled;

  void cancel() {
    if (_isCancelled) return;
    _isCancelled = true;
    for (final listener in _listeners) {
      listener();
    }
  }

  void addListener(void Function() listener) {
    if (_isCancelled) {
      listener();
    } else {
      _listeners.add(listener);
    }
  }
}

/// Standardized typed request into the AI Platform Layer.
class AiRequest {
  final String requestId;
  final AiTask task;
  final String userInput;
  final String? conversationId;
  final AiContext? context;
  final String persona;
  final double? temperature;
  final int? maxOutputTokens;
  final int priority;
  final String? responseSchema;
  final bool allowMemoryWrite;
  final bool stream;
  final AiCancellationToken? cancellationToken;
  final Map<String, dynamic> parameters;

  AiRequest({
    String? requestId,
    required this.task,
    required this.userInput,
    this.conversationId,
    this.context,
    this.persona = 'VinR Coach',
    this.temperature,
    this.maxOutputTokens,
    this.priority = AiPriority.interactive,
    this.responseSchema,
    this.allowMemoryWrite = true,
    this.stream = false,
    this.cancellationToken,
    this.parameters = const {},
  }) : requestId = requestId ?? 'req_${DateTime.now().microsecondsSinceEpoch}';

  AiRequest copyWith({
    String? requestId,
    AiTask? task,
    String? userInput,
    String? conversationId,
    AiContext? context,
    String? persona,
    double? temperature,
    int? maxOutputTokens,
    int? priority,
    String? responseSchema,
    bool? allowMemoryWrite,
    bool? stream,
    AiCancellationToken? cancellationToken,
    Map<String, dynamic>? parameters,
  }) {
    return AiRequest(
      requestId: requestId ?? this.requestId,
      task: task ?? this.task,
      userInput: userInput ?? this.userInput,
      conversationId: conversationId ?? this.conversationId,
      context: context ?? this.context,
      persona: persona ?? this.persona,
      temperature: temperature ?? this.temperature,
      maxOutputTokens: maxOutputTokens ?? this.maxOutputTokens,
      priority: priority ?? this.priority,
      responseSchema: responseSchema ?? this.responseSchema,
      allowMemoryWrite: allowMemoryWrite ?? this.allowMemoryWrite,
      stream: stream ?? this.stream,
      cancellationToken: cancellationToken ?? this.cancellationToken,
      parameters: parameters ?? this.parameters,
    );
  }
}
