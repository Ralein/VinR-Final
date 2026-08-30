import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/ai/application/ai_orchestrator.dart';
import '../../../core/ai/domain/ai_request.dart';
import '../../../core/ai/domain/ai_task.dart';
import '../../../core/ai/infrastructure/storage/generation_cache.dart';
import '../models/glint_card_model.dart';

class GlintState {
  final List<GlintCardModel> cards;
  final String selectedTopic;
  final bool isGenerating;
  final DateTime? lastGeneratedAt;
  final String? errorMessage;

  GlintState({
    this.cards = const [],
    this.selectedTopic = 'Stress Relief',
    this.isGenerating = false,
    this.lastGeneratedAt,
    this.errorMessage,
  });

  GlintState copyWith({
    List<GlintCardModel>? cards,
    String? selectedTopic,
    bool? isGenerating,
    DateTime? lastGeneratedAt,
    String? errorMessage,
  }) {
    return GlintState(
      cards: cards ?? this.cards,
      selectedTopic: selectedTopic ?? this.selectedTopic,
      isGenerating: isGenerating ?? this.isGenerating,
      lastGeneratedAt: lastGeneratedAt ?? this.lastGeneratedAt,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class GlintNotifier extends StateNotifier<GlintState> {
  final AiOrchestrator _orchestrator = AiOrchestrator.instance;
  final GenerationCache _cache = GenerationCache();

  GlintNotifier()
      : super(
          GlintState(
            cards: GlintCardModel.defaultFallbackCards,
          ),
        ) {
    loadGlintsForTopic('Stress Relief');
  }

  void setTopic(String topic) {
    state = state.copyWith(selectedTopic: topic);
    loadGlintsForTopic(topic);
  }

  Future<void> loadGlintsForTopic(String topic, {bool forceRefresh = false}) async {
    final todayStr = '${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}';
    final cacheKey = 'glint_${todayStr}_${topic.toLowerCase().replaceAll(' ', '_')}';

    // 1. Check local generation cache unless force refresh
    if (!forceRefresh) {
      final cached = await _cache.get(cacheKey);
      if (cached != null) {
        final card = GlintCardModel.fromJson(cached);
        _prependCard(card);
        return;
      }
    }

    // 2. Generate with AI Orchestrator
    state = state.copyWith(isGenerating: true);

    try {
      final request = AiRequest(
        task: AiTask.glintGeneration,
        userInput: 'Generate a rich daily growth card on the topic of $topic',
        persona: 'VinR Coach',
      );

      final response = await _orchestrator.execute(request);
      if (response.structuredData != null) {
        final data = response.structuredData!;
        final newCard = GlintCardModel(
          id: 'glint_${DateTime.now().millisecondsSinceEpoch}',
          type: data['type'] ?? 'motivation',
          title: data['title'] ?? 'Daily Insight',
          body: data['body'] ?? 'Small actions repeated daily build massive results.',
          quote: data['quote'],
          author: data['author'] ?? 'VinR',
          mood: data['mood'] ?? 'encouraging',
          accent: data['accent'] ?? 'gold',
          tag: topic,
          channel: 'VinR Intelligence',
          actionLabel: data['action_label'],
          createdAt: DateTime.now(),
        );

        // Cache result for 24 hours
        await _cache.put(cacheKey, newCard.toJson(), ttl: const Duration(hours: 24));
        _prependCard(newCard);
      }
    } catch (e) {
      // Keep existing fallback cards
      state = state.copyWith(errorMessage: 'Using offline insights');
    } finally {
      state = state.copyWith(
        isGenerating: false,
        lastGeneratedAt: DateTime.now(),
      );
    }
  }

  void _prependCard(GlintCardModel card) {
    final list = List<GlintCardModel>.from(state.cards);
    list.removeWhere((c) => c.title == card.title);
    list.insert(0, card);
    state = state.copyWith(cards: list);
  }

  void toggleFavorite(String cardId) {
    final list = state.cards.map((c) {
      if (c.id == cardId) {
        return c.copyWith(isFavorite: !c.isFavorite);
      }
      return c;
    }).toList();
    state = state.copyWith(cards: list);
  }
}

final glintProvider = StateNotifierProvider<GlintNotifier, GlintState>((ref) {
  return GlintNotifier();
});
