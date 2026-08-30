/// Categories for on-device personal memories.
enum AiMemoryCategory {
  preferences('preferences'),
  goals('goals'),
  habits('habits'),
  communicationStyle('communication_style'),
  facts('facts'),
  glintPreferences('glint_preferences');

  final String value;
  const AiMemoryCategory(this.value);

  static AiMemoryCategory fromValue(String value) {
    return AiMemoryCategory.values.firstWhere(
      (e) => e.value.toLowerCase() == value.toLowerCase(),
      orElse: () => AiMemoryCategory.facts,
    );
  }
}

/// Durable on-device user personalization fact or preference.
class AiMemory {
  final String id;
  final AiMemoryCategory category;
  final String key;
  final String value;
  final double confidence;
  final DateTime createdAt;
  final DateTime lastAccessedAt;
  final int accessCount;

  const AiMemory({
    required this.id,
    required this.category,
    required this.key,
    required this.value,
    this.confidence = 1.0,
    required this.createdAt,
    required this.lastAccessedAt,
    this.accessCount = 0,
  });

  factory AiMemory.create({
    required AiMemoryCategory category,
    required String key,
    required String value,
    double confidence = 1.0,
  }) {
    final now = DateTime.now();
    return AiMemory(
      id: 'mem_${now.millisecondsSinceEpoch}_${key.hashCode.abs()}',
      category: category,
      key: key,
      value: value,
      confidence: confidence,
      createdAt: now,
      lastAccessedAt: now,
      accessCount: 1,
    );
  }

  AiMemory markAccessed() {
    return AiMemory(
      id: id,
      category: category,
      key: key,
      value: value,
      confidence: confidence,
      createdAt: createdAt,
      lastAccessedAt: DateTime.now(),
      accessCount: accessCount + 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category.value,
        'key': key,
        'value': value,
        'confidence': confidence,
        'created_at': createdAt.toIso8601String(),
        'last_accessed_at': lastAccessedAt.toIso8601String(),
        'access_count': accessCount,
      };

  factory AiMemory.fromJson(Map<String, dynamic> json) {
    return AiMemory(
      id: json['id'] as String? ?? 'mem_${DateTime.now().millisecondsSinceEpoch}',
      category: AiMemoryCategory.fromValue(json['category'] as String? ?? 'facts'),
      key: json['key'] as String? ?? '',
      value: json['value'] as String? ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 1.0,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      lastAccessedAt: DateTime.tryParse(json['last_accessed_at'] as String? ?? '') ?? DateTime.now(),
      accessCount: (json['access_count'] as num?)?.toInt() ?? 0,
    );
  }
}
