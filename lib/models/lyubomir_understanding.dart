/// Модель данных для понимания Любомира
/// 
/// Любомир - это система понимания контента, которая анализирует
/// и интерпретирует различные типы медиа для создания интерактивного опыта
class LyubomirUnderstanding {
  final String id;
  final String name;
  final String description;
  final UnderstandingType type;
  final UnderstandingStatus status;
  final DateTime createdAt;
  final DateTime? lastAnalyzed;
  final Map<String, dynamic> metadata;
  final List<UnderstandingResult> results;

  const LyubomirUnderstanding({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.status,
    required this.createdAt,
    this.lastAnalyzed,
    required this.metadata,
    required this.results,
  });

  factory LyubomirUnderstanding.fromJson(Map<String, dynamic> json) {
    return LyubomirUnderstanding(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: UnderstandingType.fromString(json['type'] as String),
      status: UnderstandingStatus.fromString(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastAnalyzed: json['lastAnalyzed'] != null 
          ? DateTime.parse(json['lastAnalyzed'] as String) 
          : null,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map),
      results: (json['results'] as List)
          .map((result) => UnderstandingResult.fromJson(result as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.toString(),
      'status': status.toString(),
      'createdAt': createdAt.toIso8601String(),
      'lastAnalyzed': lastAnalyzed?.toIso8601String(),
      'metadata': metadata,
      'results': results.map((result) => result.toJson()).toList(),
    };
  }

  LyubomirUnderstanding copyWith({
    String? id,
    String? name,
    String? description,
    UnderstandingType? type,
    UnderstandingStatus? status,
    DateTime? createdAt,
    DateTime? lastAnalyzed,
    Map<String, dynamic>? metadata,
    List<UnderstandingResult>? results,
  }) {
    return LyubomirUnderstanding(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      lastAnalyzed: lastAnalyzed ?? this.lastAnalyzed,
      metadata: metadata ?? this.metadata,
      results: results ?? this.results,
    );
  }
}

/// Типы понимания контента
enum UnderstandingType {
  visual,      // Визуальное понимание (изображения, видео)
  audio,       // Аудиальное понимание (звук, музыка)
  text,        // Текстовое понимание (текст, субтитры)
  spatial,     // Пространственное понимание (3D, купольное)
  semantic,    // Семантическое понимание (смысл, контекст)
  interactive, // Интерактивное понимание (взаимодействие)

  static UnderstandingType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'visual':
        return UnderstandingType.visual;
      case 'audio':
        return UnderstandingType.audio;
      case 'text':
        return UnderstandingType.text;
      case 'spatial':
        return UnderstandingType.spatial;
      case 'semantic':
        return UnderstandingType.semantic;
      case 'interactive':
        return UnderstandingType.interactive;
      default:
        return UnderstandingType.semantic;
    }
  }
}

/// Статус понимания
enum UnderstandingStatus {
  idle,        // Ожидание
  analyzing,   // Анализ
  processing,  // Обработка
  completed,   // Завершено
  error,       // Ошибка
  paused,      // Приостановлено

  static UnderstandingStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'idle':
        return UnderstandingStatus.idle;
      case 'analyzing':
        return UnderstandingStatus.analyzing;
      case 'processing':
        return UnderstandingStatus.processing;
      case 'completed':
        return UnderstandingStatus.completed;
      case 'error':
        return UnderstandingStatus.error;
      case 'paused':
        return UnderstandingStatus.paused;
      default:
        return UnderstandingStatus.idle;
    }
  }
}

/// Результат понимания
class UnderstandingResult {
  final String id;
  final String type;
  final double confidence;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final List<String> tags;

  const UnderstandingResult({
    required this.id,
    required this.type,
    required this.confidence,
    required this.data,
    required this.timestamp,
    required this.tags,
  });

  factory UnderstandingResult.fromJson(Map<String, dynamic> json) {
    return UnderstandingResult(
      id: json['id'] as String,
      type: json['type'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      data: Map<String, dynamic>.from(json['data'] as Map),
      timestamp: DateTime.parse(json['timestamp'] as String),
      tags: List<String>.from(json['tags'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'confidence': confidence,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'tags': tags,
    };
  }
}

/// Настройки понимания Любомира
class LyubomirSettings {
  final bool enabled;
  final bool autoAnalyze;
  final double sensitivity;
  final List<UnderstandingType> enabledTypes;
  final Map<String, dynamic> customSettings;

  const LyubomirSettings({
    required this.enabled,
    required this.autoAnalyze,
    required this.sensitivity,
    required this.enabledTypes,
    required this.customSettings,
  });

  factory LyubomirSettings.defaultSettings() {
    return const LyubomirSettings(
      enabled: true,
      autoAnalyze: true,
      sensitivity: 0.7,
      enabledTypes: [
        UnderstandingType.visual,
        UnderstandingType.audio,
        UnderstandingType.semantic,
      ],
      customSettings: {},
    );
  }

  factory LyubomirSettings.fromJson(Map<String, dynamic> json) {
    return LyubomirSettings(
      enabled: json['enabled'] as bool? ?? true,
      autoAnalyze: json['autoAnalyze'] as bool? ?? true,
      sensitivity: (json['sensitivity'] as num?)?.toDouble() ?? 0.7,
      enabledTypes: (json['enabledTypes'] as List?)
          ?.map((type) => UnderstandingType.fromString(type as String))
          .toList() ?? [
        UnderstandingType.visual,
        UnderstandingType.audio,
        UnderstandingType.semantic,
      ],
      customSettings: Map<String, dynamic>.from(json['customSettings'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'autoAnalyze': autoAnalyze,
      'sensitivity': sensitivity,
      'enabledTypes': enabledTypes.map((type) => type.toString()).toList(),
      'customSettings': customSettings,
    };
  }

  LyubomirSettings copyWith({
    bool? enabled,
    bool? autoAnalyze,
    double? sensitivity,
    List<UnderstandingType>? enabledTypes,
    Map<String, dynamic>? customSettings,
  }) {
    return LyubomirSettings(
      enabled: enabled ?? this.enabled,
      autoAnalyze: autoAnalyze ?? this.autoAnalyze,
      sensitivity: sensitivity ?? this.sensitivity,
      enabledTypes: enabledTypes ?? this.enabledTypes,
      customSettings: customSettings ?? this.customSettings,
    );
  }
}
