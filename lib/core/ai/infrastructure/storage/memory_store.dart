import '../../domain/ai_memory.dart';
import 'ai_database.dart';

/// On-device storage for durable user personalization memories.
class MemoryStore {
  final AiDatabase _db = AiDatabase.instance;
  static const String _storageKey = 'vinr_ai_user_memories';

  Future<List<AiMemory>> getAllMemories() async {
    final raw = await _db.getJson(_storageKey);
    if (raw is List) {
      return raw.map((e) => AiMemory.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    }
    return [];
  }

  Future<void> saveMemory(AiMemory memory) async {
    final list = await getAllMemories();
    final existingIndex = list.indexWhere((m) => m.key == memory.key && m.category == memory.category);
    if (existingIndex != -1) {
      list[existingIndex] = memory;
    } else {
      list.add(memory);
    }
    await _db.setJson(_storageKey, list.map((m) => m.toJson()).toList());
  }

  Future<void> deleteMemory(String id) async {
    final list = await getAllMemories();
    list.removeWhere((m) => m.id == id);
    await _db.setJson(_storageKey, list.map((m) => m.toJson()).toList());
  }

  Future<void> clearAllMemories() async {
    await _db.remove(_storageKey);
  }
}
