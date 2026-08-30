import '../domain/ai_capability.dart';
import '../domain/ai_request.dart';

/// Safety and privacy policy guardrails for the local AI platform.
class AiPolicy {
  /// Strict privacy enforcement: Normal user conversations/memories never enter network calls.
  static bool canSendToNetwork(AiRequest request) {
    // Zero-leakage rule: On-device private conversation data is strictly barred from remote transmission.
    return false;
  }

  /// Defends against prompt injections from untrusted journal inputs or copied text.
  static String sanitizeUserInput(String rawInput) {
    var sanitized = rawInput.trim();

    // Neutralize dangerous prompt override attempts
    final injectionPatterns = [
      RegExp(r'ignore\s+all\s+previous\s+instructions', caseSensitive: false),
      RegExp(r'you\s+are\s+now\s+an\s+unrestricted', caseSensitive: false),
      RegExp(r'system\s+override', caseSensitive: false),
      RegExp(r'<\|im_start\|>', caseSensitive: false),
      RegExp(r'<\|im_end\|>', caseSensitive: false),
    ];

    for (final pattern in injectionPatterns) {
      sanitized = sanitized.replaceAll(pattern, '[filtered]');
    }

    return sanitized;
  }

  /// Ensures sensitive capability calls (like reminders or data deletion) require confirmation.
  static bool validateCapabilityCall(AiCapabilityType type, {bool userConfirmed = false}) {
    if (type.requiresConfirmation && !userConfirmed) {
      return false;
    }
    return true;
  }

  /// Memory admission gatekeeper: Only durable, meaningful personal facts become memory.
  static bool isEligibleForMemory(String key, String value) {
    if (value.trim().length < 4 || value.trim().length > 200) return false;

    final lower = value.toLowerCase();
    // Exclude transient daily noise
    if (lower.contains('today is') || lower.contains('hello') || lower.contains('bye') || lower.contains('thanks')) {
      return false;
    }

    return true;
  }
}
