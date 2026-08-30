import '../../domain/ai_request.dart';
import '../../domain/ai_task.dart';
import 'prompt_templates.dart';

/// Versioned prompt descriptor and formatter.
class VersionedPrompt {
  final String version;
  final String Function(AiRequest request) formatter;

  const VersionedPrompt({
    required this.version,
    required this.formatter,
  });
}

/// Central registry holding all prompt version mappings for tasks.
class PromptRegistry {
  static final Map<AiTask, VersionedPrompt> _registry = {
    AiTask.conversation: const VersionedPrompt(
      version: 'chat.v1',
      formatter: PromptTemplates.buildConversationPrompt,
    ),
    AiTask.voiceResponse: const VersionedPrompt(
      version: 'voice.v1',
      formatter: PromptTemplates.buildConversationPrompt,
    ),
    AiTask.glintGeneration: const VersionedPrompt(
      version: 'glint.v1',
      formatter: PromptTemplates.buildGlintPrompt,
    ),
    AiTask.glintQuote: const VersionedPrompt(
      version: 'glint_quote.v1',
      formatter: PromptTemplates.buildGlintPrompt,
    ),
    AiTask.glintReflection: const VersionedPrompt(
      version: 'glint_reflection.v1',
      formatter: PromptTemplates.buildGlintPrompt,
    ),
    AiTask.planning: const VersionedPrompt(
      version: 'planner.v1',
      formatter: PromptTemplates.buildPlanningPrompt,
    ),
    AiTask.journalAssist: const VersionedPrompt(
      version: 'journal.v1',
      formatter: PromptTemplates.buildJournalAssistPrompt,
    ),
    AiTask.dailyCheckin: const VersionedPrompt(
      version: 'checkin.v1',
      formatter: PromptTemplates.buildConversationPrompt,
    ),
    AiTask.goalSupport: const VersionedPrompt(
      version: 'goal_support.v1',
      formatter: PromptTemplates.buildConversationPrompt,
    ),
    AiTask.habitSupport: const VersionedPrompt(
      version: 'habit_support.v1',
      formatter: PromptTemplates.buildConversationPrompt,
    ),
  };

  static VersionedPrompt getPrompt(AiTask task) {
    return _registry[task] ??
        const VersionedPrompt(
          version: 'chat.v1',
          formatter: PromptTemplates.buildConversationPrompt,
        );
  }

  static String format(AiRequest request) {
    final prompt = getPrompt(request.task);
    return prompt.formatter(request);
  }

  static String getVersion(AiTask task) {
    return getPrompt(task).version;
  }
}
