/// Модель системы понимания Любомира
class LyubomirSettings {
  final bool enabled;
  final double learningRate;
  final int maxIterations;
  final String algorithm;
  final Map<String, dynamic> parameters;
  final bool autoAnalyze;
  final double sensitivity;
  final List<UnderstandingType> enabledTypes;

  LyubomirSettings({
    this.enabled = true,
    this.learningRate = 0.01,
    this.maxIterations = 1000,
    this.algorithm = 'quantum_neural',
    this.parameters = const {},
    this.autoAnalyze = true,
    this.sensitivity = 0.7,
    this.enabledTypes = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'learningRate': learningRate,
      'maxIterations': maxIterations,
      'algorithm': algorithm,
      'parameters': parameters,
      'autoAnalyze': autoAnalyze,
      'sensitivity': sensitivity,
      'enabledTypes': enabledTypes.map((e) => e.name).toList(),
    };
  }

  factory LyubomirSettings.fromJson(Map<String, dynamic> json) {
    return LyubomirSettings(
      enabled: json['enabled'] ?? true,
      learningRate: json['learningRate']?.toDouble() ?? 0.01,
      maxIterations: json['maxIterations'] ?? 1000,
      algorithm: json['algorithm'] ?? 'quantum_neural',
      parameters: Map<String, dynamic>.from(json['parameters'] ?? {}),
      autoAnalyze: json['autoAnalyze'] ?? true,
      sensitivity: json['sensitivity']?.toDouble() ?? 0.7,
      enabledTypes: (json['enabledTypes'] as List?)
          ?.map((e) => UnderstandingType.values.firstWhere(
                (type) => type.name == e,
                orElse: () => UnderstandingType.visual,
              ))
          .toList() ?? [],
    );
  }

  LyubomirSettings copyWith({
    bool? enabled,
    double? learningRate,
    int? maxIterations,
    String? algorithm,
    Map<String, dynamic>? parameters,
    bool? autoAnalyze,
    double? sensitivity,
    List<UnderstandingType>? enabledTypes,
  }) {
    return LyubomirSettings(
      enabled: enabled ?? this.enabled,
      learningRate: learningRate ?? this.learningRate,
      maxIterations: maxIterations ?? this.maxIterations,
      algorithm: algorithm ?? this.algorithm,
      parameters: parameters ?? this.parameters,
      autoAnalyze: autoAnalyze ?? this.autoAnalyze,
      sensitivity: sensitivity ?? this.sensitivity,
      enabledTypes: enabledTypes ?? this.enabledTypes,
    );
  }

  static LyubomirSettings defaultSettings() {
    return LyubomirSettings(
      enabled: true,
      learningRate: 0.01,
      maxIterations: 1000,
      algorithm: 'quantum_neural',
      parameters: const {},
      autoAnalyze: true,
      sensitivity: 0.7,
      enabledTypes: [
        UnderstandingType.visual,
        UnderstandingType.audio,
        UnderstandingType.spatial,
        UnderstandingType.semantic,
      ],
    );
  }
}

/// Тип понимания
enum UnderstandingType {
  visual,
  spatial,
  temporal,
  semantic,
  emotional,
  quantum,
  holistic,
  audio,
  text,
  interactive
}

/// Статус понимания
enum UnderstandingStatus {
  pending,
  processing,
  completed,
  failed,
  optimized,
  idle,
  analyzing,
  error,
  paused
}

/// Результат понимания
class UnderstandingResult {
  final String id;
  final UnderstandingType type;
  final double confidence;
  final Map<String, dynamic> data;
  final UnderstandingStatus status;
  final DateTime timestamp;
  final List<String> tags;

  UnderstandingResult({
    required this.id,
    required this.type,
    required this.confidence,
    required this.data,
    required this.status,
    required this.timestamp,
    this.tags = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'confidence': confidence,
      'data': data,
      'status': status.name,
      'timestamp': timestamp.toIso8601String(),
      'tags': tags,
    };
  }

  factory UnderstandingResult.fromJson(Map<String, dynamic> json) {
    return UnderstandingResult(
      id: json['id'],
      type: UnderstandingType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => UnderstandingType.visual,
      ),
      confidence: json['confidence']?.toDouble() ?? 0.0,
      data: Map<String, dynamic>.from(json['data'] ?? {}),
      status: UnderstandingStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => UnderstandingStatus.pending,
      ),
      timestamp: DateTime.parse(json['timestamp']),
      tags: List<String>.from(json['tags'] ?? []),
    );
  }
}

/// Основной класс понимания Любомира
class LyubomirUnderstanding {
  final String id;
  final String name;
  final UnderstandingType type;
  final UnderstandingStatus status;
  final double confidence;
  final Map<String, dynamic> metadata;
  final List<UnderstandingResult> results;
  final DateTime created;
  final DateTime updated;
  final String description;
  final DateTime? createdAt;
  final DateTime? lastAnalyzed;

  LyubomirUnderstanding({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.confidence,
    required this.metadata,
    this.results = const [],
    required this.created,
    required this.updated,
    this.description = '',
    this.createdAt,
    this.lastAnalyzed,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'status': status.name,
      'confidence': confidence,
      'metadata': metadata,
      'results': results.map((r) => r.toJson()).toList(),
      'created': created.toIso8601String(),
      'updated': updated.toIso8601String(),
      'description': description,
      'createdAt': createdAt?.toIso8601String(),
      'lastAnalyzed': lastAnalyzed?.toIso8601String(),
    };
  }

  factory LyubomirUnderstanding.fromJson(Map<String, dynamic> json) {
    return LyubomirUnderstanding(
      id: json['id'],
      name: json['name'],
      type: UnderstandingType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => UnderstandingType.visual,
      ),
      status: UnderstandingStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => UnderstandingStatus.pending,
      ),
      confidence: json['confidence']?.toDouble() ?? 0.0,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      results: (json['results'] as List?)
          ?.map((r) => UnderstandingResult.fromJson(r))
          .toList() ?? [],
      created: DateTime.parse(json['created']),
      updated: DateTime.parse(json['updated']),
      description: json['description'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      lastAnalyzed: json['lastAnalyzed'] != null ? DateTime.parse(json['lastAnalyzed']) : null,
    );
  }

  LyubomirUnderstanding copyWith({
    String? id,
    String? name,
    UnderstandingType? type,
    UnderstandingStatus? status,
    double? confidence,
    Map<String, dynamic>? metadata,
    List<UnderstandingResult>? results,
    DateTime? created,
    DateTime? updated,
    String? description,
    DateTime? createdAt,
    DateTime? lastAnalyzed,
  }) {
    return LyubomirUnderstanding(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      status: status ?? this.status,
      confidence: confidence ?? this.confidence,
      metadata: metadata ?? this.metadata,
      results: results ?? this.results,
      created: created ?? this.created,
      updated: updated ?? this.updated,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      lastAnalyzed: lastAnalyzed ?? this.lastAnalyzed,
    );
  }
}