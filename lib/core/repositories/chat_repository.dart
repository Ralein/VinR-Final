import '../ai/application/ai_orchestrator.dart';
import '../ai/application/context_builder.dart';
import '../ai/application/memory_service.dart';
import '../ai/domain/ai_message.dart';
import '../ai/domain/ai_request.dart';
import '../ai/domain/ai_response.dart';
import '../ai/domain/ai_task.dart';
import '../ai/infrastructure/storage/conversation_store.dart';

/// Repository managing chat messages, streaming tokens, and local offline persistence.
class ChatRepository {
  final AiOrchestrator _orchestrator = AiOrchestrator.instance;
  final ConversationStore _store = ConversationStore();
  final MemoryService _memoryService = MemoryService.instance;

  /// Streams tokens from local model runtime while auto-recording to conversation store on completion.
  Stream<AiToken> streamMessage(
    String text, {
    String persona = 'VinR Coach',
    String conversationId = 'default_conversation',
    int? streakDays,
    String? currentMood,
    AiCancellationToken? cancellationToken,
  }) async* {
    // 1. Load history & memories for context assembly
    final history = await _store.getMessages(conversationId);
    final memories = await _memoryService.getMemories();

    final userMessage = AiMessage.user(
      content: text,
      conversationId: conversationId,
    );
    await _store.saveMessage(userMessage);

    // 2. Extract durable personal memory candidates
    await _memoryService.extractFromInput(text);

    // 3. Build token-budgeted prompt context
    final context = ContextBuilder.build(
      currentScreen: 'BuddyChatScreen',
      streakDays: streakDays ?? 0,
      currentMood: currentMood,
      persona: persona,
      fullHistory: history,
      availableMemories: memories,
    );


    final request = AiRequest(
      task: AiTask.conversation,
      userInput: text,
      conversationId: conversationId,
      persona: persona,
      context: context,
      cancellationToken: cancellationToken,
    );

    final fullResponseBuffer = StringBuffer();
    final stream = _orchestrator.stream(request);

    await for (final token in stream) {
      fullResponseBuffer.write(token.text);
      yield token;
      if (token.isFinished) break;
    }

    // 4. Atomic final persistence write
    final assistantMessage = AiMessage.assistant(
      content: fullResponseBuffer.toString().trim(),
      conversationId: conversationId,
      persona: persona,
    );
    await _store.saveMessage(assistantMessage);
  }

  /// Sends a message and returns legacy-compatible response structure.
  Future<Map<String, dynamic>?> sendMessage(
    String text, {
    bool voiceEnabled = false,
    String persona = 'VinR Coach',
    String conversationId = 'default_conversation',
  }) async {
    final history = await _store.getMessages(conversationId);
    final memories = await _memoryService.getMemories();

    final userMessage = AiMessage.user(
      content: text,
      conversationId: conversationId,
    );
    await _store.saveMessage(userMessage);
    await _memoryService.extractFromInput(text);

    final context = ContextBuilder.build(
      currentScreen: 'BuddyChatScreen',
      persona: persona,
      fullHistory: history,
      availableMemories: memories,
    );

    final request = AiRequest(
      task: voiceEnabled ? AiTask.voiceResponse : AiTask.conversation,
      userInput: text,
      conversationId: conversationId,
      persona: persona,
      context: context,
    );

    final response = await _orchestrator.execute(request);

    final assistantMessage = AiMessage.assistant(
      content: response.text,
      conversationId: conversationId,
      persona: persona,
    );
    await _store.saveMessage(assistantMessage);

    return {
      'user_message': userMessage.toJson(),
      'buddy_message': assistantMessage.toJson(),
    };
  }

  /// Loads local on-device message history.
  Future<List<dynamic>?> getHistory([String conversationId = 'default_conversation']) async {
    final list = await _store.getMessages(conversationId);
    return list.map((m) => m.toJson()).toList();
  }

  /// Generates local speech synthesis or simulated TTS audio.
  Future<String?> generateTts(String text, {String persona = 'VinR Coach'}) async {
    return null;
  }

  /// Clears stored chat history.
  Future<void> clearHistory([String conversationId = 'default_conversation']) async {
    await _store.deleteConversation(conversationId);
  }
}

