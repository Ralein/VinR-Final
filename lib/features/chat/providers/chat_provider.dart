import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/ai/domain/ai_request.dart';
import '../../../core/repositories/chat_repository.dart';
import '../models/chat_message_model.dart';

class ChatState {
  final List<ChatMessageModel> messages;
  final String persona;
  final bool isGenerating;
  final String? streamingText;

  ChatState({
    this.messages = const [],
    this.persona = 'VinR Coach',
    this.isGenerating = false,
    this.streamingText,
  });

  ChatState copyWith({
    List<ChatMessageModel>? messages,
    String? persona,
    bool? isGenerating,
    String? streamingText,
    bool clearStreamingText = false,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      persona: persona ?? this.persona,
      isGenerating: isGenerating ?? this.isGenerating,
      streamingText: clearStreamingText ? null : (streamingText ?? this.streamingText),
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final ChatRepository _repository = ChatRepository();
  AiCancellationToken? _currentCancellation;

  ChatNotifier()
      : super(
          ChatState(
            messages: [
              ChatMessageModel(
                id: 'm_welcome',
                text: "Welcome back champion! I'm VinR, your private growth partner. Ready to strengthen Day 5 of your winning streak?",
                sender: MessageSender.ai,
                timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
              ),
            ],
          ),
        ) {
    _initHistory();
  }

  Future<void> _initHistory() async {
    final history = await _repository.getHistory();
    if (history != null && history.isNotEmpty) {
      final loadedMessages = history.map((item) {
        final role = item['role'] as String? ?? 'assistant';
        return ChatMessageModel(
          id: item['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
          text: item['content'] as String? ?? '',
          sender: role == 'user' ? MessageSender.user : MessageSender.ai,
          timestamp: DateTime.tryParse(item['created_at'] as String? ?? '') ?? DateTime.now(),
          audioUri: (item['metadata'] as Map?)?['audio_url'] as String?,
        );
      }).toList();

      if (loadedMessages.isNotEmpty) {
        state = state.copyWith(messages: loadedMessages);
      }
    }
  }

  void setPersona(String persona) {
    state = state.copyWith(persona: persona);
  }

  /// Sends a message and streams the assistant response token-by-token.
  Future<void> sendMessage(String text, {bool isVoice = false}) async {
    if (state.isGenerating) {
      cancelGeneration();
    }

    final userMsg = ChatMessageModel(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      text: text,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
      isVoice: isVoice,
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isGenerating: true,
      streamingText: '',
    );

    _currentCancellation = AiCancellationToken();

    try {
      final stream = _repository.streamMessage(
        text,
        persona: state.persona,
        cancellationToken: _currentCancellation,
      );

      final tokenBuffer = StringBuffer();
      DateTime lastUiUpdate = DateTime.now();

      await for (final token in stream) {
        tokenBuffer.write(token.text);

        // Coalesce rapid streaming token UI updates to ~30fps to avoid UI isolate jank
        final now = DateTime.now();
        if (token.isFinished || now.difference(lastUiUpdate).inMilliseconds >= 33) {
          lastUiUpdate = now;
          state = state.copyWith(
            streamingText: tokenBuffer.toString(),
          );
        }

        if (token.isFinished) break;
      }

      final finalAiText = tokenBuffer.toString().trim();
      final aiMsg = ChatMessageModel(
        id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
        text: finalAiText.isNotEmpty ? finalAiText : 'Every small win counts. Keep moving forward!',
        sender: MessageSender.ai,
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, aiMsg],
        isGenerating: false,
        clearStreamingText: true,
      );
    } catch (e) {
      final fallbackMsg = ChatMessageModel(
        id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
        text: "I'm right here with you. Let's take a deep breath and keep our winning momentum steady.",
        sender: MessageSender.ai,
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, fallbackMsg],
        isGenerating: false,
        clearStreamingText: true,
      );
    } finally {
      _currentCancellation = null;
    }
  }

  /// Cancels in-progress AI generation immediately.
  void cancelGeneration() {
    _currentCancellation?.cancel();
    _currentCancellation = null;
    if (state.isGenerating) {
      if (state.streamingText != null && state.streamingText!.trim().isNotEmpty) {
        final partialMsg = ChatMessageModel(
          id: 'ai_cancelled_${DateTime.now().millisecondsSinceEpoch}',
          text: '${state.streamingText!.trim()} [Stopped]',
          sender: MessageSender.ai,
          timestamp: DateTime.now(),
        );
        state = state.copyWith(
          messages: [...state.messages, partialMsg],
          isGenerating: false,
          clearStreamingText: true,
        );
      } else {
        state = state.copyWith(
          isGenerating: false,
          clearStreamingText: true,
        );
      }
    }
  }

  /// Regenerates the last assistant response.
  Future<void> regenerateLastMessage() async {
    if (state.messages.isEmpty) return;

    // Find last user message
    final lastUserMsgIndex = state.messages.lastIndexWhere((m) => m.sender == MessageSender.user);
    if (lastUserMsgIndex == -1) return;

    final userPrompt = state.messages[lastUserMsgIndex].text;
    // Trim conversation back to user message
    final trimmed = state.messages.sublist(0, lastUserMsgIndex);
    state = state.copyWith(messages: trimmed);

    await sendMessage(userPrompt);
  }

  void addSystemNotification(String notificationText) {
    final sysMsg = ChatMessageModel(
      id: 'sys_${DateTime.now().millisecondsSinceEpoch}',
      text: notificationText,
      sender: MessageSender.system,
      timestamp: DateTime.now(),
    );
    state = state.copyWith(messages: [...state.messages, sysMsg]);
  }

  Future<void> clearMessages() async {
    await _repository.clearHistory();
    state = state.copyWith(messages: []);
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier();
});
