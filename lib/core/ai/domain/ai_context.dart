import 'ai_memory.dart';
import 'ai_message.dart';

/// Context assembled dynamically by the ContextBuilder for an AI inference task.
class AiContext {
  final String? currentScreen;
  final int? streakDays;
  final String? currentMood;
  final List<String> activeGoals;
  final List<String> activeHabits;
  final String persona;
  final String dailyPacing;
  final List<AiMessage> recentMessages;
  final List<AiMemory> relevantMemories;
  final Map<String, dynamic> extraContext;

  const AiContext({
    this.currentScreen,
    this.streakDays,
    this.currentMood,
    this.activeGoals = const [],
    this.activeHabits = const [],
    this.persona = 'VinR Coach',
    this.dailyPacing = '10 mins / day (Standard)',
    this.recentMessages = const [],
    this.relevantMemories = const [],
    this.extraContext = const {},
  });

  /// Estimates approximate token consumption for budgeting
  int estimateTokenCount() {
    int count = 0;
    count += (persona.length / 4).ceil();
    count += (dailyPacing.length / 4).ceil();
    if (currentMood != null) count += (currentMood!.length / 4).ceil();
    for (final g in activeGoals) {
      count += (g.length / 4).ceil();
    }
    for (final h in activeHabits) {
      count += (h.length / 4).ceil();
    }
    for (final m in recentMessages) {
      count += m.tokenEstimate > 0 ? m.tokenEstimate : (m.content.length / 4).ceil();
    }
    for (final mem in relevantMemories) {
      count += ((mem.key.length + mem.value.length) / 4).ceil();
    }
    return count;
  }

  Map<String, dynamic> toJson() => {
        'current_screen': currentScreen,
        'streak_days': streakDays,
        'current_mood': currentMood,
        'active_goals': activeGoals,
        'active_habits': activeHabits,
        'persona': persona,
        'daily_pacing': dailyPacing,
        'recent_messages': recentMessages.map((m) => m.toJson()).toList(),
        'relevant_memories': relevantMemories.map((m) => m.toJson()).toList(),
        'extra_context': extraContext,
      };

  factory AiContext.fromJson(Map<String, dynamic> json) {
    return AiContext(
      currentScreen: json['current_screen'] as String?,
      streakDays: (json['streak_days'] as num?)?.toInt(),
      currentMood: json['current_mood'] as String?,
      activeGoals: (json['active_goals'] as List?)?.cast<String>() ?? const [],
      activeHabits: (json['active_habits'] as List?)?.cast<String>() ?? const [],
      persona: json['persona'] as String? ?? 'VinR Coach',
      dailyPacing: json['daily_pacing'] as String? ?? '10 mins / day',
      recentMessages: (json['recent_messages'] as List?)
              ?.map((e) => AiMessage.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      relevantMemories: (json['relevant_memories'] as List?)
              ?.map((e) => AiMemory.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      extraContext: (json['extra_context'] as Map?)?.cast<String, dynamic>() ?? const {},
    );
  }
}
