import 'dart:async';
import '../../application/ai_orchestrator.dart';
import '../../domain/ai_request.dart';
import '../../domain/ai_task.dart';
import 'speech_to_text_service.dart';
import 'text_to_speech_service.dart';

enum VoiceSessionState {
  idle,
  requestingPermission,
  listening,
  transcribing,
  thinking,
  speaking,
  error,
}

/// Coordinates the end-to-end voice loop: STT -> On-Device AI -> Spoken Reply.
class VoiceSessionController {
  static final VoiceSessionController instance = VoiceSessionController._internal();
  VoiceSessionController._internal();

  final SpeechToTextService _stt = SpeechToTextService.instance;
  final TextToSpeechService _tts = TextToSpeechService.instance;
  final AiOrchestrator _orchestrator = AiOrchestrator.instance;

  VoiceSessionState _state = VoiceSessionState.idle;
  String _recognizedText = '';
  String? _errorCode;
  String? _errorMessage;

  final _stateController = StreamController<VoiceSessionState>.broadcast();

  VoiceSessionState get state => _state;
  String get recognizedText => _recognizedText;
  String? get errorCode => _errorCode;
  String? get errorMessage => _errorMessage;

  Stream<VoiceSessionState> get stateStream => _stateController.stream;

  void _setState(VoiceSessionState newState) {
    _state = newState;
    _stateController.add(newState);
  }

  /// Starts listening to the user microphone.
  Future<bool> startListening({String persona = 'VinR Coach'}) async {
    _setState(VoiceSessionState.requestingPermission);
    final isReady = await _stt.initialize();
    if (!isReady) {
      _errorCode = 'VOICE_PERMISSION_DENIED';
      _errorMessage = 'Microphone permission denied or speech engine unavailable.';
      _setState(VoiceSessionState.error);
      return false;
    }

    _recognizedText = '';
    _setState(VoiceSessionState.listening);

    return _stt.startListening(
      onResult: (words, isFinal) {
        _recognizedText = words;
        if (isFinal && words.isNotEmpty) {
          _processSpokenPrompt(words, persona);
        }
      },
    );
  }

  /// Stops listening and triggers AI generation for the recognized utterance.
  Future<String?> stopAndProcess({String persona = 'VinR Coach'}) async {
    await _stt.stop();
    if (_recognizedText.trim().isEmpty) {
      _setState(VoiceSessionState.idle);
      return null;
    }

    return _processSpokenPrompt(_recognizedText, persona);
  }

  Future<String?> _processSpokenPrompt(String prompt, String persona) async {
    _setState(VoiceSessionState.thinking);

    try {
      final request = AiRequest(
        task: AiTask.voiceResponse,
        userInput: prompt,
        persona: persona,
      );

      final response = await _orchestrator.execute(request);
      _setState(VoiceSessionState.speaking);

      // Simulation/local audio output state
      await Future.delayed(const Duration(milliseconds: 600));
      _setState(VoiceSessionState.idle);

      return response.text;
    } catch (e) {
      _errorCode = 'VOICE_AI_FAILED';
      _errorMessage = 'Failed to generate voice response: $e';
      _setState(VoiceSessionState.error);
      return null;
    }
  }

  Future<void> cancel() async {
    await _stt.cancel();
    await _tts.stop();
    _setState(VoiceSessionState.idle);
  }

  void dispose() {
    _stt.cancel();
    _tts.stop();
    _stateController.close();
  }
}
