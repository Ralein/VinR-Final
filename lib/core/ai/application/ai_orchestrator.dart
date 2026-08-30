import 'dart:async';
import '../domain/ai_error.dart';
import '../domain/ai_request.dart';
import '../domain/ai_response.dart';
import '../infrastructure/prompting/prompt_registry.dart';
import '../infrastructure/runtime/local_llm_runtime.dart';
import '../infrastructure/runtime/local_llm_runtime_factory.dart';
import '../infrastructure/runtime/model_manager.dart';
import 'ai_policy.dart';
import 'ai_scheduler.dart';
import 'response_validator.dart';

/// Central facade orchestrating local inference, scheduling, prompting, safety, and validation.
class AiOrchestrator {
  static final AiOrchestrator instance = AiOrchestrator._internal();
  AiOrchestrator._internal();

  final LocalLlmRuntime _runtime = LocalLlmRuntimeFactory.getRuntime();
  final ModelManager _modelManager = ModelManager.instance;
  final AiScheduler _scheduler = AiScheduler.instance;

  /// Executes inference and streams token chunks back to the presentation buffer.
  Stream<AiToken> stream(AiRequest request) async* {
    // 1. Sanitize user input against prompt injection
    final sanitizedInput = AiPolicy.sanitizeUserInput(request.userInput);
    final sanitizedRequest = request.copyWith(userInput: sanitizedInput);

    // 2. Ensure model runtime is ready
    final isLoaded = await _modelManager.ensureModelLoaded(runtime: _runtime);
    if (!isLoaded) {
      throw const ModelMissingError();
    }

    _modelManager.markBusy();

    try {
      final tokenStream = _runtime.generate(sanitizedRequest);
      await for (final token in tokenStream) {
        yield token;
        if (token.isFinished) break;
      }
    } finally {
      _modelManager.markIdle();
    }
  }

  /// Executes task synchronously to completion and validates output.
  Future<AiResponse> execute(AiRequest request) async {
    final sanitizedInput = AiPolicy.sanitizeUserInput(request.userInput);
    final sanitizedRequest = request.copyWith(userInput: sanitizedInput);

    return _scheduler.schedule<AiResponse>(
      request: sanitizedRequest,
      execute: (cancellationToken) async {
        final isLoaded = await _modelManager.ensureModelLoaded(runtime: _runtime);
        if (!isLoaded) {
          throw const ModelMissingError();
        }

        _modelManager.markBusy();
        final stopwatch = Stopwatch()..start();
        final fullTextBuffer = StringBuffer();
        int tokenCount = 0;
        String finishReason = 'stop';

        try {
          final requestWithToken = sanitizedRequest.copyWith(cancellationToken: cancellationToken);
          final stream = _runtime.generate(requestWithToken);

          await for (final chunk in stream) {
            fullTextBuffer.write(chunk.text);
            tokenCount++;
            if (chunk.isFinished) {
              finishReason = chunk.finishReason ?? 'stop';
              break;
            }
          }

          stopwatch.stop();
          final text = fullTextBuffer.toString().trim();

          Map<String, dynamic>? structuredData;
          if (request.task.isStructured) {
            structuredData = ResponseValidator.validateStructuredOutput(text, request.task);
          }

          return AiResponse(
            text: text,
            structuredData: structuredData,
            task: request.task,
            generationId: 'gen_${DateTime.now().millisecondsSinceEpoch}',
            latencyMs: stopwatch.elapsedMilliseconds,
            tokenCount: tokenCount,
            finishReason: finishReason,
          );
        } finally {
          _modelManager.markIdle();
        }
      },
    );
  }

  /// Cancels any active generation.
  void cancel() {
    _scheduler.cancelCurrent();
    _runtime.cancelCurrentGeneration();
  }
}
