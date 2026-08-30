import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vinr_app/core/ai/domain/ai_request.dart';
import 'package:vinr_app/core/ai/infrastructure/storage/conversation_store.dart';
import 'package:vinr_app/core/repositories/chat_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Local Chat Streaming & Persistence Tests', () {
    test('Streams tokens and saves completed response locally', () async {
      final repo = ChatRepository();
      final store = ConversationStore();
      const testConvId = 'test_conv_stream';

      await store.deleteConversation(testConvId);

      final tokenBuffer = StringBuffer();
      final stream = repo.streamMessage(
        'I am ready for Day 5 of my streak!',
        persona: 'VinR Coach',
        conversationId: testConvId,
        streakDays: 5,
      );

      await for (final token in stream) {
        tokenBuffer.write(token.text);
      }

      final generatedText = tokenBuffer.toString().trim();
      expect(generatedText.isNotEmpty, true);

      // Verify messages were persisted in ConversationStore
      final messages = await store.getMessages(testConvId);
      expect(messages.length, 2); // User message + Assistant message
      expect(messages.first.content, 'I am ready for Day 5 of my streak!');
      expect(messages.last.content, generatedText);
    });

    test('Cancellation interrupts generation early', () async {
      final repo = ChatRepository();
      const testConvId = 'test_conv_cancel';
      final cancellationToken = AiCancellationToken();

      final stream = repo.streamMessage(
        'Give me a long explanation of stoicism and mental resilience',
        conversationId: testConvId,
        cancellationToken: cancellationToken,
      );

      int count = 0;
      await for (final _ in stream) {
        count++;
        if (count == 3) {
          cancellationToken.cancel();
        }
      }

      expect(cancellationToken.isCancelled, true);
    });
  });
}
