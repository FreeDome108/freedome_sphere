
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

  LyubomirUnderstanding({required this.id, required this.status, this.results = const []});
}

class UnderstandingResult {
  final double confidence;
  final UnderstandingType type;
  final DateTime timestamp;

  UnderstandingResult({required this.confidence, required this.type, required this.timestamp});
}

class LyubomirSettings {
  final bool enabled;
  final List<UnderstandingType> enabledTypes;

  LyubomirSettings({required this.enabled, required this.enabledTypes});

  LyubomirSettings copyWith({bool? enabled, List<UnderstandingType>? enabledTypes}) {
    return LyubomirSettings(
      enabled: enabled ?? this.enabled,
      enabledTypes: enabledTypes ?? this.enabledTypes,
    );
  }
}
