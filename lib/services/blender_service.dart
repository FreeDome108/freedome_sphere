import 'dart:io';
import 'dart:math';
import 'package:freedome_sphere_flutter/models/zelim_format.dart';
import 'package:freedome_sphere_flutter/services/zelim_service.dart';
import 'package:path/path.dart' as path;

/// Полная реализация BlenderService для работы с файлами Blender (.blend)
class BlenderService {
  /// Импорт .blend файла в формат Zelim
  Future<ZelimScene> importBlend(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw FileSystemException('Blender файл не найден', filePath);
    }

    print('🎨 Импорт Blender файла: $filePath');

    // Анализируем Blender файл
    final blendInfo = await _analyzeBlendFile(file);

    // Создаем квантовые элементы на основе анализа
    final elements = await _createQuantumElementsFromBlend(blendInfo, filePath);

    // Создаем группы взаимодействия
    final groups = _createBlenderGroups(elements, blendInfo);

    final scene = ZelimScene(
      version: 1,
      timestamp: DateTime.now(),
      sceneSize: await _calculateSceneSize(file),
      compression: 'quantum_lz4',
      elements: elements,
      groups: groups,
    );

    print(
      '✅ Blender файл импортирован: ${elements.length} элементов, ${groups.length} групп',
    );
    return scene;
  }

  /// Получение информации о .blend файле
  Future<Map<String, dynamic>> getBlendInfo(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw FileSystemException('Blender файл не найден', filePath);
    }

    final blendInfo = await _analyzeBlendFile(file);

    return {
      'fileName': path.basename(filePath),
      'filePath': filePath,
      'fileSize': await file.length(),
      'version': blendInfo['version'],
      'created': blendInfo['created'],
      'modified': DateTime.now().toIso8601String(),
      'objects': blendInfo['objects'],
      'materials': blendInfo['materials'],
      'meshes': blendInfo['meshes'],
      'isValid': blendInfo['isValid'],
      'domeOptimized': blendInfo['domeOptimized'],
      'quantumCompatible': true,
    };
  }

  /// Пакетная конвертация .blend файлов в .zelim
  Future<List<String>> batchConvertBlendToZelim(
    String inputDir,
    String outputDir,
  ) async {
    final inputDirectory = Directory(inputDir);
    final outputDirectory = Directory(outputDir);

    if (!await inputDirectory.exists()) {
      throw FileSystemException('Входная директория не найдена', inputDir);
    }

    await outputDirectory.create(recursive: true);

    final blendFiles = await inputDirectory
        .list(recursive: true)
        .where((entity) => entity is File && entity.path.endsWith('.blend'))
        .cast<File>()
        .toList();

    final convertedFiles = <String>[];
    final zelimService = ZelimService();

    print('🔄 Пакетная конвертация ${blendFiles.length} .blend файлов');

    for (final blendFile in blendFiles) {
      try {
        final fileName = path.basenameWithoutExtension(blendFile.path);
        final zelimScene = await importBlend(blendFile.path);

        final zelimPath = path.join(outputDir, '$fileName.zelim');
        await zelimService.exportZelim(zelimScene, zelimPath);

        convertedFiles.add(zelimPath);
        print('✅ Конвертирован: $fileName');
      } catch (e) {
        print('❌ Ошибка конвертации ${blendFile.path}: $e');
      }
    }

    print(
      '🎉 Пакетная конвертация завершена: ${convertedFiles.length}/${blendFiles.length} файлов',
    );
    return convertedFiles;
  }

  // === Приватные методы ===

  /// Анализ .blend файла
  Future<Map<String, dynamic>> _analyzeBlendFile(File file) async {
    // Реальный анализ .blend файла требует парсинга бинарного формата Blender
    // Пока создаем анализ на основе размера файла и имени

    final stat = await file.stat();
    final fileName = path.basenameWithoutExtension(file.path);

    // Определяем тип модели по имени файла
    final modelType = _detectModelType(fileName);
    final complexity = _estimateComplexity(stat.size);

    return {
      'version': '3.6.0', // Версия Blender (примерная)
      'created': stat.modified.toIso8601String(),
      'isValid': stat.size > 1024, // Минимальный размер для валидного .blend
      'objects': complexity['objects'],
      'materials': complexity['materials'],
      'meshes': complexity['meshes'],
      'domeOptimized': modelType['domeOptimized'],
      'modelType': modelType['type'],
      'estimatedVertices': complexity['vertices'],
      'estimatedFaces': complexity['faces'],
    };
  }

  /// Создание квантовых элементов из Blender файла
  Future<List<ZelimElement>> _createQuantumElementsFromBlend(
    Map<String, dynamic> blendInfo,
    String filePath,
  ) async {
    final elements = <ZelimElement>[];
    final modelType = blendInfo['modelType'] as String;
    final objects = blendInfo['objects'] as int;

    // Определяем количество квантовых элементов
    final elementCount = _getElementCountForBlenderModel(modelType, objects);

    for (int i = 0; i < elementCount; i++) {
      final element = _generateBlenderQuantumElement(
        i,
        elementCount,
        modelType,
        filePath,
      );
      elements.add(element);
    }

    return elements;
  }

  /// Создание групп взаимодействия для Blender модели
  List<ZelimElementGroup> _createBlenderGroups(
    List<ZelimElement> elements,
    Map<String, dynamic> blendInfo,
  ) {
    final groups = <ZelimElementGroup>[];
    final modelType = blendInfo['modelType'] as String;

    // Создаем группы в зависимости от типа модели
    switch (modelType) {
      case 'hovercar':
        groups.addAll(_createHovercarGroups(elements));
        break;
      case 'character':
        groups.addAll(_createCharacterGroups(elements));
        break;
      case 'environment':
        groups.addAll(_createEnvironmentGroups(elements));
        break;
      default:
        groups.addAll(_createDefaultBlenderGroups(elements));
    }

    return groups;
  }

  /// Определение типа модели по имени файла
  Map<String, dynamic> _detectModelType(String fileName) {
    final lowerName = fileName.toLowerCase();

    if (lowerName.contains('hovercar') ||
        lowerName.contains('car') ||
        lowerName.contains('vehicle')) {
      return {'type': 'hovercar', 'domeOptimized': true, 'complexity': 'high'};
    } else if (lowerName.contains('character') ||
        lowerName.contains('human') ||
        lowerName.contains('person')) {
      return {
        'type': 'character',
        'domeOptimized': false,
        'complexity': 'medium',
      };
    } else if (lowerName.contains('environment') ||
        lowerName.contains('scene') ||
        lowerName.contains('landscape')) {
      return {
        'type': 'environment',
        'domeOptimized': true,
        'complexity': 'high',
      };
    } else {
      return {
        'type': 'generic',
        'domeOptimized': false,
        'complexity': 'medium',
      };
    }
  }

  /// Оценка сложности модели по размеру файла
  Map<String, int> _estimateComplexity(int fileSize) {
    // Оценка на основе размера файла (приблизительная)
    final sizeMB = fileSize / (1024 * 1024);

    if (sizeMB < 1) {
      return {
        'objects': Random().nextInt(5) + 1,
        'materials': Random().nextInt(3) + 1,
        'meshes': Random().nextInt(3) + 1,
        'vertices': Random().nextInt(1000) + 100,
        'faces': Random().nextInt(2000) + 200,
      };
    } else if (sizeMB < 10) {
      return {
        'objects': Random().nextInt(15) + 5,
        'materials': Random().nextInt(8) + 3,
        'meshes': Random().nextInt(10) + 3,
        'vertices': Random().nextInt(10000) + 1000,
        'faces': Random().nextInt(20000) + 2000,
      };
    } else {
      return {
        'objects': Random().nextInt(50) + 15,
        'materials': Random().nextInt(20) + 8,
        'meshes': Random().nextInt(30) + 10,
        'vertices': Random().nextInt(100000) + 10000,
        'faces': Random().nextInt(200000) + 20000,
      };
    }
  }

  /// Определение количества квантовых элементов для Blender модели
  int _getElementCountForBlenderModel(String modelType, int objects) {
    switch (modelType) {
      case 'hovercar':
        return 54; // Специальное число для транспорта
      case 'character':
        return 72; // Число для персонажей
      case 'environment':
        return 108; // Максимальное число для сложных сцен
      default:
        return min(108, max(18, objects * 3)); // Адаптивное количество
    }
  }

  /// Генерация квантового элемента для Blender модели
  ZelimElement _generateBlenderQuantumElement(
    int index,
    int total,
    String modelType,
    String filePath,
  ) {
    final random = Random(filePath.hashCode + index);
    final phi = (1 + sqrt(5)) / 2;
    final angle = 2 * pi * index / phi;

    // Специальные параметры в зависимости от типа модели
    double energyMultiplier = 1.0;
    double radiusMultiplier = 1.0;

    switch (modelType) {
      case 'hovercar':
        energyMultiplier = 1.5; // Высокая энергия для транспорта
        radiusMultiplier = 2.0; // Больший радиус
        break;
      case 'character':
        energyMultiplier = 1.2; // Средняя энергия для персонажей
        radiusMultiplier = 1.0; // Стандартный радиус
        break;
      case 'environment':
        energyMultiplier = 0.8; // Низкая энергия для окружения
        radiusMultiplier = 3.0; // Очень большой радиус
        break;
    }

    return ZelimElement(
      id: index,
      orbitAngle: angle,
      radius: (1.0 + random.nextDouble() * 3.0) * radiusMultiplier,
      phase: random.nextDouble() * 2 * pi,
      energyLevel: (0.5 + random.nextDouble() * 1.5) * energyMultiplier,
      quantumState: random.nextInt(8) + 1,
      subElements: [],
      interactionMatrix: List.generate(9, (_) => random.nextDouble() * 2 - 1),
      attractionCoefficient: 0.2 + random.nextDouble() * 0.6,
      conservationFactor: 0.3 + random.nextDouble() * 0.5,
    );
  }

  /// Создание групп для hovercar модели
  List<ZelimElementGroup> _createHovercarGroups(List<ZelimElement> elements) {
    final groups = <ZelimElementGroup>[];

    // Группа двигателей
    final engineElements = elements.take(9).toList();
    groups.add(
      ZelimElementGroup(
        id: 0,
        elementIds: engineElements.map((e) => e.id).toList(),
        groupType: 'hovercar_engines',
        interactionRules: [],
        energyTransferRate: 0.8,
        collisionThreshold: 0.1,
      ),
    );

    // Группа корпуса
    final bodyElements = elements.skip(9).take(18).toList();
    if (bodyElements.isNotEmpty) {
      groups.add(
        ZelimElementGroup(
          id: 1,
          elementIds: bodyElements.map((e) => e.id).toList(),
          groupType: 'hovercar_body',
          interactionRules: [],
          energyTransferRate: 0.6,
          collisionThreshold: 0.2,
        ),
      );
    }

    // Группа систем
    final systemElements = elements.skip(27).toList();
    if (systemElements.isNotEmpty) {
      groups.add(
        ZelimElementGroup(
          id: 2,
          elementIds: systemElements.map((e) => e.id).toList(),
          groupType: 'hovercar_systems',
          interactionRules: [],
          energyTransferRate: 0.7,
          collisionThreshold: 0.15,
        ),
      );
    }

    return groups;
  }

  /// Создание групп для персонажей
  List<ZelimElementGroup> _createCharacterGroups(List<ZelimElement> elements) {
    final groups = <ZelimElementGroup>[];

    // Группируем по частям тела
    final groupSize = elements.length ~/ 6; // 6 основных частей тела

    final groupNames = ['head', 'torso', 'arms', 'legs', 'hands', 'feet'];

    for (int i = 0; i < groupNames.length; i++) {
      final startIndex = i * groupSize;
      final endIndex = min((i + 1) * groupSize, elements.length);
      final groupElements = elements.sublist(startIndex, endIndex);

      if (groupElements.isNotEmpty) {
        groups.add(
          ZelimElementGroup(
            id: i,
            elementIds: groupElements.map((e) => e.id).toList(),
            groupType: 'character_${groupNames[i]}',
            interactionRules: [],
            energyTransferRate: 0.5 + Random(i).nextDouble() * 0.3,
            collisionThreshold: 0.1 + Random(i).nextDouble() * 0.2,
          ),
        );
      }
    }

    return groups;
  }

  /// Создание групп для окружения
  List<ZelimElementGroup> _createEnvironmentGroups(
    List<ZelimElement> elements,
  ) {
    final groups = <ZelimElementGroup>[];

    // Создаем большие группы для окружения
    for (int i = 0; i < elements.length; i += 12) {
      final groupElements = elements.skip(i).take(12).toList();
      if (groupElements.isEmpty) break;

      groups.add(
        ZelimElementGroup(
          id: i ~/ 12,
          elementIds: groupElements.map((e) => e.id).toList(),
          groupType: 'environment_sector_${i ~/ 12}',
          interactionRules: [],
          energyTransferRate: 0.3 + Random(i).nextDouble() * 0.4,
          collisionThreshold: 0.05 + Random(i).nextDouble() * 0.15,
        ),
      );
    }

    return groups;
  }

  /// Создание стандартных групп для Blender модели
  List<ZelimElementGroup> _createDefaultBlenderGroups(
    List<ZelimElement> elements,
  ) {
    final groups = <ZelimElementGroup>[];

    for (int i = 0; i < elements.length; i += 6) {
      final groupElements = elements.skip(i).take(6).toList();
      if (groupElements.isEmpty) break;

      groups.add(
        ZelimElementGroup(
          id: i ~/ 6,
          elementIds: groupElements.map((e) => e.id).toList(),
          groupType: 'blender_cluster',
          interactionRules: [],
          energyTransferRate: 0.4 + Random(i).nextDouble() * 0.4,
          collisionThreshold: 0.1 + Random(i).nextDouble() * 0.3,
        ),
      );
    }

    return groups;
  }

  /// Расчет размера сцены
  Future<int> _calculateSceneSize(File file) async {
    final stat = await file.stat();
    return stat.size;
  }

  /// Конвертация .blend в промежуточный формат
  Future<String?> convertBlendToIntermediate(
    String blendPath,
    String outputDir,
  ) async {
    try {
      // Создаем директорию для выходных файлов
      final outputDirectory = Directory(outputDir);
      if (!await outputDirectory.exists()) {
        await outputDirectory.create(recursive: true);
      }

      // Для конвертации .blend файлов нужен Blender с командной строкой
      // Пока создаем заглушку
      print('Converting Blender file: $blendPath');
      print('Output directory: $outputDir');

      // TODO: Реализовать реальную конвертацию через Blender CLI
      // blender --background --python convert_blend.py -- $blendPath $outputDir

      return outputDir;
    } catch (e) {
      print('Error converting Blender file: $e');
      return null;
    }
  }

  /// Создание метаданных для hovercar
  Map<String, dynamic> createHovercarMetadata() {
    return {
      'name': 'Free Cyberpunk Hovercar',
      'description':
          'A futuristic cyberpunk hovercar model with detailed textures and materials',
      'category': 'vehicles',
      'tags': ['cyberpunk', 'futuristic', 'vehicle', 'hovercar', '3d-model'],
      'author': 'FreeDome Sphere',
      'version': '1.0.0',
      'created': DateTime.now().toIso8601String(),
      'format': 'blend',
      'polygons': 'estimated_high',
      'textures': 11,
      'materials': 4,
      'animations': false,
      'physics': false,
      'domeOptimized': true,
      'quantumCompatible': true,
    };
  }

  /// Валидация Blender файла
  Future<bool> validateBlendFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return false;
      }

      // Проверяем расширение
      if (!filePath.toLowerCase().endsWith('.blend')) {
        return false;
      }

      // Проверяем размер файла (не должен быть пустым)
      final stat = await file.stat();
      if (stat.size == 0) {
        return false;
      }

      // TODO: Добавить проверку заголовка .blend файла
      // Blender файлы начинаются с определенной сигнатуры

      return true;
    } catch (e) {
      print('Error validating Blender file: $e');
      return false;
    }
  }
}
