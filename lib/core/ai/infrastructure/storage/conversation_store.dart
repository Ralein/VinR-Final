import '../../domain/ai_message.dart';
import 'ai_database.dart';

/// Manages on-device persistence for chat threads and messages.
class ConversationStore {
  final AiDatabase _db = AiDatabase.instance;
  static const String _messagePrefix = 'vinr_ai_messages_';
  static const String _metaPrefix = 'vinr_ai_conv_';

  Future<void> saveMessage(AiMessage message) async {
    final list = await getMessages(message.conversationId);
    list.add(message);
    await _db.setJson(
      '$_messagePrefix${message.conversationId}',
      list.map((m) => m.toJson()).toList(),
    );
  }

  Future<void> saveMessages(String conversationId, List<AiMessage> messages) async {
    await _db.setJson(
      '$_messagePrefix$conversationId',
      messages.map((m) => m.toJson()).toList(),
    );
  }

  Future<List<AiMessage>> getMessages(String conversationId) async {
    final raw = await _db.getJson('$_messagePrefix$conversationId');
    if (raw is List) {
      return raw.map((e) => AiMessage.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    }
    return [];
  }

  Future<void> deleteConversation(String conversationId) async {
    await _db.remove('$_messagePrefix$conversationId');
    await _db.remove('$_metaPrefix$conversationId');
  }

  Future<void> clearAllConversations() async {
    await _db.clearNamespace(_messagePrefix);
    await _db.clearNamespace(_metaPrefix);
  }
}
