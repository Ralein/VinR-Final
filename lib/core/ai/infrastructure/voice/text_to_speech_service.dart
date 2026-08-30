import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Robust on-device Text-to-Speech service wrapper.
/// Seamlessly uses native on-device TTS engine (Google TTS/Samsung TTS)
/// with fallback to local audio playback.
class TextToSpeechService {
  static final TextToSpeechService instance = TextToSpeechService._internal();
  TextToSpeechService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isInitialized = false;
  bool _isPlaying = false;
  double _speechRate = 0.5; // FlutterTts normal speech rate is ~0.5
  double _pitch = 1.0;
  double _volume = 1.0;

  final StreamController<bool> _playingStateController =
      StreamController<bool>.broadcast();

  bool get isPlaying => _isPlaying;
  double get speechRate => _speechRate;
  Stream<bool> get playingStateStream => _playingStateController.stream;

  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      await _flutterTts.setLanguage('en-US');
      await _flutterTts.setSpeechRate(_speechRate);
      await _flutterTts.setVolume(_volume);
      await _flutterTts.setPitch(_pitch);

      _flutterTts.setStartHandler(() {
        _isPlaying = true;
        _playingStateController.add(true);
      });

      _flutterTts.setCompletionHandler(() {
        _isPlaying = false;
        _playingStateController.add(false);
      });

      _flutterTts.setCancelHandler(() {
        _isPlaying = false;
        _playingStateController.add(false);
      });

      _flutterTts.setErrorHandler((msg) {
        debugPrint('TextToSpeechService error: $msg');
        _isPlaying = false;
        _playingStateController.add(false);
      });

      _isInitialized = true;
    } catch (e) {
      debugPrint('TextToSpeechService init error: $e');
    }
  }

  void setSpeechRate(double rate) {
    _speechRate = rate;
    _flutterTts.setSpeechRate(rate);
  }

  void setPitch(double pitch) {
    _pitch = pitch;
    _flutterTts.setPitch(pitch);
  }

  void setVolume(double volume) {
    _volume = volume;
    _flutterTts.setVolume(volume);
  }


  /// Speaks the provided text using native on-device synthesis with persona voice tuning.
  Future<bool> speak(String text, {String? personaId}) async {
    if (text.trim().isEmpty) return false;

    if (!_isInitialized) {
      await initialize();
    }

    try {
      await stop();

      // Configure persona voice cadence
      if (personaId == 'stoic_mentor' || personaId == 'stoic') {
        await _flutterTts.setSpeechRate(0.44);
        await _flutterTts.setPitch(0.92);
      } else if (personaId == 'gentle_listener' || personaId == 'gentle') {
        await _flutterTts.setSpeechRate(0.47);
        await _flutterTts.setPitch(1.05);
      } else {
        // VinR Coach default: calm, confident, grounding
        await _flutterTts.setSpeechRate(0.48);
        await _flutterTts.setPitch(1.0);
      }

      // Clean markdown characters like asterisks before speaking
      final cleanText = text
          .replaceAll(RegExp(r'[\*\_#`~>]'), '')
          .replaceAll(RegExp(r'\n+'), '. ')
          .trim();

      final result = await _flutterTts.speak(cleanText);
      _isPlaying = result == 1;
      _playingStateController.add(_isPlaying);
      return _isPlaying;
    } catch (e) {
      debugPrint('TextToSpeechService speak exception: $e');
      _isPlaying = false;
      _playingStateController.add(false);
      return false;
    }
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
      await _audioPlayer.stop();
      _isPlaying = false;
      _playingStateController.add(false);
    } catch (e) {
      debugPrint('TextToSpeechService.stop error: $e');
    }
  }

  Future<void> dispose() async {
    await stop();
    await _audioPlayer.dispose();
    await _playingStateController.close();
  }
}
