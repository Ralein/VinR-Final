/// Base typed error class for all AI platform operations.
abstract class AiError implements Exception {
  final String message;
  final String code;
  final dynamic details;

  const AiError(this.message, {required this.code, this.details});

  @override
  String toString() => '$code: $message';
}

class ModelMissingError extends AiError {
  const ModelMissingError([String message = 'Local AI model file is not downloaded.'])
      : super(message, code: 'MODEL_MISSING');
}

class ModelCorruptError extends AiError {
  const ModelCorruptError([String message = 'Model integrity checksum verification failed.'])
      : super(message, code: 'MODEL_CORRUPT');
}

class ModelLoadFailedError extends AiError {
  const ModelLoadFailedError([String message = 'Failed to load model weights into runtime.', dynamic details])
      : super(message, code: 'MODEL_LOAD_FAILED', details: details);
}

class RuntimeUnavailableError extends AiError {
  const RuntimeUnavailableError([String message = 'Inference runtime is currently unavailable.'])
      : super(message, code: 'RUNTIME_UNAVAILABLE');
}

class GenerationFailedError extends AiError {
  const GenerationFailedError([String message = 'AI text generation failed.', dynamic details])
      : super(message, code: 'GENERATION_FAILED', details: details);
}

class GenerationCancelledError extends AiError {
  const GenerationCancelledError([String message = 'Generation was cancelled by user or scheduler.'])
      : super(message, code: 'GENERATION_CANCELLED');
}

class ContextTooLargeError extends AiError {
  const ContextTooLargeError([String message = 'Assembled context exceeds model maximum context window.'])
      : super(message, code: 'CONTEXT_TOO_LARGE');
}

class InvalidStructuredOutputError extends AiError {
  const InvalidStructuredOutputError([String message = 'Model output did not match expected JSON schema.', dynamic details])
      : super(message, code: 'INVALID_STRUCTURED_OUTPUT', details: details);
}

class MemoryPressureError extends AiError {
  const MemoryPressureError([String message = 'Operation aborted due to device memory pressure.'])
      : super(message, code: 'MEMORY_PRESSURE');
}

class PermissionDeniedError extends AiError {
  const PermissionDeniedError([String message = 'Microphone or storage permission denied.'])
      : super(message, code: 'PERMISSION_DENIED');
}

class VoiceUnavailableError extends AiError {
  const VoiceUnavailableError([String message = 'Speech-to-text or TTS service is unavailable.'])
      : super(message, code: 'VOICE_UNAVAILABLE');
}

class UnknownAiError extends AiError {
  const UnknownAiError([String message = 'An unexpected AI subsystem error occurred.', dynamic details])
      : super(message, code: 'UNKNOWN_AI_ERROR', details: details);
}
