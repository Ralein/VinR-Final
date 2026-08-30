/// Controlled capabilities that the AI can invoke deterministically.
enum AiCapabilityType {
  getUserContext('get_user_context', requiresConfirmation: false),
  getGoals('get_goals', requiresConfirmation: false),
  getHabits('get_habits', requiresConfirmation: false),
  getStreak('get_streak', requiresConfirmation: false),
  getRecentActivity('get_recent_activity', requiresConfirmation: false),
  createGlint('create_glint', requiresConfirmation: false),
  saveMemory('save_memory', requiresConfirmation: false),
  createReminder('create_reminder', requiresConfirmation: true),
  deleteData('delete_data', requiresConfirmation: true);

  final String name;
  final bool requiresConfirmation;

  const AiCapabilityType(this.name, {required this.requiresConfirmation});

  static AiCapabilityType fromName(String name) {
    return AiCapabilityType.values.firstWhere(
      (e) => e.name == name,
      orElse: () => AiCapabilityType.getUserContext,
    );
  }
}

/// A declared capability invocation request with typed arguments.
class AiCapabilityCall {
  final AiCapabilityType type;
  final Map<String, dynamic> arguments;
  final String callId;

  const AiCapabilityCall({
    required this.type,
    this.arguments = const {},
    required this.callId,
  });

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'arguments': arguments,
        'call_id': callId,
      };

  factory AiCapabilityCall.fromJson(Map<String, dynamic> json) {
    return AiCapabilityCall(
      type: AiCapabilityType.fromName(json['type'] as String? ?? ''),
      arguments: (json['arguments'] as Map?)?.cast<String, dynamic>() ?? {},
      callId: json['call_id'] as String? ?? 'call_${DateTime.now().millisecondsSinceEpoch}',
    );
  }
}

/// Result returned from a capability execution.
class AiCapabilityResult {
  final String callId;
  final bool isSuccess;
  final Map<String, dynamic> data;
  final String? errorMessage;

  const AiCapabilityResult({
    required this.callId,
    required this.isSuccess,
    this.data = const {},
    this.errorMessage,
  });

  Map<String, dynamic> toJson() => {
        'call_id': callId,
        'is_success': isSuccess,
        'data': data,
        'error_message': errorMessage,
      };
}
