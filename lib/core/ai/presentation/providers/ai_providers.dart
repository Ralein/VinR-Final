import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/memory_service.dart';
import '../../domain/ai_memory.dart';
import '../../infrastructure/runtime/inference_config.dart';
import '../../infrastructure/runtime/local_llm_runtime_factory.dart';
import '../../infrastructure/runtime/model_manager.dart';

/// State of the on-device AI model subsystem.
class AiModelState {
  final ModelState state;
  final double progress;
  final bool isInstalled;
  final String modelName;
  final int modelSizeBytes;
  final String? errorMessage;

  const AiModelState({
    required this.state,
    this.progress = 0.0,
    this.isInstalled = false,
    this.modelName = 'VinR Compact Growth Intelligence v1',
    this.modelSizeBytes = 524288000,
    this.errorMessage,
  });

  bool get isReady => state == ModelState.ready || state == ModelState.busy;
  bool get isDownloading => state == ModelState.downloading;
  bool get isVerifying => state == ModelState.verifying;
  bool get isLoading => state == ModelState.loading;
}

class AiModelNotifier extends StateNotifier<AiModelState> {
  final ModelManager _manager = ModelManager.instance;

  AiModelNotifier()
      : super(
          AiModelState(
            state: ModelManager.instance.state,
            progress: ModelManager.instance.downloadProgress,
            isInstalled: ModelManager.instance.isModelInstalled,
            modelSizeBytes: ModelManager.instance.metadata.sizeBytes,
          ),
        ) {
    _init();
  }

  Future<void> _init() async {
    _manager.stateStream.listen((state) {
      this.state = AiModelState(
        state: state,
        progress: _manager.downloadProgress,
        isInstalled: _manager.isModelInstalled,
        modelSizeBytes: _manager.metadata.sizeBytes,
        errorMessage: _manager.errorMessage,
      );
    });

    _manager.progressStream.listen((progress) {
      state = AiModelState(
        state: _manager.state,
        progress: progress,
        isInstalled: _manager.isModelInstalled,
        modelSizeBytes: _manager.metadata.sizeBytes,
        errorMessage: _manager.errorMessage,
      );
    });

    await _manager.checkModelStatus();
  }

  Future<void> checkStatus() async {
    await _manager.checkModelStatus();
  }

  Future<void> downloadModel() async {
    await _manager.downloadAndInstallModel();
  }

  Future<void> deleteModel() async {
    await _manager.deleteModel();
  }

  Future<void> loadModel() async {
    await _manager.ensureModelLoaded();
  }

  Future<void> unloadModel() async {
    await _manager.unloadModel();
  }
}

final aiModelProvider = StateNotifierProvider<AiModelNotifier, AiModelState>((ref) {
  return AiModelNotifier();
});

/// State notifier managing inspectable on-device user memories.
class AiMemoryNotifier extends StateNotifier<List<AiMemory>> {
  final MemoryService _service = MemoryService.instance;

  AiMemoryNotifier() : super([]) {
    loadMemories();
  }

  Future<void> loadMemories() async {
    state = await _service.getMemories();
  }

  Future<void> deleteMemory(String id) async {
    await _service.deleteMemory(id);
    await loadMemories();
  }

  Future<void> clearAll() async {
    await _service.clearAll();
    state = [];
  }
}

final aiMemoryProvider = StateNotifierProvider<AiMemoryNotifier, List<AiMemory>>((ref) {
  return AiMemoryNotifier();
});

/// Provider supplying current runtime telemetry stats.
final aiStatsProvider = FutureProvider<AiRuntimeStats>((ref) async {
  final runtime = LocalLlmRuntimeFactory.getRuntime();
  return runtime.stats();
});
