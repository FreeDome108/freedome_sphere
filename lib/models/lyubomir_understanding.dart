
enum UnderstandingType {
  visual,
  audio,
  text,
  spatial,
  semantic,
  interactive,
}

enum UnderstandingStatus {
  idle,
  analyzing,
  processing,
  completed,
  error,
  paused,
}

class LyubomirUnderstanding {
  final String id;
  final UnderstandingStatus status;
  final List<UnderstandingResult> results;
  final DateTime? lastAnalyzed;
  final String name;
  final String description;
  final UnderstandingType type;
  final DateTime createdAt;

  LyubomirUnderstanding({
    required this.id,
    required this.status,
    this.results = const [],
    this.lastAnalyzed,
    required this.name,
    required this.description,
    required this.type,
    required this.createdAt,
  });
}

class UnderstandingResult {
  final double confidence;
  final UnderstandingType type;
  final DateTime timestamp;
  final List<String> tags;
  final dynamic data;

  UnderstandingResult({
    required this.confidence, 
    required this.type, 
    required this.timestamp, 
    this.tags = const [], 
    this.data
  });
}

class LyubomirSettings {
  final bool enabled;
  final List<UnderstandingType> enabledTypes;
  final bool autoAnalyze;
  final double sensitivity;

  LyubomirSettings({
    required this.enabled, 
    required this.enabledTypes, 
    required this.autoAnalyze, 
    required this.sensitivity
  });

  LyubomirSettings copyWith({
    bool? enabled, 
    List<UnderstandingType>? enabledTypes, 
    bool? autoAnalyze, 
    double? sensitivity
  }) {
    return LyubomirSettings(
      enabled: enabled ?? this.enabled,
      enabledTypes: enabledTypes ?? this.enabledTypes,
      autoAnalyze: autoAnalyze ?? this.autoAnalyze,
      sensitivity: sensitivity ?? this.sensitivity,
    );
  }
}
