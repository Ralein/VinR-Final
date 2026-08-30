/// Configuration parameters for local LLM inference execution.
class InferenceConfig {
  final int maxContextTokens;
  final int defaultMaxOutputTokens;
  final double defaultTemperature;
  final double defaultTopP;
  final int threadCount;
  final List<String> defaultStopSequences;

  const InferenceConfig({
    this.maxContextTokens = 2048,
    this.defaultMaxOutputTokens = 256,
    this.defaultTemperature = 0.7,
    this.defaultTopP = 0.9,
    this.threadCount = 4,
    this.defaultStopSequences = const ['<|im_end|>', '<|endoftext|>', 'USER:', 'ASSISTANT:'],
  });

  Map<String, dynamic> toJson() => {
        'max_context_tokens': maxContextTokens,
        'default_max_output_tokens': defaultMaxOutputTokens,
        'default_temperature': defaultTemperature,
        'default_top_p': defaultTopP,
        'thread_count': threadCount,
        'default_stop_sequences': defaultStopSequences,
      };
}

/// Generation stats emitted after an inference pass.
class AiRuntimeStats {
  final int promptTokens;
  final int generatedTokens;
  final int latencyMs;
  final double tokensPerSecond;
  final int memoryUsageMb;

  const AiRuntimeStats({
    this.promptTokens = 0,
    this.generatedTokens = 0,
    this.latencyMs = 0,
    this.tokensPerSecond = 0.0,
    this.memoryUsageMb = 0,
  });

  Map<String, dynamic> toJson() => {
        'prompt_tokens': promptTokens,
        'generated_tokens': generatedTokens,
        'latency_ms': latencyMs,
        'tokens_per_second': tokensPerSecond,
        'memory_usage_mb': memoryUsageMb,
      };
}
