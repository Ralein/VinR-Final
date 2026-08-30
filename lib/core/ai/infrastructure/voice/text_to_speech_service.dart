import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Service managing offline spoken audio playback and speech synthesis.
class TextToSpeechService {
  static final TextToSpeechService instance = TextToSpeechService._internal();
  TextToSpeechService._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  double _speechRate = 1.0;

  bool get isPlaying => _isPlaying;
  double get speechRate => _speechRate;

  void setSpeechRate(double rate) {
    _speechRate = rate;
  }

  Future<void> stop() async {
    try {
      await _player.stop();
      _isPlaying = false;
    } catch (e) {
      debugPrint('TextToSpeechService.stop error: $e');
    }
  }

  Future<void> dispose() async {
    await stop();
    await _player.dispose();
  }
}
