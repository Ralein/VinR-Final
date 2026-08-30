import '../domain/ai_memory.dart';
import '../infrastructure/storage/memory_store.dart';
import 'ai_policy.dart';

/// Application service managing durable personal memory lifecycle and retrieval.
class MemoryService {
  static final MemoryService instance = MemoryService._internal();
  MemoryService._internal();

  final MemoryStore _store = MemoryStore();
  static const int maxTotalMemories = 50;

  Future<List<AiMemory>> getMemories() async {
    return _store.getAllMemories();
  }

  Future<void> remember({
    required AiMemoryCategory category,
    required String key,
    required String value,
    double confidence = 1.0,
  }) async {
    if (!AiPolicy.isEligibleForMemory(key, value)) return;

    final current = await _store.getAllMemories();
    if (current.length >= maxTotalMemories) {
      // Evict lowest confidence / oldest memory
      current.sort((a, b) => a.lastAccessedAt.compareTo(b.lastAccessedAt));
      if (current.isNotEmpty) {
        await _store.deleteMemory(current.first.id);
      }
    }

    final memory = AiMemory.create(
      category: category,
      key: key,
      value: value,
      confidence: confidence,
    );
    await _store.saveMemory(memory);
  }

  /// Extracts durable facts from user prompt automatically if clear preferences are shared.
  Future<void> extractFromInput(String input) async {
    final lower = input.toLowerCase();

    if (lower.contains('my goal is') || lower.contains('i want to achieve')) {
      final goal = input.replaceAll(RegExp(r'(?i)my goal is|i want to achieve'), '').trim();
      if (goal.isNotEmpty) {
        await remember(category: AiMemoryCategory.goals, key: 'active_goal', value: goal);
      }
    } else if (lower.contains('i prefer') || lower.contains('call me')) {
      final pref = input.replaceAll(RegExp(r'(?i)i prefer|call me'), '').trim();
      if (pref.isNotEmpty) {
        await remember(category: AiMemoryCategory.preferences, key: 'user_preference', value: pref);
      }
    }
  }

  Future<void> deleteMemory(String id) => _store.deleteMemory(id);

  Future<void> clearAll() => _store.clearAllMemories();
}
