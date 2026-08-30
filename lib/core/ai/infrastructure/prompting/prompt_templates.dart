import '../../domain/ai_context.dart';
import '../../domain/ai_request.dart';

/// Centralized prompt templates with strict persona formatting and boundary delimiters.
class PromptTemplates {
  static const systemPersonalityBase = '''
You are VinR, an empowering, private on-device wellness & growth partner.
Principles:
1. Be uplifting, concise, and grounded in practical action.
2. NEVER pretend to be a medical clinician or give diagnostic advice.
3. Keep user data strictly private and respect their personal growth journey.
4. Adapt seamlessly to the chosen persona tone without breaking character.
''';

  static String buildSystemPrompt(String persona) {
    String personaGuidance = '';
    final p = persona.toLowerCase();

    if (p.contains('stoic')) {
      personaGuidance = 'Tone: Stoic Guardian. Resilient, philosophical, focused on virtue, self-mastery, and what is within voluntary control.';
    } else if (p.contains('zen') || p.contains('listener')) {
      personaGuidance = 'Tone: Zen Master. Gentle, mindful, calm, non-judgmental, emphasizing breath, grounding, and self-compassion.';
    } else if (p.contains('solar') || p.contains('spark')) {
      personaGuidance = 'Tone: Solar Spark. High energy, enthusiastic, celebrating momentum and bold daily action.';
    } else {
      personaGuidance = 'Tone: VinR Coach. Inspiring, disciplined, empathetic, focused on building the 21-day winning streak.';
    }

    return '$systemPersonalityBase\n$personaGuidance';
  }

  static String buildConversationPrompt(AiRequest request) {
    final buffer = StringBuffer();
    buffer.writeln(buildSystemPrompt(request.persona));
    buffer.writeln();

    if (request.context != null) {
      _appendContext(buffer, request.context!);
    }

    buffer.writeln('=== CURRENT INTERACTION ===');
    buffer.writeln('USER: ${request.userInput}');
    buffer.writeln('ASSISTANT:');
    return buffer.toString();
  }

  static String buildGlintPrompt(AiRequest request) {
    final buffer = StringBuffer();
    buffer.writeln('You are the VinR Glint Card Intelligence.');
    buffer.writeln('TASK: Generate a single JSON object for a daily wellness/motivation card.');
    buffer.writeln('STRICT OUTPUT FORMAT: Output ONLY valid JSON matching this schema:');
    buffer.writeln('''
{
  "type": "motivation | quote | reflection | streak | challenge",
  "title": "Short punchy title (under 35 chars)",
  "body": "Inspiring message (under 140 chars)",
  "quote": "Memorable insight line",
  "author": "VinR or attributed philosopher if historical",
  "mood": "encouraging | calm | stoic | energetic",
  "accent": "gold | emerald | sapphire | ruby",
  "priority": 1-5,
  "action_label": "Optional CTA button text"
}
''');

    if (request.context != null) {
      _appendContext(buffer, request.context!);
    }

    buffer.writeln('USER TOPIC/STATE: ${request.userInput.isNotEmpty ? request.userInput : "Daily Motivation"}');
    buffer.writeln('JSON:');
    return buffer.toString();
  }

  static String buildPlanningPrompt(AiRequest request) {
    final buffer = StringBuffer();
    buffer.writeln('You are the VinR Action Planner.');
    buffer.writeln('TASK: Break down the user objective into 3 actionable, bite-sized micro-steps.');
    buffer.writeln('STRICT OUTPUT FORMAT: Output ONLY valid JSON:');
    buffer.writeln('''
{
  "goal": "Goal title",
  "steps": [
    {"step": 1, "action": "Action description", "duration_minutes": 5},
    {"step": 2, "action": "Action description", "duration_minutes": 20},
    {"step": 3, "action": "Action description", "duration_minutes": 5}
  ],
  "milestone": "Target completion marker"
}
''');
    buffer.writeln('USER GOAL: ${request.userInput}');
    buffer.writeln('JSON:');
    return buffer.toString();
  }

  static String buildJournalAssistPrompt(AiRequest request) {
    final buffer = StringBuffer();
    buffer.writeln(buildSystemPrompt(request.persona));
    buffer.writeln('TASK: Provide an empathetic, non-judgmental 2-sentence reflection on the user\'s journal entry. Prompt them with one constructive self-discovery question.');
    if (request.context != null) {
      _appendContext(buffer, request.context!);
    }
    buffer.writeln('=== USER JOURNAL ENTRY ===');
    buffer.writeln(request.userInput);
    buffer.writeln('=== REFLECTION ===');
    return buffer.toString();
  }

  static void _appendContext(StringBuffer buffer, AiContext context) {
    buffer.writeln('=== USER LOCAL CONTEXT ===');
    if (context.streakDays != null) {
      buffer.writeln('Winning Streak: Day ${context.streakDays} of 21');
    }
    if (context.currentMood != null) {
      buffer.writeln('Current Mood: ${context.currentMood}');
    }
    if (context.activeGoals.isNotEmpty) {
      buffer.writeln('Active Goals: ${context.activeGoals.join(", ")}');
    }
    if (context.activeHabits.isNotEmpty) {
      buffer.writeln('Active Habits: ${context.activeHabits.join(", ")}');
    }
    if (context.relevantMemories.isNotEmpty) {
      buffer.writeln('Relevant Memories:');
      for (final mem in context.relevantMemories) {
        buffer.writeln('- ${mem.key}: ${mem.value}');
      }
    }
    if (context.recentMessages.isNotEmpty) {
      buffer.writeln('Recent Conversation History:');
      for (final m in context.recentMessages) {
        buffer.writeln('${m.role.value.toUpperCase()}: ${m.content}');
      }
    }
    buffer.writeln();
  }
}
