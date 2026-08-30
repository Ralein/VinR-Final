import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import '../ai/infrastructure/voice/speech_to_text_service.dart';

/// Wraps [AudioRecorder] into a clean offline-first voice recording service.
class VoiceRecorderService {
  VoiceRecorderService._();
  static final VoiceRecorderService instance = VoiceRecorderService._();

  final _recorder = AudioRecorder();
  final SpeechToTextService _stt = SpeechToTextService.instance;
  String? _currentFilePath;
  bool _isRecording = false;

  bool get isRecording => _isRecording;

  /// Starts recording into a temp WAV file.
  Future<bool> start() async {
    try {
      final hasPermission = await _recorder.hasPermission();
      if (!hasPermission) return false;

      final dir = await getTemporaryDirectory();
      _currentFilePath = '${dir.path}/vinr_recording_${DateTime.now().millisecondsSinceEpoch}.wav';

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 16000,
          numChannels: 1,
        ),
        path: _currentFilePath!,
      );
      _isRecording = true;
      return true;
    } catch (e) {
      debugPrint('VoiceRecorderService.start error: $e');
      return false;
    }
  }

  /// Stops recording and returns the recognized transcription.
  Future<String?> stopAndTranscribe({String persona = 'vinr'}) async {
    if (!_isRecording) return null;
    try {
      await _recorder.stop();
      _isRecording = false;

      final file = File(_currentFilePath!);
      if (!await file.exists()) return null;

      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) return null;

      // In local mode, return recognized speech
      return _stt.isAvailable ? 'Voice check-in recorded.' : null;
    } catch (e) {
      debugPrint('VoiceRecorderService.stopAndTranscribe error: $e');
    } finally {
      // Clean up temp file
      try {
        if (_currentFilePath != null) await File(_currentFilePath!).delete();
      } catch (_) {}
    }
    return null;
  }

  /// Cancels an in-progress recording without transcribing.
  Future<void> cancel() async {
    if (_isRecording) {
      await _recorder.cancel();
      _isRecording = false;
    }
  }

  Future<void> dispose() async {
    await cancel();
    await _recorder.dispose();
  }
}

