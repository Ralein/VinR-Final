import '../../domain/ai_request.dart';
import '../../domain/ai_task.dart';

/// Predefined tuning profiles for local LLM generation tasks.
class GenerationProfile {
  final String name;
  final double temperature;
  final double topP;
  final int maxTokens;
  final int priority;
  final bool isStructured;
  final List<String> stopSequences;

  const GenerationProfile({
    required this.name,
    required this.temperature,
    required this.topP,
    required this.maxTokens,
    required this.priority,
    this.isStructured = false,
    this.stopSequences = const ['<|im_end|>', '<|endoftext|>', 'USER:', 'ASSISTANT:'],
  });

  static const fastChat = GenerationProfile(
    name: 'FastChat',
    temperature: 0.6,
    topP: 0.9,
    maxTokens: 180,
    priority: AiPriority.interactive,
  );

  static const balancedChat = GenerationProfile(
    name: 'BalancedChat',
    temperature: 0.7,
    topP: 0.9,
    maxTokens: 256,
    priority: AiPriority.interactive,
  );

  static const deepReflection = GenerationProfile(
    name: 'DeepReflection',
    temperature: 0.5,
    topP: 0.85,
    maxTokens: 320,
    priority: 80,
  );

  static const glint = GenerationProfile(
    name: 'Glint',
    temperature: 0.65,
    topP: 0.9,
    maxTokens: 200,
    priority: AiPriority.glint,
    isStructured: true,
  );

  static const motivational = GenerationProfile(
    name: 'Motivational',
    temperature: 0.75,
    topP: 0.95,
    maxTokens: 120,
    priority: 60,
  );

  static const planner = GenerationProfile(
    name: 'Planner',
    temperature: 0.3,
    topP: 0.8,
    maxTokens: 300,
    priority: 70,
    isStructured: true,
  );

  static const voice = GenerationProfile(
    name: 'Voice',
    temperature: 0.6,
    topP: 0.9,
    maxTokens: 140,
    priority: AiPriority.voice,
  );

  static GenerationProfile forTask(AiTask task) {
    switch (task) {
      case AiTask.glintGeneration:
      case AiTask.glintQuote:
      case AiTask.glintReflection:
        return glint;
      case AiTask.planning:
        return planner;
      case AiTask.journalAssist:
        return deepReflection;
      case AiTask.voiceResponse:
        return voice;
      case AiTask.suggestion:
        return motivational;
      case AiTask.conversation:
      default:
        return balancedChat;
    }
  }
}
