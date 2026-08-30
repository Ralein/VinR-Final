import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vinr_app/core/ai/domain/ai_memory.dart';
import 'package:vinr_app/core/ai/application/memory_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Local Memory Service Tests', () {
    test('Stores and retrieves user memories correctly', () async {
      final service = MemoryService.instance;
      await service.clearAll();

      await service.remember(
        category: AiMemoryCategory.goals,
        key: 'active_goal',
        value: 'Build 21-day winning streak',
      );

      final memories = await service.getMemories();
      expect(memories.length, 1);
      expect(memories.first.category, AiMemoryCategory.goals);
      expect(memories.first.value, 'Build 21-day winning streak');
    });

    test('Extracts goal from user conversation prompt', () async {
      final service = MemoryService.instance;
      await service.clearAll();

      await service.extractFromInput('My goal is to meditate 10 minutes every morning');

      final memories = await service.getMemories();
      expect(memories.isNotEmpty, true);
      expect(memories.first.category, AiMemoryCategory.goals);
      expect(memories.first.value.toLowerCase(), contains('meditate 10 minutes'));
    });

    test('Deletes individual memory and clears all', () async {
      final service = MemoryService.instance;
      await service.clearAll();

      await service.remember(
        category: AiMemoryCategory.preferences,
        key: 'pacing',
        value: '10 mins daily',
      );

      var list = await service.getMemories();
      expect(list.length, 1);

      await service.deleteMemory(list.first.id);
      list = await service.getMemories();
      expect(list.isEmpty, true);
    });
  });
}
