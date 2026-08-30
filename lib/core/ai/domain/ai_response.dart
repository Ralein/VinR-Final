import 'ai_memory.dart';
import 'ai_task.dart';

/// Single token chunk emitted during streaming generation.
class AiToken {
  final String text;
  final bool isFinished;
  final String? finishReason;
  final int index;

  const AiToken({
    required this.text,
    this.isFinished = false,
    this.finishReason,
    this.index = 0,
  });

  factory AiToken.done([String reason = 'stop']) {
    return AiToken(
      text: '',
      isFinished: true,
      finishReason: reason,
    );
  }
}

/// Standardized output returned from the AI Platform Layer.
class AiResponse {
  final String text;
  final Map<String, dynamic>? structuredData;
  final AiTask task;
  final String generationId;
  final int latencyMs;
  final int tokenCount;
  final String finishReason;
  final List<AiMemory> memoryUpdates;
  final List<String> warnings;

  const AiResponse({
    required this.text,
    this.structuredData,
    required this.task,
    required this.generationId,
    required this.latencyMs,
    this.tokenCount = 0,
    this.finishReason = 'stop',
    this.memoryUpdates = const [],
    this.warnings = const [],
  });

  Map<String, dynamic> toJson() => {
        'text': text,
        'structured_data': structuredData,
        'task': task.id,
        'generation_id': generationId,
        'latency_ms': latencyMs,
        'token_count': tokenCount,
        'finish_reason': finishReason,
        'memory_updates': memoryUpdates.map((m) => m.toJson()).toList(),
        'warnings': warnings,
      };
}
