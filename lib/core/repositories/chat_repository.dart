import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../services/local_ai_service.dart';

class ChatRepository {
  final ApiService _apiService = ApiService();
  final LocalAIService _localAiService = LocalAIService.instance;

  Future<Map<String, dynamic>?> sendMessage(
    String text, {
    bool voiceEnabled = false,
    String persona = 'vinr',
  }) async {
    try {
      if (ApiService.isConfigured) {
        final response = await _apiService.dio.post(
          'chat/message',
          data: {
            'text': text,
            'voice_enabled': voiceEnabled,
            'persona': persona,
          },
        );
        if (response.statusCode == 200 && response.data != null) {
          return response.data as Map<String, dynamic>;
        }
      }
    } on DioException catch (e) {
      debugPrint('ChatRepository remote send error: ${e.message}');
    } catch (e) {
      debugPrint('ChatRepository remote send error: $e');
    }

    // Local AI fallback abstraction for offline-first architecture
    final aiReply = await _localAiService.generateResponse(
      prompt: text,
      persona: persona,
    );

    return {
      'user_message': {
        'id': 'msg_usr_${DateTime.now().millisecondsSinceEpoch}',
        'role': 'user',
        'content': text,
        'created_at': DateTime.now().toIso8601String(),
      },
      'buddy_message': {
        'id': 'msg_ai_${DateTime.now().millisecondsSinceEpoch}',
        'role': 'assistant',
        'content': aiReply,
        'persona': persona,
        'created_at': DateTime.now().toIso8601String(),
      }
    };
  }

  Future<List<dynamic>?> getHistory() async {
    try {
      if (ApiService.isConfigured) {
        final response = await _apiService.dio.get('chat/history');
        if (response.statusCode == 200 && response.data != null) {
          return response.data['messages'] as List<dynamic>?;
        }
      }
    } catch (e) {
      debugPrint('ChatRepository getHistory error: $e');
    }
    return [];
  }

  Future<String?> generateTts(String text, {String persona = 'vinr'}) async {
    try {
      if (ApiService.isConfigured) {
        final response = await _apiService.dio.post(
          'chat/tts',
          data: {
            'text': text,
            'persona': persona,
          },
        );
        if (response.statusCode == 200 && response.data != null) {
          return response.data['audio_url'] as String?;
        }
      }
    } catch (e) {
      debugPrint('ChatRepository generateTts error: $e');
    }
    return null;
  }
}
