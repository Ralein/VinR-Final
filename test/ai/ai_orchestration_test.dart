import 'package:flutter_test/flutter_test.dart';
import 'package:vinr_app/core/ai/domain/ai_request.dart';
import 'package:vinr_app/core/ai/domain/ai_task.dart';
import 'package:vinr_app/core/ai/domain/ai_context.dart';
import 'package:vinr_app/core/ai/application/context_builder.dart';
import 'package:vinr_app/core/ai/application/response_validator.dart';
import 'package:vinr_app/core/ai/application/ai_orchestrator.dart';
import 'package:vinr_app/core/ai/infrastructure/prompting/prompt_registry.dart';
import 'package:vinr_app/core/ai/infrastructure/prompting/generation_profile.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AI Orchestration & Prompt Engine Tests', () {
    test('GenerationProfile resolution for tasks', () {
      final chatProf = GenerationProfile.forTask(AiTask.conversation);
      expect(chatProf.name, 'BalancedChat');
      expect(chatProf.priority, AiPriority.interactive);

      final glintProf = GenerationProfile.forTask(AiTask.glintGeneration);
      expect(glintProf.name, 'Glint');
      expect(glintProf.isStructured, true);
    });

    test('PromptRegistry formats conversation and glint prompts', () {
      final req = AiRequest(
        task: AiTask.conversation,
        userInput: 'How to stay consistent?',
        persona: 'Stoic Guardian',
        context: const AiContext(streakDays: 7, currentMood: 'Determined'),
      );

      final prompt = PromptRegistry.format(req);
      expect(prompt, contains('Stoic Guardian'));
      expect(prompt, contains('Winning Streak: Day 7'));
      expect(prompt, contains('How to stay consistent?'));
    });

    test('ContextBuilder trims and bounds history and memories', () {
      final context = ContextBuilder.build(
        currentScreen: 'ChatScreen',
        streakDays: 12,
        currentMood: 'Energized',
        activeGoals: ['Complete workout'],
      );

      expect(context.streakDays, 12);
      expect(context.currentMood, 'Energized');
      expect(context.activeGoals.length, 1);
    });

    test('ResponseValidator extracts and validates JSON Glint', () {
      const rawJson = '''
```json
{
  "type": "motivation",
  "title": "Daily Discipline",
  "body": "Small actions repeated daily build massive results.",
  "quote": "Consistency compounds.",
  "author": "VinR",
  "mood": "encouraging",
  "accent": "gold",
  "priority": 3
}
```
''';
      final validated = ResponseValidator.validateStructuredOutput(rawJson, AiTask.glintGeneration);
      expect(validated, isNotNull);
      expect(validated!['title'], 'Daily Discipline');
      expect(validated['accent'], 'gold');
    });

    test('AiOrchestrator generates response and executes task', () async {
      final orchestrator = AiOrchestrator.instance;
      final req = AiRequest(
        task: AiTask.glintGeneration,
        userInput: 'Focus',
      );

      final response = await orchestrator.execute(req);
      expect(response.text, isNotEmpty);
      expect(response.structuredData, isNotNull);
      expect(response.structuredData!['title'], isNotEmpty);
    });
  });
}
