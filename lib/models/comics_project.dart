/// Модель для .comics проекта
class ComicsProject {
  final String id;
  final String name;
  final String? author;
  final String? description;
  final int? duration;
  final String? audioFile;
  final List<ComicsPage> pages;
  final ComicsMetadata metadata;
  final String originalPath;
  final DateTime importedAt;

  ComicsProject({
    required this.id,
    required this.name,
    this.author,
    this.description,
    this.duration,
    this.audioFile,
    required this.pages,
    required this.metadata,
    required this.originalPath,
    required this.importedAt,
  });

  /// Создание из JSON
  factory ComicsProject.fromJson(Map<String, dynamic> json) {
    return ComicsProject(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      author: json['author'],
      description: json['description'],
      duration: json['duration'],
      audioFile: json['audioFile'],
      pages: (json['pages'] as List<dynamic>?)
          ?.map((page) => ComicsPage.fromJson(page))
          .toList() ?? [],
      metadata: ComicsMetadata.fromJson(json['metadata'] ?? {}),
      originalPath: json['originalPath'] ?? '',
      importedAt: DateTime.tryParse(json['importedAt'] ?? '') ?? DateTime.now(),
    );
  }

  /// Конвертация в JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'author': author,
      'description': description,
      'duration': duration,
      'audioFile': audioFile,
      'pages': pages.map((page) => page.toJson()).toList(),
      'metadata': metadata.toJson(),
      'originalPath': originalPath,
      'importedAt': importedAt.toIso8601String(),
    };
  }

  /// Создание из метаданных и страниц
  factory ComicsProject.fromMetadata({
    required String id,
    required String originalPath,
    required ComicsMetadata metadata,
    required List<ComicsPage> pages,
  }) {
    return ComicsProject(
      id: id,
      name: metadata.title,
      author: metadata.author,
      description: metadata.description,
      duration: metadata.duration,
      audioFile: metadata.audioFile,
      pages: pages,
      metadata: metadata,
      originalPath: originalPath,
      importedAt: DateTime.now(),
    );
  }

  /// Получение общего количества страниц
  int get pageCount => pages.length;

  /// Получение первой страницы
  ComicsPage? get firstPage => pages.isNotEmpty ? pages.first : null;

  /// Получение последней страницы
  ComicsPage? get lastPage => pages.isNotEmpty ? pages.last : null;

  /// Проверка, является ли проект валидным
  bool get isValid => pages.isNotEmpty && name.isNotEmpty;

  /// Получение страницы по индексу
  ComicsPage? getPage(int index) {
    if (index >= 0 && index < pages.length) {
      return pages[index];
    }
    return null;
  }

  /// Поиск страницы по имени файла
  ComicsPage? findPageByName(String fileName) {
    try {
      return pages.firstWhere((page) => page.fileName == fileName);
    } catch (e) {
      return null;
    }
  }
}

/// Модель для страницы комикса
class ComicsPage {
  final String fileName;
  final String originalPath;
  final int pageNumber;
  final String? previewPath;
  final Map<String, dynamic>? properties;

  ComicsPage({
    required this.fileName,
    required this.originalPath,
    required this.pageNumber,
    this.previewPath,
    this.properties,
  });

  /// Создание из JSON
  factory ComicsPage.fromJson(Map<String, dynamic> json) {
    return ComicsPage(
      fileName: json['fileName'] ?? '',
      originalPath: json['originalPath'] ?? '',
      pageNumber: json['pageNumber'] ?? 0,
      previewPath: json['previewPath'],
      properties: json['properties'],
    );
  }

  /// Конвертация в JSON
  Map<String, dynamic> toJson() {
    return {
      'fileName': fileName,
      'originalPath': originalPath,
      'pageNumber': pageNumber,
      'previewPath': previewPath,
      'properties': properties,
    };
  }

  /// Создание из файла
  factory ComicsPage.fromFile({
    required String fileName,
    required String originalPath,
    required int pageNumber,
    String? previewPath,
    Map<String, dynamic>? properties,
  }) {
    return ComicsPage(
      fileName: fileName,
      originalPath: originalPath,
      pageNumber: pageNumber,
      previewPath: previewPath,
      properties: properties,
    );
  }

  /// Получение расширения файла
  String get fileExtension {
    final parts = fileName.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : '';
  }

  /// Проверка, является ли файл изображением
  bool get isImage {
    const imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];
    return imageExtensions.contains(fileExtension);
  }

  /// Получение размера файла (если доступно)
  int? get fileSize => properties?['fileSize'];

  /// Получение размеров изображения (если доступно)
  Map<String, int>? get imageDimensions {
    final width = properties?['width'];
    final height = properties?['height'];
    if (width != null && height != null) {
      return {'width': width, 'height': height};
    }
    return null;
  }
}

/// Модель для метаданных комикса
class ComicsMetadata {
  final String title;
  final String? author;
  final String? description;
  final int? duration;
  final String? audioFile;
  final List<String> pages;
  final ComicsMetadataInfo metadata;

  ComicsMetadata({
    required this.title,
    this.author,
    this.description,
    this.duration,
    this.audioFile,
    required this.pages,
    required this.metadata,
  });

  /// Создание из JSON
  factory ComicsMetadata.fromJson(Map<String, dynamic> json) {
    return ComicsMetadata(
      title: json['title'] ?? '',
      author: json['author'],
      description: json['description'],
      duration: json['duration'],
      audioFile: json['audioFile'],
      pages: (json['pages'] as List<dynamic>?)?.cast<String>() ?? [],
      metadata: ComicsMetadataInfo.fromJson(json['metadata'] ?? {}),
    );
  }

  /// Конвертация в JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'author': author,
      'description': description,
      'duration': duration,
      'audioFile': audioFile,
      'pages': pages,
      'metadata': metadata.toJson(),
    };
  }

  /// Создание по умолчанию
  factory ComicsMetadata.defaultMetadata({required String title}) {
    return ComicsMetadata(
      title: title,
      pages: [],
      metadata: ComicsMetadataInfo.defaultInfo(),
    );
  }
}

/// Модель для дополнительной информации о метаданных
class ComicsMetadataInfo {
  final int version;
  final String created;
  final String language;
  final String format;
  final bool domeOptimized;
  final bool quantumCompatible;

  ComicsMetadataInfo({
    required this.version,
    required this.created,
    required this.language,
    required this.format,
    required this.domeOptimized,
    required this.quantumCompatible,
  });

  /// Создание из JSON
  factory ComicsMetadataInfo.fromJson(Map<String, dynamic> json) {
    return ComicsMetadataInfo(
      version: json['version'] ?? 1,
      created: json['created'] ?? DateTime.now().toIso8601String(),
      language: json['language'] ?? 'ru',
      format: json['format'] ?? 'comics',
      domeOptimized: json['domeOptimized'] ?? false,
      quantumCompatible: json['quantumCompatible'] ?? false,
    );
  }

  /// Конвертация в JSON
  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'created': created,
      'language': language,
      'format': format,
      'domeOptimized': domeOptimized,
      'quantumCompatible': quantumCompatible,
    };
  }

  /// Создание по умолчанию
  factory ComicsMetadataInfo.defaultInfo() {
    return ComicsMetadataInfo(
      version: 1,
      created: DateTime.now().toIso8601String(),
      language: 'ru',
      format: 'comics',
      domeOptimized: false,
      quantumCompatible: false,
    );
  }
}

/// Результат импорта комикса
class ComicsImportResult {
  final bool success;
  final ComicsProject? project;
  final String? error;
  final List<String> warnings;

  ComicsImportResult({
    required this.success,
    this.project,
    this.error,
    this.warnings = const [],
  });

  /// Успешный результат
  factory ComicsImportResult.success(ComicsProject project, {List<String> warnings = const []}) {
    return ComicsImportResult(
      success: true,
      project: project,
      warnings: warnings,
    );
  }

  /// Результат с ошибкой
  factory ComicsImportResult.error(String error) {
    return ComicsImportResult(
      success: false,
      error: error,
    );
  }
}
