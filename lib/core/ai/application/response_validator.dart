import 'dart:convert';
import '../domain/ai_task.dart';

/// Validates, parses, and sanitizes structured model responses.
class ResponseValidator {
  /// Extracts and validates JSON map from model generation.
  static Map<String, dynamic>? validateStructuredOutput(String rawOutput, AiTask task) {
    try {
      final jsonString = _extractJsonBlock(rawOutput);
      if (jsonString == null) return _fallbackForTask(task);

      final decoded = jsonDecode(jsonString);
      if (decoded is! Map<String, dynamic>) return _fallbackForTask(task);

      // Task-specific schema validation
      if (task == AiTask.glintGeneration || task == AiTask.glintQuote || task == AiTask.glintReflection) {
        if (!decoded.containsKey('title') || !decoded.containsKey('body')) {
          return _fallbackForTask(task);
        }
        return {
          'type': decoded['type'] ?? 'motivation',
          'title': (decoded['title'] as String).trim(),
          'body': (decoded['body'] as String).trim(),
          'quote': decoded['quote'] ?? 'Keep moving forward.',
          'author': decoded['author'] ?? 'VinR',
          'mood': decoded['mood'] ?? 'encouraging',
          'accent': decoded['accent'] ?? 'gold',
          'priority': (decoded['priority'] as num?)?.toInt() ?? 3,
          'action_label': decoded['action_label'] ?? 'View Streak',
        };
      }

      return decoded;
    } catch (_) {
      return _fallbackForTask(task);
    }
  }

  static String? _extractJsonBlock(String raw) {
    var trimmed = raw.trim();
    if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
      return trimmed;
    }

    final codeBlockMatch = RegExp(r'```(?:json)?\s*(\{[\s\S]*?\})\s*```').firstMatch(trimmed);
    if (codeBlockMatch != null) {
      return codeBlockMatch.group(1);
    }

    final startIdx = trimmed.indexOf('{');
    final endIdx = trimmed.lastIndexOf('}');
    if (startIdx != -1 && endIdx != -1 && endIdx > startIdx) {
      return trimmed.substring(startIdx, endIdx + 1);
    }

    return null;
  }

  static Map<String, dynamic> _fallbackForTask(AiTask task) {
    switch (task) {
      case AiTask.glintQuote:
        return {
          "type": "quote",
          "title": "Master Your Perception",
          "body": "Difficulties strengthen the mind, as labor does the body.",
          "quote": "Difficulties strengthen the mind.",
          "author": "Seneca",
          "mood": "stoic",
          "accent": "sapphire",
          "priority": 2,
        };
      case AiTask.glintReflection:
        return {
          "type": "reflection",
          "title": "Evening Gratitude",
          "body": "Pause and acknowledge today's quiet progress. Momentum is built in silent consistency.",
          "quote": "Small wins compound into big breakthroughs.",
          "author": "VinR",
          "mood": "calm",
          "accent": "emerald",
          "priority": 1,
        };
      case AiTask.glintGeneration:
      default:
        return {
          "type": "motivation",
          "title": "Stay the Course",
          "body": "Your 21-day winning streak is created one decision at a time. Own this moment.",
          "quote": "Consistency compounds.",
          "author": "VinR",
          "mood": "encouraging",
          "accent": "gold",
          "priority": 3,
          "action_label": "Check In",
        };
    }
  }
}
