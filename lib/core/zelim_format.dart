import 'dart:convert';
import 'dart:io';
import '../models/project.dart';

/// Формат .zelim - Продвинутая структура хранения для freedome_sphere
/// Поддерживает импорт из устаревших форматов (.comics, .cbr, .cbz)
/// Но сохраняет только в современном формате .zelim
class ZelimFormat {
  final String version = "1.0.0";
  final String format = "zelim";
  final List<String> supportedImportFormats = ['.comics', '.cbr', '.cbz'];
  final String exportFormat = '.zelim';

  /// Создание структуры .zelim файла
  Map<String, dynamic> createZelimStructure(FreedomeProject projectData) {
    return {
      // Заголовок формата
      'header': {
        'format': format,
        'version': version,
        'created': DateTime.now().toIso8601String(),
        'author': 'Freedome Sphere',
        'compatibility': {
          'freedome_sphere': '>=1.0.0',
          'mbharata_client': '>=1.0.0'
        }
      },

      // Метаданные проекта
      'project': {
        'id': projectData.id,
        'name': projectData.name,
        'description': projectData.description,
        'tags': projectData.tags,
        'created': projectData.created.toIso8601String(),
        'modified': projectData.modified.toIso8601String(),
        'version': projectData.version
      },

      // Настройки купола
      'dome': {
        'radius': projectData.dome.radius,
        'projectionType': projectData.dome.projectionType,
        'resolution': {
          'width': projectData.dome.resolution.width,
          'height': projectData.dome.resolution.height
        },
        'supportedFormats': projectData.dome.supportedFormats
      },

      // 3D сцены
      'scenes': projectData.scenes.map((scene) => {
        'id': scene.id,
        'name': scene.name,
        'description': scene.description,
        'models': scene.models.map((model) => {
          'id': model.id,
          'name': model.name,
          'geometryType': model.geometryType,
          'triangles': model.triangles,
          'vertices': model.vertices,
          'filePath': model.filePath,
          'transform': {
            'position': {
              'x': model.transform.position.x,
              'y': model.transform.position.y,
              'z': model.transform.position.z
            },
            'rotation': {
              'x': model.transform.rotation.x,
              'y': model.transform.rotation.y,
              'z': model.transform.rotation.z
            },
            'scale': {
              'x': model.transform.scale.x,
              'y': model.transform.scale.y,
              'z': model.transform.scale.z
            }
          }
        }).toList(),
        'materials': scene.materials.map((material) => {
          'id': material.id,
          'name': material.name,
          'type': material.type,
          'color': material.color,
          'metalness': material.metalness,
          'roughness': material.roughness
        }).toList(),
        'animations': scene.animations.map((animation) => {
          'id': animation.id,
          'name': animation.name,
          'duration': animation.duration,
          'keyframes': animation.keyframes.map((keyframe) => {
            'time': keyframe.time,
            'transform': {
              'position': {
                'x': keyframe.transform.position.x,
                'y': keyframe.transform.position.y,
                'z': keyframe.transform.position.z
              },
              'rotation': {
                'x': keyframe.transform.rotation.x,
                'y': keyframe.transform.rotation.y,
                'z': keyframe.transform.rotation.z
              },
              'scale': {
                'x': keyframe.transform.scale.x,
                'y': keyframe.transform.scale.y,
                'z': keyframe.transform.scale.z
              }
            }
          }).toList()
        }).toList(),
        'textures': scene.textures.map((texture) => {
          'id': texture.id,
          'name': texture.name,
          'filePath': texture.filePath,
          'width': texture.width,
          'height': texture.height
        }).toList()
      }).toList(),

      // Аудио источники
      'audio': projectData.audioSources.map((audio) => {
        'id': audio.id,
        'name': audio.name,
        'type': audio.type,
        'position': {
          'x': audio.position.x,
          'y': audio.position.y,
          'z': audio.position.z
        },
        'volume': audio.volume,
        'filePath': audio.filePath,
        'anAntaSound': {
          'enabled': audio.anAntaSound.enabled,
          'spatialFactor': audio.anAntaSound.spatialFactor,
          'format': audio.anAntaSound.format,
          'supportedFormats': audio.anAntaSound.supportedFormats
        }
      }).toList(),

      // Комиксы (legacy поддержка)
      'comics': projectData.comics.map((comic) => {
        'id': comic.id,
        'name': comic.name,
        'originalPath': comic.originalPath,
        'format': comic.format,
        'pages': comic.pages.map((page) => {
          'id': page.id,
          'imagePath': page.imagePath,
          'pageNumber': page.pageNumber,
          'caption': page.caption
        }).toList()
      }).toList(),

      // Настройки проекта
      'settings': {
        'autoSave': projectData.settings.autoSave,
        'autoSaveInterval': projectData.settings.autoSaveInterval,
        'defaultExportFormat': projectData.settings.defaultExportFormat,
        'recentProjects': projectData.settings.recentProjects
      }
    };
  }

  /// Сохранение проекта в .zelim формат
  Future<bool> saveAsZelim(FreedomeProject project, String outputPath) async {
    try {
      final zelimData = createZelimStructure(project);
      final jsonString = jsonEncode(zelimData);
      
      final file = File(outputPath);
      await file.writeAsString(jsonString);
      
      return true;
    } catch (e) {
      print('Ошибка сохранения .zelim файла: $e');
      return false;
    }
  }

  /// Загрузка проекта из .zelim формата
  Future<FreedomeProject?> loadFromZelim(String filePath) async {
    try {
      final file = File(filePath);
      final jsonString = await file.readAsString();
      final zelimData = jsonDecode(jsonString) as Map<String, dynamic>;
      
      // Валидация заголовка
      final header = zelimData['header'] as Map<String, dynamic>;
      if (header['format'] != format) {
        throw Exception('Неверный формат файла. Ожидается .zelim');
      }
      
      // Извлечение данных проекта
      final projectData = zelimData['project'] as Map<String, dynamic>;
      final domeData = zelimData['dome'] as Map<String, dynamic>;
      final scenesData = zelimData['scenes'] as List<dynamic>;
      final audioData = zelimData['audio'] as List<dynamic>;
      final comicsData = zelimData['comics'] as List<dynamic>;
      final settingsData = zelimData['settings'] as Map<String, dynamic>;
      
      // Создание объекта проекта
      final project = FreedomeProject(
        id: projectData['id'],
        name: projectData['name'],
        description: projectData['description'] ?? '',
        tags: List<String>.from(projectData['tags'] ?? []),
        created: DateTime.parse(projectData['created']),
        modified: DateTime.parse(projectData['modified']),
        version: projectData['version'] ?? '1.0.0',
        dome: DomeSettings(
          radius: domeData['radius']?.toDouble() ?? 10.0,
          projectionType: domeData['projectionType'] ?? 'spherical',
          resolution: Resolution(
            width: domeData['resolution']['width'],
            height: domeData['resolution']['height'],
          ),
          supportedFormats: List<String>.from(domeData['supportedFormats'] ?? []),
        ),
        scenes: scenesData.map((sceneData) => _parseScene(sceneData)).toList(),
        audioSources: audioData.map((audioData) => _parseAudioSource(audioData)).toList(),
        comics: comicsData.map((comicData) => _parseComicContent(comicData)).toList(),
        settings: ProjectSettings(
          autoSave: settingsData['autoSave'] ?? true,
          autoSaveInterval: settingsData['autoSaveInterval'] ?? 300,
          defaultExportFormat: settingsData['defaultExportFormat'] ?? 'mbp',
          recentProjects: List<String>.from(settingsData['recentProjects'] ?? []),
        ),
      );
      
      return project;
    } catch (e) {
      print('Ошибка загрузки .zelim файла: $e');
      return null;
    }
  }

  /// Парсинг сцены из данных
  Scene _parseScene(Map<String, dynamic> sceneData) {
    return Scene(
      id: sceneData['id'],
      name: sceneData['name'],
      description: sceneData['description'] ?? '',
      models: (sceneData['models'] as List<dynamic>)
          .map((modelData) => _parseModel3D(modelData))
          .toList(),
      materials: (sceneData['materials'] as List<dynamic>)
          .map((materialData) => _parseMaterial(materialData))
          .toList(),
      animations: (sceneData['animations'] as List<dynamic>)
          .map((animationData) => _parseAnimation(animationData))
          .toList(),
      textures: (sceneData['textures'] as List<dynamic>)
          .map((textureData) => _parseTexture(textureData))
          .toList(),
    );
  }

  /// Парсинг 3D модели
  Model3D _parseModel3D(Map<String, dynamic> modelData) {
    return Model3D(
      id: modelData['id'],
      name: modelData['name'],
      geometryType: modelData['geometryType'],
      triangles: modelData['triangles'],
      vertices: modelData['vertices'],
      filePath: modelData['filePath'],
      transform: _parseTransform(modelData['transform']),
    );
  }

  /// Парсинг материала
  Material _parseMaterial(Map<String, dynamic> materialData) {
    return Material(
      id: materialData['id'],
      name: materialData['name'],
      type: materialData['type'],
      color: materialData['color'],
      metalness: materialData['metalness']?.toDouble() ?? 0.0,
      roughness: materialData['roughness']?.toDouble() ?? 0.5,
    );
  }

  /// Парсинг анимации
  Animation _parseAnimation(Map<String, dynamic> animationData) {
    return Animation(
      id: animationData['id'],
      name: animationData['name'],
      duration: animationData['duration']?.toDouble() ?? 0.0,
      keyframes: (animationData['keyframes'] as List<dynamic>)
          .map((keyframeData) => _parseKeyframe(keyframeData))
          .toList(),
    );
  }

  /// Парсинг ключевого кадра
  Keyframe _parseKeyframe(Map<String, dynamic> keyframeData) {
    return Keyframe(
      time: keyframeData['time']?.toDouble() ?? 0.0,
      transform: _parseTransform(keyframeData['transform']),
    );
  }

  /// Парсинг текстуры
  Texture _parseTexture(Map<String, dynamic> textureData) {
    return Texture(
      id: textureData['id'],
      name: textureData['name'],
      filePath: textureData['filePath'],
      width: textureData['width'],
      height: textureData['height'],
    );
  }

  /// Парсинг трансформации
  Transform _parseTransform(Map<String, dynamic> transformData) {
    return Transform(
      position: Vector3(
        transformData['position']['x']?.toDouble() ?? 0.0,
        transformData['position']['y']?.toDouble() ?? 0.0,
        transformData['position']['z']?.toDouble() ?? 0.0,
      ),
      rotation: Vector3(
        transformData['rotation']['x']?.toDouble() ?? 0.0,
        transformData['rotation']['y']?.toDouble() ?? 0.0,
        transformData['rotation']['z']?.toDouble() ?? 0.0,
      ),
      scale: Vector3(
        transformData['scale']['x']?.toDouble() ?? 1.0,
        transformData['scale']['y']?.toDouble() ?? 1.0,
        transformData['scale']['z']?.toDouble() ?? 1.0,
      ),
    );
  }

  /// Парсинг аудио источника
  AudioSource _parseAudioSource(Map<String, dynamic> audioData) {
    return AudioSource(
      id: audioData['id'],
      name: audioData['name'],
      type: audioData['type'],
      position: Vector3(
        audioData['position']['x']?.toDouble() ?? 0.0,
        audioData['position']['y']?.toDouble() ?? 0.0,
        audioData['position']['z']?.toDouble() ?? 0.0,
      ),
      volume: audioData['volume']?.toDouble() ?? 1.0,
      filePath: audioData['filePath'],
      anAntaSound: AnAntaSoundSettings(
        enabled: audioData['anAntaSound']['enabled'] ?? true,
        spatialFactor: audioData['anAntaSound']['spatialFactor']?.toDouble() ?? 1.0,
        format: audioData['anAntaSound']['format'] ?? 'daga',
        supportedFormats: List<String>.from(audioData['anAntaSound']['supportedFormats'] ?? []),
      ),
    );
  }

  /// Парсинг контента комиксов
  ComicContent _parseComicContent(Map<String, dynamic> comicData) {
    return ComicContent(
      id: comicData['id'],
      name: comicData['name'],
      originalPath: comicData['originalPath'],
      format: comicData['format'],
      pages: (comicData['pages'] as List<dynamic>)
          .map((pageData) => ComicPage(
                id: pageData['id'],
                imagePath: pageData['imagePath'],
                pageNumber: pageData['pageNumber'],
                caption: pageData['caption'],
              ))
          .toList(),
    );
  }

  /// Получение информации о формате
  Map<String, dynamic> getFormatInfo() {
    return {
      'name': 'Zelim 3D Format',
      'version': version,
      'description': 'Продвинутый формат для хранения 3D контента',
      'supportedImportFormats': supportedImportFormats,
      'exportFormat': exportFormat,
      'features': [
        '3D модели и сцены',
        'Материалы и текстуры',
        'Анимации',
        'Аудио с anAntaSound',
        'Купольная проекция',
        'Современная структура данных',
        'Совместимость с mbharata_client'
      ]
    };
  }
}
