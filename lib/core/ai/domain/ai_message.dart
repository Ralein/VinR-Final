/// Roles that an AI message can belong to.
enum AiMessageRole {
  user('user'),
  assistant('assistant'),
  system('system');

  final String value;
  const AiMessageRole(this.value);

  static AiMessageRole fromValue(String value) {
    return AiMessageRole.values.firstWhere(
      (e) => e.value.toLowerCase() == value.toLowerCase(),
      orElse: () => AiMessageRole.user,
    );
  }
}

/// Unified domain message representation for chat, context, and storage.
class AiMessage {
  final String id;
  final String conversationId;
  final AiMessageRole role;
  final String content;
  final DateTime createdAt;
  final int tokenEstimate;
  final Map<String, dynamic> metadata;

  const AiMessage({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    required this.createdAt,
    this.tokenEstimate = 0,
    this.metadata = const {},
  });

  factory AiMessage.user({
    required String content,
    required String conversationId,
    String? id,
    Map<String, dynamic>? metadata,
  }) {
    return AiMessage(
      id: id ?? 'msg_usr_${DateTime.now().millisecondsSinceEpoch}',
      conversationId: conversationId,
      role: AiMessageRole.user,
      content: content,
      createdAt: DateTime.now(),
      tokenEstimate: (content.length / 4).ceil(),
      metadata: metadata ?? {},
    );
  }

  factory AiMessage.assistant({
    required String content,
    required String conversationId,
    String? id,
    String? persona,
    String? audioUri,
    Map<String, dynamic>? metadata,
  }) {
    final meta = Map<String, dynamic>.from(metadata ?? {});
    if (persona != null) meta['persona'] = persona;
    if (audioUri != null) meta['audio_url'] = audioUri;

    return AiMessage(
      id: id ?? 'msg_ai_${DateTime.now().millisecondsSinceEpoch}',
      conversationId: conversationId,
      role: AiMessageRole.assistant,
      content: content,
      createdAt: DateTime.now(),
      tokenEstimate: (content.length / 4).ceil(),
      metadata: meta,
    );
  }

  factory AiMessage.system({
    required String content,
    required String conversationId,
    String? id,
  }) {
    return AiMessage(
      id: id ?? 'msg_sys_${DateTime.now().millisecondsSinceEpoch}',
      conversationId: conversationId,
      role: AiMessageRole.system,
      content: content,
      createdAt: DateTime.now(),
      tokenEstimate: (content.length / 4).ceil(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'conversation_id': conversationId,
        'role': role.value,
        'content': content,
        'created_at': createdAt.toIso8601String(),
        'token_estimate': tokenEstimate,
        'metadata': metadata,
      };

  factory AiMessage.fromJson(Map<String, dynamic> json) {
    return AiMessage(
      id: json['id'] as String? ?? 'msg_${DateTime.now().millisecondsSinceEpoch}',
      conversationId: json['conversation_id'] as String? ?? 'default',
      role: AiMessageRole.fromValue(json['role'] as String? ?? 'user'),
      content: json['content'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      tokenEstimate: (json['token_estimate'] as num?)?.toInt() ?? 0,
      metadata: (json['metadata'] as Map?)?.cast<String, dynamic>() ?? {},
    );
  }

  AiMessage copyWith({
    String? id,
    String? conversationId,
    AiMessageRole? role,
    String? content,
    DateTime? createdAt,
    int? tokenEstimate,
    Map<String, dynamic>? metadata,
  }) {
    return AiMessage(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      role: role ?? this.role,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      tokenEstimate: tokenEstimate ?? this.tokenEstimate,
      metadata: metadata ?? this.metadata,
    );
  }
}
