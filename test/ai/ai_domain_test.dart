import 'package:flutter_test/flutter_test.dart';
import 'package:vinr_app/core/ai/domain/ai_task.dart';
import 'package:vinr_app/core/ai/domain/ai_message.dart';
import 'package:vinr_app/core/ai/domain/ai_memory.dart';
import 'package:vinr_app/core/ai/domain/ai_context.dart';
import 'package:vinr_app/core/ai/domain/ai_request.dart';
import 'package:vinr_app/core/ai/domain/ai_response.dart';
import 'package:vinr_app/core/ai/domain/ai_error.dart';
import 'package:vinr_app/core/ai/domain/ai_capability.dart';

void main() {
  group('AI Domain Contracts Tests', () {
    test('AiTask mapping works correctly', () {
      expect(AiTask.fromId('conversation'), AiTask.conversation);
      expect(AiTask.fromId('glint_generation').isStructured, true);
      expect(AiTask.fromId('unknown_task'), AiTask.conversation);
    });

    test('AiMessage serialization roundtrip', () {
      final msg = AiMessage.user(
        content: 'Hello VinR Coach',
        conversationId: 'conv_1',
        metadata: {'tag': 'greeting'},
      );

      final json = msg.toJson();
      final restored = AiMessage.fromJson(json);

      expect(restored.id, msg.id);
      expect(restored.role, AiMessageRole.user);
      expect(restored.content, 'Hello VinR Coach');
      expect(restored.conversationId, 'conv_1');
      expect(restored.metadata['tag'], 'greeting');
    });

    test('AiMemory creation and access tracking', () {
      final mem = AiMemory.create(
        category: AiMemoryCategory.goals,
        key: 'primary_goal',
        value: 'Build 21-day streak',
      );

      expect(mem.category, AiMemoryCategory.goals);
      expect(mem.accessCount, 1);

      final accessed = mem.markAccessed();
      expect(accessed.accessCount, 2);
    });

    test('AiContext token estimation', () {
      final context = AiContext(
        persona: 'VinR Coach',
        activeGoals: ['Complete workout', 'Meditate 10 mins'],
        recentMessages: [
          AiMessage.user(content: 'Let us start', conversationId: 'c1'),
        ],
      );

      final tokens = context.estimateTokenCount();
      expect(tokens, greaterThan(0));
    });

    test('AiError hierarchy and toString', () {
      const error = ModelMissingError();
      expect(error.code, 'MODEL_MISSING');
      expect(error.toString(), contains('MODEL_MISSING'));

      const corrupt = ModelCorruptError();
      expect(corrupt.code, 'MODEL_CORRUPT');
    });

    test('AiCapabilityCall serialization', () {
      final call = AiCapabilityCall(
        type: AiCapabilityType.getStreak,
        arguments: {'userId': 'user_123'},
        callId: 'call_1',
      );

      final json = call.toJson();
      final restored = AiCapabilityCall.fromJson(json);
      expect(restored.type, AiCapabilityType.getStreak);
      expect(restored.callId, 'call_1');
      expect(restored.arguments['userId'], 'user_123');
    });
  });
}
