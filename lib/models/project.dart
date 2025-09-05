/// Модель проекта Freedome Sphere
class FreedomeProject {
  final String id;
  final String name;
  final String description;
  final List<String> tags;
  final DateTime created;
  final DateTime modified;
  final String version;
  final DomeSettings dome;
  final List<Scene> scenes;
  final List<AudioSource> audioSources;
  final List<ComicContent> comics;
  final ProjectSettings settings;

  FreedomeProject({
    required this.id,
    required this.name,
    this.description = '',
    this.tags = const [],
    required this.created,
    required this.modified,
    this.version = '1.0.0',
    required this.dome,
    this.scenes = const [],
    this.audioSources = const [],
    this.comics = const [],
    required this.settings,
  });

  FreedomeProject copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? tags,
    DateTime? created,
    DateTime? modified,
    String? version,
    DomeSettings? dome,
    List<Scene>? scenes,
    List<AudioSource>? audioSources,
    List<ComicContent>? comics,
    ProjectSettings? settings,
  }) {
    return FreedomeProject(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      created: created ?? this.created,
      modified: modified ?? this.modified,
      version: version ?? this.version,
      dome: dome ?? this.dome,
      scenes: scenes ?? this.scenes,
      audioSources: audioSources ?? this.audioSources,
      comics: comics ?? this.comics,
      settings: settings ?? this.settings,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'tags': tags,
      'created': created.toIso8601String(),
      'modified': modified.toIso8601String(),
      'version': version,
      'dome': dome.toJson(),
      'scenes': scenes.map((s) => s.toJson()).toList(),
      'audioSources': audioSources.map((a) => a.toJson()).toList(),
      'comics': comics.map((c) => c.toJson()).toList(),
      'settings': settings.toJson(),
    };
  }

  factory FreedomeProject.fromJson(Map<String, dynamic> json) {
    return FreedomeProject(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      created: DateTime.parse(json['created']),
      modified: DateTime.parse(json['modified']),
      version: json['version'] ?? '1.0.0',
      dome: DomeSettings.fromJson(json['dome']),
      scenes: (json['scenes'] as List?)
          ?.map((s) => Scene.fromJson(s))
          .toList() ?? [],
      audioSources: (json['audioSources'] as List?)
          ?.map((a) => AudioSource.fromJson(a))
          .toList() ?? [],
      comics: (json['comics'] as List?)
          ?.map((c) => ComicContent.fromJson(c))
          .toList() ?? [],
      settings: ProjectSettings.fromJson(json['settings']),
    );
  }
}

/// Настройки купола
class DomeSettings {
  final double radius;
  final String projectionType;
  final Resolution resolution;
  final List<String> supportedFormats;

  DomeSettings({
    this.radius = 10.0,
    this.projectionType = 'spherical',
    required this.resolution,
    this.supportedFormats = const ['.dome', '.fsp'],
  });

  Map<String, dynamic> toJson() {
    return {
      'radius': radius,
      'projectionType': projectionType,
      'resolution': resolution.toJson(),
      'supportedFormats': supportedFormats,
    };
  }

  factory DomeSettings.fromJson(Map<String, dynamic> json) {
    return DomeSettings(
      radius: json['radius']?.toDouble() ?? 10.0,
      projectionType: json['projectionType'] ?? 'spherical',
      resolution: Resolution.fromJson(json['resolution']),
      supportedFormats: List<String>.from(json['supportedFormats'] ?? []),
    );
  }

  DomeSettings copyWith({
    double? radius,
    String? projectionType,
    Resolution? resolution,
    List<String>? supportedFormats,
  }) {
    return DomeSettings(
      radius: radius ?? this.radius,
      projectionType: projectionType ?? this.projectionType,
      resolution: resolution ?? this.resolution,
      supportedFormats: supportedFormats ?? this.supportedFormats,
    );
  }
}

/// Разрешение
class Resolution {
  final int width;
  final int height;

  Resolution({required this.width, required this.height});

  Map<String, dynamic> toJson() {
    return {
      'width': width,
      'height': height,
    };
  }

  factory Resolution.fromJson(Map<String, dynamic> json) {
    return Resolution(
      width: json['width'],
      height: json['height'],
    );
  }
}

/// Сцена
class Scene {
  final String id;
  final String name;
  final String description;
  final List<Model3D> models;
  final List<Material> materials;
  final List<Animation> animations;
  final List<Texture> textures;

  Scene({
    required this.id,
    required this.name,
    this.description = '',
    this.models = const [],
    this.materials = const [],
    this.animations = const [],
    this.textures = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'models': models.map((m) => m.toJson()).toList(),
      'materials': materials.map((m) => m.toJson()).toList(),
      'animations': animations.map((a) => a.toJson()).toList(),
      'textures': textures.map((t) => t.toJson()).toList(),
    };
  }

  factory Scene.fromJson(Map<String, dynamic> json) {
    return Scene(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      models: (json['models'] as List?)
          ?.map((m) => Model3D.fromJson(m))
          .toList() ?? [],
      materials: (json['materials'] as List?)
          ?.map((m) => Material.fromJson(m))
          .toList() ?? [],
      animations: (json['animations'] as List?)
          ?.map((a) => Animation.fromJson(a))
          .toList() ?? [],
      textures: (json['textures'] as List?)
          ?.map((t) => Texture.fromJson(t))
          .toList() ?? [],
    );
  }
}

/// 3D Модель
class Model3D {
  final String id;
  final String name;
  final String geometryType;
  final int triangles;
  final int vertices;
  final String? filePath;
  final Transform transform;

  Model3D({
    required this.id,
    required this.name,
    required this.geometryType,
    required this.triangles,
    required this.vertices,
    this.filePath,
    required this.transform,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'geometryType': geometryType,
      'triangles': triangles,
      'vertices': vertices,
      'filePath': filePath,
      'transform': transform.toJson(),
    };
  }

  factory Model3D.fromJson(Map<String, dynamic> json) {
    return Model3D(
      id: json['id'],
      name: json['name'],
      geometryType: json['geometryType'],
      triangles: json['triangles'],
      vertices: json['vertices'],
      filePath: json['filePath'],
      transform: Transform.fromJson(json['transform']),
    );
  }
}

/// Материал
class Material {
  final String id;
  final String name;
  final String type;
  final String color;
  final double metalness;
  final double roughness;

  Material({
    required this.id,
    required this.name,
    required this.type,
    required this.color,
    this.metalness = 0.0,
    this.roughness = 0.5,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'color': color,
      'metalness': metalness,
      'roughness': roughness,
    };
  }

  factory Material.fromJson(Map<String, dynamic> json) {
    return Material(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      color: json['color'],
      metalness: json['metalness']?.toDouble() ?? 0.0,
      roughness: json['roughness']?.toDouble() ?? 0.5,
    );
  }
}

/// Анимация
class Animation {
  final String id;
  final String name;
  final double duration;
  final List<Keyframe> keyframes;

  Animation({
    required this.id,
    required this.name,
    required this.duration,
    this.keyframes = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'duration': duration,
      'keyframes': keyframes.map((k) => k.toJson()).toList(),
    };
  }

  factory Animation.fromJson(Map<String, dynamic> json) {
    return Animation(
      id: json['id'],
      name: json['name'],
      duration: json['duration']?.toDouble() ?? 0.0,
      keyframes: (json['keyframes'] as List?)
          ?.map((k) => Keyframe.fromJson(k))
          .toList() ?? [],
    );
  }
}

/// Ключевой кадр
class Keyframe {
  final double time;
  final Transform transform;

  Keyframe({required this.time, required this.transform});

  Map<String, dynamic> toJson() {
    return {
      'time': time,
      'transform': transform.toJson(),
    };
  }

  factory Keyframe.fromJson(Map<String, dynamic> json) {
    return Keyframe(
      time: json['time']?.toDouble() ?? 0.0,
      transform: Transform.fromJson(json['transform']),
    );
  }
}

/// Текстура
class Texture {
  final String id;
  final String name;
  final String filePath;
  final int width;
  final int height;

  Texture({
    required this.id,
    required this.name,
    required this.filePath,
    required this.width,
    required this.height,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'filePath': filePath,
      'width': width,
      'height': height,
    };
  }

  factory Texture.fromJson(Map<String, dynamic> json) {
    return Texture(
      id: json['id'],
      name: json['name'],
      filePath: json['filePath'],
      width: json['width'],
      height: json['height'],
    );
  }
}

/// Трансформация
class Transform {
  final Vector3 position;
  final Vector3 rotation;
  final Vector3 scale;

  Transform({
    this.position = const Vector3(0, 0, 0),
    this.rotation = const Vector3(0, 0, 0),
    this.scale = const Vector3(1, 1, 1),
  });

  Map<String, dynamic> toJson() {
    return {
      'position': position.toJson(),
      'rotation': rotation.toJson(),
      'scale': scale.toJson(),
    };
  }

  factory Transform.fromJson(Map<String, dynamic> json) {
    return Transform(
      position: Vector3.fromJson(json['position']),
      rotation: Vector3.fromJson(json['rotation']),
      scale: Vector3.fromJson(json['scale']),
    );
  }
}

/// 3D Вектор
class Vector3 {
  final double x;
  final double y;
  final double z;

  const Vector3(this.x, this.y, this.z);

  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
      'z': z,
    };
  }

  factory Vector3.fromJson(Map<String, dynamic> json) {
    return Vector3(
      json['x']?.toDouble() ?? 0.0,
      json['y']?.toDouble() ?? 0.0,
      json['z']?.toDouble() ?? 0.0,
    );
  }
}

/// Аудио источник
class AudioSource {
  final String id;
  final String name;
  final String type;
  final Vector3 position;
  final double volume;
  final String? filePath;
  final AnAntaSoundSettings anAntaSound;

  AudioSource({
    required this.id,
    required this.name,
    required this.type,
    required this.position,
    this.volume = 1.0,
    this.filePath,
    required this.anAntaSound,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'position': position.toJson(),
      'volume': volume,
      'filePath': filePath,
      'anAntaSound': anAntaSound.toJson(),
    };
  }

  factory AudioSource.fromJson(Map<String, dynamic> json) {
    return AudioSource(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      position: Vector3.fromJson(json['position']),
      volume: json['volume']?.toDouble() ?? 1.0,
      filePath: json['filePath'],
      anAntaSound: AnAntaSoundSettings.fromJson(json['anAntaSound']),
    );
  }
}

/// Настройки anAntaSound
class AnAntaSoundSettings {
  final bool enabled;
  final double spatialFactor;
  final String format;
  final List<String> supportedFormats;

  AnAntaSoundSettings({
    this.enabled = true,
    this.spatialFactor = 1.0,
    this.format = 'daga',
    this.supportedFormats = const ['.daga', '.wav', '.mp3'],
  });

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'spatialFactor': spatialFactor,
      'format': format,
      'supportedFormats': supportedFormats,
    };
  }

  factory AnAntaSoundSettings.fromJson(Map<String, dynamic> json) {
    return AnAntaSoundSettings(
      enabled: json['enabled'] ?? true,
      spatialFactor: json['spatialFactor']?.toDouble() ?? 1.0,
      format: json['format'] ?? 'daga',
      supportedFormats: List<String>.from(json['supportedFormats'] ?? []),
    );
  }
}

/// Контент комиксов
class ComicContent {
  final String id;
  final String name;
  final String originalPath;
  final String format;
  final List<ComicPage> pages;

  ComicContent({
    required this.id,
    required this.name,
    required this.originalPath,
    required this.format,
    this.pages = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'originalPath': originalPath,
      'format': format,
      'pages': pages.map((p) => p.toJson()).toList(),
    };
  }

  factory ComicContent.fromJson(Map<String, dynamic> json) {
    return ComicContent(
      id: json['id'],
      name: json['name'],
      originalPath: json['originalPath'],
      format: json['format'],
      pages: (json['pages'] as List?)
          ?.map((p) => ComicPage.fromJson(p))
          .toList() ?? [],
    );
  }
}

/// Страница комикса
class ComicPage {
  final String id;
  final String imagePath;
  final int pageNumber;
  final String? caption;

  ComicPage({
    required this.id,
    required this.imagePath,
    required this.pageNumber,
    this.caption,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imagePath': imagePath,
      'pageNumber': pageNumber,
      'caption': caption,
    };
  }

  factory ComicPage.fromJson(Map<String, dynamic> json) {
    return ComicPage(
      id: json['id'],
      imagePath: json['imagePath'],
      pageNumber: json['pageNumber'],
      caption: json['caption'],
    );
  }
}

/// Настройки проекта
class ProjectSettings {
  final bool autoSave;
  final int autoSaveInterval;
  final String defaultExportFormat;
  final List<String> recentProjects;

  ProjectSettings({
    this.autoSave = true,
    this.autoSaveInterval = 300, // 5 минут
    this.defaultExportFormat = 'mbp',
    this.recentProjects = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'autoSave': autoSave,
      'autoSaveInterval': autoSaveInterval,
      'defaultExportFormat': defaultExportFormat,
      'recentProjects': recentProjects,
    };
  }

  factory ProjectSettings.fromJson(Map<String, dynamic> json) {
    return ProjectSettings(
      autoSave: json['autoSave'] ?? true,
      autoSaveInterval: json['autoSaveInterval'] ?? 300,
      defaultExportFormat: json['defaultExportFormat'] ?? 'mbp',
      recentProjects: List<String>.from(json['recentProjects'] ?? []),
    );
  }
}
