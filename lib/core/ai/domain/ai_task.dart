/// Represents all discrete task families supported by the VinR Local AI layer.
enum AiTask {
  conversation('conversation', isStructured: false),
  glintGeneration('glint_generation', isStructured: true),
  glintQuote('glint_quote', isStructured: true),
  glintReflection('glint_reflection', isStructured: true),
  dailyCheckin('daily_checkin', isStructured: false),
  goalSupport('goal_support', isStructured: false),
  habitSupport('habit_support', isStructured: false),
  journalAssist('journal_assist', isStructured: false),
  planning('planning', isStructured: true),
  summarization('summarization', isStructured: false),
  rewrite('rewrite', isStructured: false),
  suggestion('suggestion', isStructured: false),
  voiceResponse('voice_response', isStructured: false);

  final String id;
  final bool isStructured;

  const AiTask(this.id, {required this.isStructured});

  static AiTask fromId(String id) {
    return AiTask.values.firstWhere(
      (e) => e.id == id,
      orElse: () => AiTask.conversation,
    );
  }
}
