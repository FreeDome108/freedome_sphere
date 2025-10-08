
class BorankoProject {
  final String id;
  final String name;
  final String version;
  final List<BorankoPage> pages;
  final Map<String, BorankoLocalization> localizations;
  final BorankoAssets? assets;

  BorankoProject({
    required this.id,
    required this.name,
    this.version = '1.0.0',
    this.pages = const [],
    this.localizations = const {},
    this.assets,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'version': version,
      'pages': pages.map((p) => p.toJson()).toList(),
      'localizations': localizations.map((key, value) => MapEntry(key, value.toJson())),
      'assets': assets?.toJson(),
    };
  }

  factory BorankoProject.fromJson(Map<String, dynamic> json) {
    return BorankoProject(
      id: json['id'],
      name: json['name'],
      version: json['version'] ?? '1.0.0',
      pages: (json['pages'] as List?)
          ?.map((p) => BorankoPage.fromJson(p))
          .toList() ??
          [],
      localizations: (json['localizations'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, BorankoLocalization.fromJson(value)),
      ) ?? {},
      assets: json['assets'] != null ? BorankoAssets.fromJson(json['assets']) : null,
    );
  }
}

class BorankoPage {
  final String id;
  final int pageNumber;
  final String imagePath;
  final String fileName;
  final String originalPath;
  final double zDepth; // По умолчанию 100, range 0-108
  final bool domeOptimized;
  final bool quantumCompatible;
  final String? text;
  final List<BorankoSound> sounds;
  final List<BorankoBalloon> balloons;

  BorankoPage({
    required this.id,
    required this.pageNumber,
    required this.imagePath,
    required this.fileName,
    required this.originalPath,
    double? zDepth,
    this.domeOptimized = false,
    this.quantumCompatible = false,
    this.text,
    this.sounds = const [],
    this.balloons = const [],
  }) : zDepth = _validateZDepth(zDepth ?? 100.0);

  /// Валидация Z-Depth: range 0-108
  static double _validateZDepth(double value) {
    if (value < 0.0) return 0.0;
    if (value > 108.0) return 108.0;
    return value;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pageNumber': pageNumber,
      'imagePath': imagePath,
      'fileName': fileName,
      'originalPath': originalPath,
      'zDepth': zDepth,
      'domeOptimized': domeOptimized,
      'quantumCompatible': quantumCompatible,
      'text': text,
      'sounds': sounds.map((s) => s.toJson()).toList(),
      'balloons': balloons.map((b) => b.toJson()).toList(),
    };
  }

  factory BorankoPage.fromJson(Map<String, dynamic> json) {
    return BorankoPage(
      id: json['id'],
      pageNumber: json['pageNumber'],
      imagePath: json['imagePath'],
      fileName: json['fileName'] ?? json['imagePath'],
      originalPath: json['originalPath'] ?? '',
      zDepth: json['zDepth']?.toDouble(),
      domeOptimized: json['domeOptimized'] ?? false,
      quantumCompatible: json['quantumCompatible'] ?? false,
      text: json['text'],
      sounds: (json['sounds'] as List?)
          ?.map((s) => BorankoSound.fromJson(s))
          .toList() ??
          [],
      balloons: (json['balloons'] as List?)
          ?.map((b) => BorankoBalloon.fromJson(b))
          .toList() ??
          [],
    );
  }
}

class BorankoSound {
  final String id;
  final String soundPath;
  final double startTime;
  final double volume;

  BorankoSound({
    required this.id,
    required this.soundPath,
    this.startTime = 0.0,
    this.volume = 1.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'soundPath': soundPath,
      'startTime': startTime,
      'volume': volume,
    };
  }

  factory BorankoSound.fromJson(Map<String, dynamic> json) {
    return BorankoSound(
      id: json['id'],
      soundPath: json['soundPath'],
      startTime: json['startTime']?.toDouble() ?? 0.0,
      volume: json['volume']?.toDouble() ?? 1.0,
    );
  }
}

/// Структура для локализаций (108 языков)
class BorankoLocalization {
  final String languageCode;
  final Map<String, String> texts; // balloonId -> translated text

  BorankoLocalization({
    required this.languageCode,
    this.texts = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'languageCode': languageCode,
      'texts': texts,
    };
  }

  factory BorankoLocalization.fromJson(Map<String, dynamic> json) {
    return BorankoLocalization(
      languageCode: json['languageCode'],
      texts: Map<String, String>.from(json['texts'] ?? {}),
    );
  }
}

/// Структура для баллонов с метаданными
class BorankoBalloon {
  final String id;
  final String originalImagePath; // Оригинальный баллон
  final String cleanedImagePath; // Очищенный от текста баллон
  final String originalText; // Исходный текст
  final BalloonType type; // Тип баллона
  final double aspectRatio; // Отношение сторон
  final double analogDigitalCoefficient; // 0-1: 0=овальный, 1=прямоугольный

  BorankoBalloon({
    required this.id,
    required this.originalImagePath,
    required this.cleanedImagePath,
    required this.originalText,
    this.type = BalloonType.speech,
    this.aspectRatio = 1.0,
    this.analogDigitalCoefficient = 0.5,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'originalImagePath': originalImagePath,
      'cleanedImagePath': cleanedImagePath,
      'originalText': originalText,
      'type': type.toString().split('.').last,
      'aspectRatio': aspectRatio,
      'analogDigitalCoefficient': analogDigitalCoefficient,
    };
  }

  factory BorankoBalloon.fromJson(Map<String, dynamic> json) {
    return BorankoBalloon(
      id: json['id'],
      originalImagePath: json['originalImagePath'],
      cleanedImagePath: json['cleanedImagePath'],
      originalText: json['originalText'],
      type: BalloonType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => BalloonType.speech,
      ),
      aspectRatio: json['aspectRatio']?.toDouble() ?? 1.0,
      analogDigitalCoefficient: json['analogDigitalCoefficient']?.toDouble() ?? 0.5,
    );
  }
}

/// Типы баллонов
enum BalloonType {
  speech, // Обычная речь
  thought, // Мысли
  shout, // Крик
  whisper, // Шепот
  narration, // Повествование
}

/// Структура для ассетов проекта
class BorankoAssets {
  final String basePath; // Базовая папка assets/
  final List<String> originalImages; // Оригинальные изображения
  final List<String> vectorizedImages; // Векторизованные версии (.png)
  final String balloonsOriginalPath; // assets/balloons_original/
  final String balloonsCleanedPath; // assets/balloons/

  BorankoAssets({
    required this.basePath,
    this.originalImages = const [],
    this.vectorizedImages = const [],
    this.balloonsOriginalPath = 'assets/balloons_original',
    this.balloonsCleanedPath = 'assets/balloons',
  });

  Map<String, dynamic> toJson() {
    return {
      'basePath': basePath,
      'originalImages': originalImages,
      'vectorizedImages': vectorizedImages,
      'balloonsOriginalPath': balloonsOriginalPath,
      'balloonsCleanedPath': balloonsCleanedPath,
    };
  }

  factory BorankoAssets.fromJson(Map<String, dynamic> json) {
    return BorankoAssets(
      basePath: json['basePath'],
      originalImages: List<String>.from(json['originalImages'] ?? []),
      vectorizedImages: List<String>.from(json['vectorizedImages'] ?? []),
      balloonsOriginalPath: json['balloonsOriginalPath'] ?? 'assets/balloons_original',
      balloonsCleanedPath: json['balloonsCleanedPath'] ?? 'assets/balloons',
    );
  }
}
