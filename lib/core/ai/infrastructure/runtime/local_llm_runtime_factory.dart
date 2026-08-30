import 'local_llm_runtime.dart';
import 'mock_local_llm_runtime.dart';

/// Factory providing singleton access to the active local LLM runtime.
class LocalLlmRuntimeFactory {
  static LocalLlmRuntime? _instance;

  static LocalLlmRuntime getRuntime({bool forceSimulator = false}) {
    if (_instance == null || forceSimulator) {
      _instance = MockLocalLlmRuntime();
    }
    return _instance!;
  }

  static void setCustomRuntime(LocalLlmRuntime customRuntime) {
    _instance = customRuntime;
  }
}
