/// Immutable metadata descriptor for a downloadable/on-device local quantized LLM model.
class ModelMetadata {
  final String modelId;
  final String name;
  final String version;
  final String format;
  final String quantization;
  final int sizeBytes;
  final String sha256;
  final String runtimeCompatibility;
  final int minRamMb;
  final String? localFilePath;
  final bool isInstalled;

  const ModelMetadata({
    required this.modelId,
    required this.name,
    required this.version,
    required this.format,
    required this.quantization,
    required this.sizeBytes,
    required this.sha256,
    required this.runtimeCompatibility,
    this.minRamMb = 1536,
    this.localFilePath,
    this.isInstalled = false,
  });

  /// Standard VinR default 500MB quantized mobile model metadata
  static const defaultModel = ModelMetadata(
    modelId: 'vinr-growth-instruct-q4km',
    name: 'VinR Compact Growth Intelligence v1',
    version: '1.0.0',
    format: 'gguf',
    quantization: 'q4_k_m',
    sizeBytes: 524288000, // ~500 MB
    sha256: 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
    runtimeCompatibility: 'mobile-arm64-v8a',
    minRamMb: 1500,
    isInstalled: true,
  );

  ModelMetadata copyWith({
    String? modelId,
    String? name,
    String? version,
    String? format,
    String? quantization,
    int? sizeBytes,
    String? sha256,
    String? runtimeCompatibility,
    int? minRamMb,
    String? localFilePath,
    bool? isInstalled,
  }) {
    return ModelMetadata(
      modelId: modelId ?? this.modelId,
      name: name ?? this.name,
      version: version ?? this.version,
      format: format ?? this.format,
      quantization: quantization ?? this.quantization,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      sha256: sha256 ?? this.sha256,
      runtimeCompatibility: runtimeCompatibility ?? this.runtimeCompatibility,
      minRamMb: minRamMb ?? this.minRamMb,
      localFilePath: localFilePath ?? this.localFilePath,
      isInstalled: isInstalled ?? this.isInstalled,
    );
  }

  Map<String, dynamic> toJson() => {
        'model_id': modelId,
        'name': name,
        'version': version,
        'format': format,
        'quantization': quantization,
        'size_bytes': sizeBytes,
        'sha256': sha256,
        'runtime_compatibility': runtimeCompatibility,
        'min_ram_mb': minRamMb,
        'local_file_path': localFilePath,
        'is_installed': isInstalled,
      };

  factory ModelMetadata.fromJson(Map<String, dynamic> json) {
    return ModelMetadata(
      modelId: json['model_id'] as String? ?? 'vinr-default-model',
      name: json['name'] as String? ?? 'VinR Local Model',
      version: json['version'] as String? ?? '1.0.0',
      format: json['format'] as String? ?? 'gguf',
      quantization: json['quantization'] as String? ?? 'q4_k_m',
      sizeBytes: (json['size_bytes'] as num?)?.toInt() ?? 524288000,
      sha256: json['sha256'] as String? ?? '',
      runtimeCompatibility: json['runtime_compatibility'] as String? ?? 'arm64',
      minRamMb: (json['min_ram_mb'] as num?)?.toInt() ?? 1500,
      localFilePath: json['local_file_path'] as String?,
      isInstalled: json['is_installed'] as bool? ?? false,
    );
  }
}
