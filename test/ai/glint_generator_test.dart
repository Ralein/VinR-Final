import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vinr_app/core/ai/infrastructure/storage/generation_cache.dart';
import 'package:vinr_app/features/glint/providers/glint_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Glint Structured Cards & Cache Tests', () {
    test('Fallback cards are present by default', () {
      final notifier = GlintNotifier();
      expect(notifier.state.cards.isNotEmpty, true);
      expect(notifier.state.cards.any((c) => c.tag == 'Stress Relief'), true);
    });

    test('GenerationCache stores and retrieves with TTL', () async {
      final cache = GenerationCache();
      const testKey = 'test_glint_key';
      final testData = {
        'title': 'Test Fortitude',
        'body': 'Stay consistent daily.',
        'accent': 'gold',
      };

      await cache.put(testKey, testData, ttl: const Duration(hours: 1));
      final retrieved = await cache.get(testKey);

      expect(retrieved, isNotNull);
      expect(retrieved!['title'], 'Test Fortitude');
      expect(retrieved['accent'], 'gold');
    });

    test('Card favorites toggling', () {
      final notifier = GlintNotifier();
      final firstCardId = notifier.state.cards.first.id;

      expect(notifier.state.cards.first.isFavorite, false);
      notifier.toggleFavorite(firstCardId);
      expect(notifier.state.cards.first.isFavorite, true);
    });
  });
}
