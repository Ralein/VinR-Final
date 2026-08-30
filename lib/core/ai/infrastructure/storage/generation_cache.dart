import 'ai_database.dart';

/// Caches deterministic or daily AI generation results to prevent redundant inference.
class GenerationCache {
  final AiDatabase _db = AiDatabase.instance;
  static const String _cachePrefix = 'vinr_ai_cache_';

  Future<void> put(String key, Map<String, dynamic> data, {Duration ttl = const Duration(hours: 24)}) async {
    final entry = {
      'data': data,
      'expires_at': DateTime.now().add(ttl).toIso8601String(),
    };
    await _db.setJson('$_cachePrefix$key', entry);
  }

  Future<Map<String, dynamic>?> get(String key) async {
    final entry = await _db.getJson('$_cachePrefix$key');
    if (entry is Map) {
      final expiresAtStr = entry['expires_at'] as String?;
      if (expiresAtStr != null) {
        final expiresAt = DateTime.tryParse(expiresAtStr);
        if (expiresAt != null && DateTime.now().isAfter(expiresAt)) {
          await _db.remove('$_cachePrefix$key');
          return null;
        }
      }
      return (entry['data'] as Map?)?.cast<String, dynamic>();
    }
    return null;
  }

  Future<void> invalidate(String key) async {
    await _db.remove('$_cachePrefix$key');
  }

  Future<void> clearAll() async {
    await _db.clearNamespace(_cachePrefix);
  }
}
