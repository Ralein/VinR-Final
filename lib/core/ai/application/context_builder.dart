import '../domain/ai_context.dart';
import '../domain/ai_memory.dart';
import '../domain/ai_message.dart';

/// Selectively builds token-budgeted prompt context from on-device repositories and stores.
class ContextBuilder {
  static const int maxHistoryMessages = 8;
  static const int maxMemoriesInContext = 4;
  static const int maxTotalContextTokens = 1200;

  /// Assembles and trims context according to strict token budgets.
  static AiContext build({
    String? currentScreen,
    int? streakDays,
    String? currentMood,
    List<String> activeGoals = const [],
    List<String> activeHabits = const [],
    String persona = 'VinR Coach',
    String dailyPacing = '10 mins / day',
    List<AiMessage> fullHistory = const [],
    List<AiMemory> availableMemories = const [],
    Map<String, dynamic> extraContext = const {},
  }) {
    // 1. Trim messages to most recent window
    final recentMessages = fullHistory.length > maxHistoryMessages
        ? fullHistory.sublist(fullHistory.length - maxHistoryMessages)
        : List<AiMessage>.from(fullHistory);

    // 2. Select top-k relevant memories by confidence & access count
    final sortedMemories = List<AiMemory>.from(availableMemories)
      ..sort((a, b) {
        final scoreA = a.confidence * (1 + a.accessCount * 0.1);
        final scoreB = b.confidence * (1 + b.accessCount * 0.1);
        return scoreB.compareTo(scoreA);
      });

    final relevantMemories = sortedMemories.take(maxMemoriesInContext).toList();

    var context = AiContext(
      currentScreen: currentScreen,
      streakDays: streakDays,
      currentMood: currentMood,
      activeGoals: activeGoals,
      activeHabits: activeHabits,
      persona: persona,
      dailyPacing: dailyPacing,
      recentMessages: recentMessages,
      relevantMemories: relevantMemories,
      extraContext: extraContext,
    );

    // 3. Ensure token budget is not exceeded
    while (context.estimateTokenCount() > maxTotalContextTokens && recentMessages.isNotEmpty) {
      recentMessages.removeAt(0);
      context = context;
    }

    return context;
  }
}
