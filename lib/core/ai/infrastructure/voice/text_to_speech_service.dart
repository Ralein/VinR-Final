import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Robust on-device Text-to-Speech service wrapper.
/// Seamlessly utilizes native on-device TTS hardware engines (Google TTS / Samsung TTS)
/// with adaptive pitch, speech rate, and audio focus management.
class TextToSpeechService {
  static final TextToSpeechService instance = TextToSpeechService._internal();
  TextToSpeechService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isInitialized = false;
  bool _isPlaying = false;
  double _speechRate = 0.5;
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
      if (Platform.isIOS) {
        await _flutterTts.setSharedInstance(true);
        await _flutterTts.setIosAudioCategory(
          IosTextToSpeechAudioCategory.playback,
          [
            IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
            IosTextToSpeechAudioCategoryOptions.allowBluetooth,
            IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
          ],
        );
      }

      await _flutterTts.setLanguage('en-US');
      await _flutterTts.setSpeechRate(_speechRate);
      await _flutterTts.setVolume(_volume);
      await _flutterTts.setPitch(_pitch);
      await _flutterTts.awaitSpeakCompletion(true);

      _flutterTts.setStartHandler(() {
        debugPrint('TextToSpeechService: TTS speech started');
        _isPlaying = true;
        _playingStateController.add(true);
      });

      _flutterTts.setCompletionHandler(() {
        debugPrint('TextToSpeechService: TTS speech completed');
        _isPlaying = false;
        _playingStateController.add(false);
      });

      _flutterTts.setCancelHandler(() {
        debugPrint('TextToSpeechService: TTS speech cancelled');
        _isPlaying = false;
        _playingStateController.add(false);
      });

      _flutterTts.setErrorHandler((msg) {
        debugPrint('TextToSpeechService error: $msg');
        _isPlaying = false;
        _playingStateController.add(false);
      });

      // Query available engines on Android
      if (Platform.isAndroid) {
        try {
          final engines = await _flutterTts.getEngines;
          debugPrint('TextToSpeechService: Available TTS engines: $engines');
        } catch (e) {
          debugPrint('TextToSpeechService getEngines notice: $e');
        }
      }

      _isInitialized = true;
      debugPrint('TextToSpeechService: Successfully initialized native TTS engine');
    } catch (e) {
      debugPrint('TextToSpeechService init exception: $e');
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
      // Ensure any previous speech is halted
      await _flutterTts.stop();
      await _audioPlayer.stop();

      // Configure persona voice cadence
      final p = personaId?.toLowerCase() ?? '';
      if (p.contains('stoic')) {
        await _flutterTts.setSpeechRate(0.44);
        await _flutterTts.setPitch(0.92);
      } else if (p.contains('listener') || p.contains('gentle')) {
        await _flutterTts.setSpeechRate(0.46);
        await _flutterTts.setPitch(1.05);
      } else {
        // VinR Coach default: calm, confident, energetic
        await _flutterTts.setSpeechRate(0.48);
        await _flutterTts.setPitch(1.0);
      }

      await _flutterTts.setVolume(1.0);

      // Clean markdown characters, asterisks, bullet points, headers, emojis
      final cleanText = text
          .replaceAll(RegExp(r'[\*\_#`~>]'), '')
          .replaceAll('•', '')
          .replaceAll(RegExp(r'\n+'), '. ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();

      debugPrint('TextToSpeechService.speak: speaking "$cleanText" (persona=$personaId)');

      final dynamic result = await _flutterTts.speak(cleanText);
      debugPrint('TextToSpeechService.speak result: $result');

      final isSuccess = result == 1 || result == true || result == '1';
      _isPlaying = isSuccess;
      _playingStateController.add(isSuccess);
      return isSuccess;
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
