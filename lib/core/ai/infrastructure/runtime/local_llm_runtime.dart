import 'dart:async';
import '../../domain/ai_request.dart';
import '../../domain/ai_response.dart';
import 'inference_config.dart';
import 'model_metadata.dart';

/// Abstract interface for local mobile LLM inference engines (Android/iOS/FFI/Simulator).
abstract class LocalLlmRuntime {
  /// Loads and prepares model weights in a background runtime isolate.
  Future<void> initialize(ModelMetadata model, [InferenceConfig? config]);

  /// Safely releases model memory and cleans up native runtime context.
  Future<void> dispose();

  /// Executes inference and streams token chunks outside the Flutter UI isolate.
  Stream<AiToken> generate(AiRequest request);

  /// Checks if the runtime is loaded and ready for prompt requests.
  Future<bool> isReady();

  /// Emits runtime telemetry and performance stats.
  Future<AiRuntimeStats> stats();

  /// Interrupts any currently running generation immediately.
  Future<void> cancelCurrentGeneration();
}
