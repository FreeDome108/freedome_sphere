/// Модель данных для туториала в Комплексе обучения ЛЮБОМИР
///
/// Представляет собой туториал или интерактивный сценарий
class LubomirTutorial {
  final String id;
  final String name;
  final String description;
  final LubomirTutorialType type;
  final LubomirTutorialStatus status;
  final DateTime createdAt;
  final DateTime? lastCompleted;
  final Map<String, dynamic> metadata;
  final List<LubomirTutorialStep> steps;

  const LubomirTutorial({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.status,
    required this.createdAt,
    this.lastCompleted,
    required this.metadata,
    required this.steps,
  });

  factory LubomirTutorial.fromJson(Map<String, dynamic> json) {
    return LubomirTutorial(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: LubomirTutorialTypeExtension.fromString(json['type'] as String),
      status: LubomirTutorialStatusExtension.fromString(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastCompleted: json['lastCompleted'] != null
          ? DateTime.parse(json['lastCompleted'] as String)
          : null,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map),
      steps: (json['steps'] as List)
          .map((step) => LubomirTutorialStep.fromJson(step as Map<String, dynamic>))
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
      'lastCompleted': lastCompleted?.toIso8601String(),
      'metadata': metadata,
      'steps': steps.map((step) => step.toJson()).toList(),
    };
  }

  LubomirTutorial copyWith({
    String? id,
    String? name,
    String? description,
    LubomirTutorialType? type,
    LubomirTutorialStatus? status,
    DateTime? createdAt,
    DateTime? lastCompleted,
    Map<String, dynamic>? metadata,
    List<LubomirTutorialStep>? steps,
  }) {
    return LubomirTutorial(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      lastCompleted: lastCompleted ?? this.lastCompleted,
      metadata: metadata ?? this.metadata,
      steps: steps ?? this.steps,
    );
  }
}

/// Типы туториалов
enum LubomirTutorialType {
  visual,      // Визуальный (изображения, видео)
  audio,       // Аудиальный (звук, музыка)
  text,        // Текстовый (текст, субтитры)
  spatial,     // Пространственный (3D, купольное)
  interactive, // Интерактивный (взаимодействие)
}

/// Расширение для LubomirTutorialType
extension LubomirTutorialTypeExtension on LubomirTutorialType {
  static LubomirTutorialType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'visual':
        return LubomirTutorialType.visual;
      case 'audio':
        return LubomirTutorialType.audio;
      case 'text':
        return LubomirTutorialType.text;
      case 'spatial':
        return LubomirTutorialType.spatial;
      case 'interactive':
        return LubomirTutorialType.interactive;
      default:
        return LubomirTutorialType.interactive;
    }
  }
}

/// Статус туториала
enum LubomirTutorialStatus {
  notStarted, // Не начат
  inProgress, // В процессе
  completed,  // Завершен
  error,      // Ошибка
  paused,     // Приостановлен
}

/// Расширение для LubomirTutorialStatus
extension LubomirTutorialStatusExtension on LubomirTutorialStatus {
  static LubomirTutorialStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'notstarted':
        return LubomirTutorialStatus.notStarted;
      case 'inprogress':
        return LubomirTutorialStatus.inProgress;
      case 'completed':
        return LubomirTutorialStatus.completed;
      case 'error':
        return LubomirTutorialStatus.error;
      case 'paused':
        return LubomirTutorialStatus.paused;
      default:
        return LubomirTutorialStatus.notStarted;
    }
  }
}

/// Шаг туториала
class LubomirTutorialStep {
  final String id;
  final String type;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final List<String> tags;

  const LubomirTutorialStep({
    required this.id,
    required this.type,
    required this.data,
    required this.timestamp,
    required this.tags,
  });

  factory LubomirTutorialStep.fromJson(Map<String, dynamic> json) {
    return LubomirTutorialStep(
      id: json['id'] as String,
      type: json['type'] as String,
      data: Map<String, dynamic>.from(json['data'] as Map),
      timestamp: DateTime.parse(json['timestamp'] as String),
      tags: List<String>.from(json['tags'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'tags': tags,
    };
  }
}

/// Настройки Комплекса обучения ЛЮБОМИР
class LubomirLearningSettings {
  final bool enabled;
  final bool autoStart;
  final List<LubomirTutorialType> enabledTypes;
  final Map<String, dynamic> customSettings;

  const LubomirLearningSettings({
    required this.enabled,
    required this.autoStart,
    required this.enabledTypes,
    required this.customSettings,
  });

  factory LubomirLearningSettings.defaultSettings() {
    return const LubomirLearningSettings(
      enabled: true,
      autoStart: true,
      enabledTypes: [
        LubomirTutorialType.visual,
        LubomirTutorialType.audio,
        LubomirTutorialType.interactive,
      ],
      customSettings: {},
    );
  }

  factory LubomirLearningSettings.fromJson(Map<String, dynamic> json) {
    return LubomirLearningSettings(
      enabled: json['enabled'] as bool? ?? true,
      autoStart: json['autoStart'] as bool? ?? true,
      enabledTypes: (json['enabledTypes'] as List?)
          ?.map((type) => LubomirTutorialTypeExtension.fromString(type as String))
          .toList() ?? [
        LubomirTutorialType.visual,
        LubomirTutorialType.audio,
        LubomirTutorialType.interactive,
      ],
      customSettings: Map<String, dynamic>.from(json['customSettings'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'autoStart': autoStart,
      'enabledTypes': enabledTypes.map((type) => type.toString()).toList(),
      'customSettings': customSettings,
    };
  }

  LubomirLearningSettings copyWith({
    bool? enabled,
    bool? autoStart,
    List<LubomirTutorialType>? enabledTypes,
    Map<String, dynamic>? customSettings,
  }) {
    return LubomirLearningSettings(
      enabled: enabled ?? this.enabled,
      autoStart: autoStart ?? this.autoStart,
      enabledTypes: enabledTypes ?? this.enabledTypes,
      customSettings: customSettings ?? this.customSettings,
    );
  }
}
