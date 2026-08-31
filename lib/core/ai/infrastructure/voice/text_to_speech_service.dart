import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Robust on-device Text-to-Speech service wrapper.
/// Seamlessly utilizes native on-device TTS hardware engines (Google TTS / Samsung TTS)
/// with natural prosody, voice selection, and distinctive persona vocal personalities.
class TextToSpeechService {
  static final TextToSpeechService instance = TextToSpeechService._internal();
  TextToSpeechService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isInitialized = false;
  bool _isPlaying = false;
  double _speechRate = 0.50;
  double _pitch = 1.0;
  double _volume = 1.0;
  List<dynamic> _availableVoices = [];

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

      // Query available voices on device for natural voice tuning
      try {
        final voices = await _flutterTts.getVoices;
        if (voices is List) {
          _availableVoices = voices;
          debugPrint('TextToSpeechService: Loaded ${_availableVoices.length} device voice profiles.');
        }
      } catch (e) {
        debugPrint('TextToSpeechService voice query notice: $e');
      }

      _isInitialized = true;
      debugPrint('TextToSpeechService: Native TTS engine initialized.');
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

  /// Speaks the provided text using native on-device synthesis with natural prosody and persona vocal tuning.
  Future<bool> speak(String text, {String? personaId}) async {
    if (text.trim().isEmpty) return false;

    if (!_isInitialized) {
      await initialize();
    }

    try {
      await _flutterTts.stop();
      await _audioPlayer.stop();

      // Configure distinctive persona vocal tone and pacing
      final p = personaId?.toLowerCase() ?? '';
      if (p.contains('stoic')) {
        // Stoic Mentor: Deep, measured, deliberate, authoritative
        await _flutterTts.setSpeechRate(0.43);
        await _flutterTts.setPitch(0.88);
        _applyPersonaVoice(gender: 'male', locale: 'en-US');
      } else if (p.contains('listener') || p.contains('gentle')) {
        // Gentle Listener: Soft, calming, serene, empathetic
        await _flutterTts.setSpeechRate(0.46);
        await _flutterTts.setPitch(1.06);
        _applyPersonaVoice(gender: 'female', locale: 'en-US');
      } else {
        // VinR Coach: Grounded, confident, motivating baritone
        await _flutterTts.setSpeechRate(0.49);
        await _flutterTts.setPitch(0.96);
        _applyPersonaVoice(gender: 'male', locale: 'en-US');
      }

      await _flutterTts.setVolume(1.0);

      // Clean text and introduce natural vocal prosody punctuation
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

  void _applyPersonaVoice({required String gender, required String locale}) {
    if (_availableVoices.isEmpty) return;
    try {
      for (final voice in _availableVoices) {
        if (voice is Map) {
          final name = (voice['name'] ?? '').toString().toLowerCase();
          final loc = (voice['locale'] ?? '').toString();
          if (loc.startsWith('en') && (name.contains(gender) || name.contains('natural') || name.contains('neural'))) {
            _flutterTts.setVoice({'name': voice['name'], 'locale': voice['locale']});
            break;
          }
        }
      }
    } catch (_) {}
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
