import 'dart:async';
import 'dart:convert';
import '../../domain/ai_error.dart';
import '../../domain/ai_request.dart';
import '../../domain/ai_response.dart';
import '../../domain/ai_task.dart';
import 'inference_config.dart';
import 'local_llm_runtime.dart';
import 'model_metadata.dart';

/// Production-grade on-device local inference engine simulator.
/// Provides offline token streaming, structured JSON generation, and cancellation handling.
class MockLocalLlmRuntime implements LocalLlmRuntime {
  bool _isInitialized = false;
  ModelMetadata? _loadedModel;
  InferenceConfig _config = const InferenceConfig();
  bool _isGenerating = false;
  AiCancellationToken? _currentCancellationToken;
  int _lastLatencyMs = 0;
  int _lastTokenCount = 0;

  @override
  Future<void> initialize(ModelMetadata model, [InferenceConfig? config]) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _loadedModel = model;
    _config = config ?? const InferenceConfig();
    _isInitialized = true;
  }

  @override
  Future<void> dispose() async {
    await cancelCurrentGeneration();
    _isInitialized = false;
    _loadedModel = null;
  }

  @override
  Future<bool> isReady() async => _isInitialized;

  @override
  Future<AiRuntimeStats> stats() async {
    return AiRuntimeStats(
      promptTokens: 84,
      generatedTokens: _lastTokenCount,
      latencyMs: _lastLatencyMs,
      tokensPerSecond: _lastLatencyMs > 0 ? (_lastTokenCount / (_lastLatencyMs / 1000.0)) : 28.5,
      memoryUsageMb: 485,
    );
  }

  @override
  Future<void> cancelCurrentGeneration() async {
    if (_isGenerating) {
      _currentCancellationToken?.cancel();
      _isGenerating = false;
    }
  }

  @override
  Stream<AiToken> generate(AiRequest request) async* {
    if (!_isInitialized) {
      throw const ModelMissingError('Local model runtime is not initialized.');
    }

    _isGenerating = true;
    _currentCancellationToken = request.cancellationToken;
    final stopwatch = Stopwatch()..start();

    final responseText = _craftTaskResponse(request);
    final tokens = _tokenize(responseText);
    _lastTokenCount = tokens.length;

    try {
      for (int i = 0; i < tokens.length; i++) {
        if (request.cancellationToken?.isCancelled == true || !_isGenerating) {
          yield AiToken.done('cancelled');
          return;
        }

        yield AiToken(
          text: tokens[i],
          isFinished: i == tokens.length - 1,
          finishReason: i == tokens.length - 1 ? 'stop' : null,
          index: i,
        );

        // Async micro-yield simulating local mobile quantized generation (~25-35 tokens/sec)
        await Future.delayed(const Duration(milliseconds: 28));
      }
    } finally {
      stopwatch.stop();
      _lastLatencyMs = stopwatch.elapsedMilliseconds;
      _isGenerating = false;
    }
  }

  List<String> _tokenize(String text) {
    final regex = RegExp(r'(\s+|[^\s\w]+|\w+)');
    final matches = regex.allMatches(text);
    if (matches.isEmpty) return [text];
    return matches.map((m) => m.group(0) ?? '').where((s) => s.isNotEmpty).toList();
  }

  String _craftTaskResponse(AiRequest request) {
    final persona = request.persona.toLowerCase();
    final userInput = request.userInput.trim();
    final context = request.context;
    final streakDays = context?.streakDays ?? 5;

    switch (request.task) {
      case AiTask.glintGeneration:
        return jsonEncode({
          "type": "motivation",
          "title": "Compounding Fortitude",
          "body": "Small, uncelebrated actions repeated daily build unshakable momentum. Your $streakDays-day streak is solid proof.",
          "quote": "Consistency compounds into destiny.",
          "author": "VinR",
          "mood": "encouraging",
          "accent": "gold",
          "priority": 3,
          "action_label": "Log Check-in",
        });

      case AiTask.glintQuote:
        return jsonEncode({
          "type": "quote",
          "title": "Stoic Reflection",
          "body": "Focus exclusively on what lies within your voluntary choice; release anxiety over external outcomes.",
          "quote": "You have power over your mind, not outside events.",
          "author": "Marcus Aurelius",
          "mood": "stoic",
          "accent": "sapphire",
          "priority": 2,
        });

      case AiTask.glintReflection:
        return jsonEncode({
          "type": "reflection",
          "title": "Evening Alignment",
          "body": "Pause and acknowledge one small victory from today. Recovery is an active part of discipline.",
          "quote": "Rest when needed, but never quit.",
          "author": "VinR",
          "mood": "calm",
          "accent": "emerald",
          "priority": 1,
        });

      case AiTask.planning:
        return jsonEncode({
          "goal": userInput.isNotEmpty ? userInput : "Maintain 21-Day Winning Habit",
          "steps": [
            {"step": 1, "action": "Morning 5-minute breathwork", "duration_minutes": 5},
            {"step": 2, "action": "Deep focus sprint on core objective", "duration_minutes": 25},
            {"step": 3, "action": "Evening check-in and gratitude reflection", "duration_minutes": 5}
          ],
          "milestone": "Day $streakDays Complete"
        });

      case AiTask.journalAssist:
        return "I hear the authenticity in your reflection. Recognizing how your environment affects your mindset is the first step in mastering it. What is one small boundary you can set tomorrow to protect this calm?";

      case AiTask.dailyCheckin:
        return "Day $streakDays of your 21-day winning streak is in motion. Keep the pace steady and trust the compound process!";

      case AiTask.conversation:
      case AiTask.voiceResponse:
      default:
        return _generatePersonaReply(userInput, persona, streakDays, context?.currentMood);
    }
  }

  String _generatePersonaReply(String input, String persona, int streakDays, String? mood) {
    final lower = input.toLowerCase();

    if (lower.contains('anxious') || lower.contains('stress') || lower.contains('overwhelm')) {
      if (persona.contains('stoic')) {
        return "Observe this feeling without judgment. Marcus Aurelius reminded us that anxiety does not exist in things outside of you, but in your own judgments. Let us ground ourselves with 3 box breaths.";
      } else if (persona.contains('zen') || persona.contains('listener')) {
        return "Take a slow, deep breath with me. Inhale for 4 seconds, hold for 7, and exhale for 8. You are safe in this moment, and we can take things one step at a time.";
      } else {
        return "I'm right here with you, champion. Stress is just unchanneled energy. Let's take 3 deep breaths and break down the very next smallest step you can take right now.";
      }
    }

    if (lower.contains('streak') || lower.contains('habit') || lower.contains('goal')) {
      return "You're holding strong at Day $streakDays of your winning streak! The compound effect works quietly before the breakthrough becomes visible. What is our focus for today?";
    }

    if (persona.contains('stoic')) {
      return "Every obstacle presents an opportunity to practice virtue and discipline. Control your perception, direct your action rightly, and embrace what happens. How can I assist your focus today?";
    } else if (persona.contains('zen')) {
      return "Peace is found in presence, not in the absence of noise. Notice how you feel right now. Let us move forward with clarity and intention.";
    } else if (persona.contains('solar') || persona.contains('spark')) {
      return "High energy, high focus! Every choice today is fuel for your future self. Let's conquer Day $streakDays with full momentum!";
    } else {
      return "Every step counts on your journey. As your VinR growth partner, I'm dedicated to backing your daily progress. Let's keep building that 21-day winning habit!";
    }
  }
}
