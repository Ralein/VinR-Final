/// Structured domain model for a Glint card.
class GlintCardModel {
  final String id;
  final String type;
  final String title;
  final String body;
  final String? quote;
  final String? author;
  final String? mood;
  final String accent;
  final String tag;
  final String channel;
  final String? actionLabel;
  final DateTime createdAt;
  final bool isFavorite;

  const GlintCardModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.quote,
    this.author = 'VinR',
    this.mood = 'encouraging',
    this.accent = 'gold',
    required this.tag,
    this.channel = 'VinR Intelligence',
    this.actionLabel,
    required this.createdAt,
    this.isFavorite = false,
  });

  GlintCardModel copyWith({
    String? id,
    String? type,
    String? title,
    String? body,
    String? quote,
    String? author,
    String? mood,
    String? accent,
    String? tag,
    String? channel,
    String? actionLabel,
    DateTime? createdAt,
    bool? isFavorite,
  }) {
    return GlintCardModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      quote: quote ?? this.quote,
      author: author ?? this.author,
      mood: mood ?? this.mood,
      accent: accent ?? this.accent,
      tag: tag ?? this.tag,
      channel: channel ?? this.channel,
      actionLabel: actionLabel ?? this.actionLabel,
      createdAt: createdAt ?? this.createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'title': title,
        'body': body,
        'quote': quote,
        'author': author,
        'mood': mood,
        'accent': accent,
        'tag': tag,
        'channel': channel,
        'action_label': actionLabel,
        'created_at': createdAt.toIso8601String(),
        'is_favorite': isFavorite,
      };

  factory GlintCardModel.fromJson(Map<String, dynamic> json) {
    return GlintCardModel(
      id: json['id'] as String? ?? 'glint_${DateTime.now().millisecondsSinceEpoch}',
      type: json['type'] as String? ?? 'motivation',
      title: json['title'] as String? ?? 'Daily Insight',
      body: json['body'] as String? ?? '',
      quote: json['quote'] as String?,
      author: json['author'] as String? ?? 'VinR',
      mood: json['mood'] as String? ?? 'encouraging',
      accent: json['accent'] as String? ?? 'gold',
      tag: json['tag'] as String? ?? 'Growth',
      channel: json['channel'] as String? ?? 'VinR Intelligence',
      actionLabel: json['action_label'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      isFavorite: json['is_favorite'] as bool? ?? false,
    );
  }

  /// Curated, verified offline fallback cards when local LLM is uninitialized.
  static final List<GlintCardModel> defaultFallbackCards = [
    GlintCardModel(
      id: 'fallback_1',
      type: 'motivation',
      title: 'How 4-7-8 Breathing Resets Your Vagus Nerve in 60 Seconds',
      body: 'Extended exhalations activate the parasympathetic nervous system, instantly slowing heart rate and resetting cortisol levels.',
      quote: 'Control your breath, control your biology.',
      author: 'VinR Science',
      mood: 'calm',
      accent: 'emerald',
      tag: 'Stress Relief',
      channel: 'VinR Science',
      actionLabel: 'Try Breathing',
      createdAt: DateTime.now(),
    ),
    GlintCardModel(
      id: 'fallback_2',
      type: 'streak',
      title: 'Overcoming the 3-Day Habit Slump on Your 21-Day Winning Streak',
      body: 'Dopamine drops after initial excitement. Reframe Day 3 as the true baseline of mental fortitude and keep moving forward.',
      quote: 'Consistency compounds into destiny.',
      author: 'VinR Coach',
      mood: 'encouraging',
      accent: 'gold',
      tag: 'Discipline',
      channel: 'Growth Partner',
      actionLabel: 'Check Streak',
      createdAt: DateTime.now(),
    ),
    GlintCardModel(
      id: 'fallback_3',
      type: 'quote',
      title: 'Stoic Mindset for Emotional Fortitude and Inner Calm',
      body: 'You cannot control the storm outside, but you have absolute jurisdiction over your internal response.',
      quote: 'You have power over your mind, not outside events.',
      author: 'Marcus Aurelius',
      mood: 'stoic',
      accent: 'sapphire',
      tag: 'Mindfulness',
      channel: 'Stoic Mind',
      createdAt: DateTime.now(),
    ),
  ];
}
