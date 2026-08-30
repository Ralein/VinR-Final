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
  const ModelMissingError([super.message = 'Local AI model file is not downloaded.'])
      : super(code: 'MODEL_MISSING');
}

class ModelCorruptError extends AiError {
  const ModelCorruptError([super.message = 'Model integrity checksum verification failed.'])
      : super(code: 'MODEL_CORRUPT');
}

class ModelLoadFailedError extends AiError {
  const ModelLoadFailedError([super.message = 'Failed to load model weights into runtime.', dynamic details])
      : super(code: 'MODEL_LOAD_FAILED', details: details);
}

class RuntimeUnavailableError extends AiError {
  const RuntimeUnavailableError([super.message = 'Inference runtime is currently unavailable.'])
      : super(code: 'RUNTIME_UNAVAILABLE');
}

class GenerationFailedError extends AiError {
  const GenerationFailedError([super.message = 'AI text generation failed.', dynamic details])
      : super(code: 'GENERATION_FAILED', details: details);
}

class GenerationCancelledError extends AiError {
  const GenerationCancelledError([super.message = 'Generation was cancelled by user or scheduler.'])
      : super(code: 'GENERATION_CANCELLED');
}

class ContextTooLargeError extends AiError {
  const ContextTooLargeError([super.message = 'Assembled context exceeds model maximum context window.'])
      : super(code: 'CONTEXT_TOO_LARGE');
}

class InvalidStructuredOutputError extends AiError {
  const InvalidStructuredOutputError([super.message = 'Model output did not match expected JSON schema.', dynamic details])
      : super(code: 'INVALID_STRUCTURED_OUTPUT', details: details);
}

class MemoryPressureError extends AiError {
  const MemoryPressureError([super.message = 'Operation aborted due to device memory pressure.'])
      : super(code: 'MEMORY_PRESSURE');
}

class PermissionDeniedError extends AiError {
  const PermissionDeniedError([super.message = 'Microphone or storage permission denied.'])
      : super(code: 'PERMISSION_DENIED');
}

class VoiceUnavailableError extends AiError {
  const VoiceUnavailableError([super.message = 'Speech-to-text or TTS service is unavailable.'])
      : super(code: 'VOICE_UNAVAILABLE');
}

class UnknownAiError extends AiError {
  const UnknownAiError([super.message = 'An unexpected AI subsystem error occurred.', dynamic details])
      : super(code: 'UNKNOWN_AI_ERROR', details: details);
}
