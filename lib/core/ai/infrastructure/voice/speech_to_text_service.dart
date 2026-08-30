import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Robust offline-first Speech-to-Text service wrapper.
class SpeechToTextService {
  static final SpeechToTextService instance = SpeechToTextService._internal();
  SpeechToTextService._internal();

  final stt.SpeechToText _stt = stt.SpeechToText();
  bool _isAvailable = false;
  bool _isListening = false;
  String? _lastError;

  bool get isAvailable => _isAvailable;
  bool get isListening => _isListening;
  String? get lastError => _lastError;

  Future<bool> initialize() async {
    try {
      _isAvailable = await _stt.initialize(
        onError: (val) {
          debugPrint('SpeechToText error: ${val.errorMsg}');
          _lastError = val.errorMsg;
          _isListening = false;
        },
        onStatus: (val) {
          debugPrint('SpeechToText status: $val');
          _isListening = val == 'listening';
        },
      );
      return _isAvailable;
    } catch (e) {
      debugPrint('SpeechToText init exception: $e');
      _isAvailable = false;
      _lastError = e.toString();
      return false;
    }
  }

  Future<bool> startListening({
    required void Function(String words, bool isFinal) onResult,
    Duration listenFor = const Duration(seconds: 45),
    Duration pauseFor = const Duration(seconds: 5),
  }) async {
    if (!_isAvailable) {
      final ok = await initialize();
      if (!ok) return false;
    }

    try {
      await _stt.listen(
        onResult: (result) {
          onResult(result.recognizedWords, result.finalResult);
        },
        listenOptions: stt.SpeechListenOptions(
          listenFor: listenFor,
          pauseFor: pauseFor,
          cancelOnError: true,
        ),
      );
      _isListening = true;
      return true;
    } catch (e) {
      debugPrint('SpeechToText startListening exception: $e');
      _isListening = false;
      return false;
    }
  }

  Future<void> stop() async {
    if (_isListening) {
      await _stt.stop();
      _isListening = false;
    }
  }

  Future<void> cancel() async {
    if (_isListening) {
      await _stt.cancel();
      _isListening = false;
    }
  }
}
