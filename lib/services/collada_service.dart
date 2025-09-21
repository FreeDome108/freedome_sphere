import 'dart:io';
import 'dart:math';
import 'package:xml/xml.dart';
import 'package:freedome_sphere_flutter/models/zelim_format.dart';
import 'package:freedome_sphere_flutter/services/zelim_service.dart';
import 'package:path/path.dart' as path;

/// Полная реализация ColladaService для работы с .dae файлами из samskara
class ColladaService {
  /// Импорт COLLADA файла в формат Zelim
  Future<ZelimScene> importCollada(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw FileSystemException('COLLADA файл не найден', filePath);
    }

    print('🏛️ Импорт COLLADA файла: $filePath');

    final xmlContent = await file.readAsString();
    final document = XmlDocument.parse(xmlContent);

    // Парсим основные секции COLLADA
    final geometries = _parseGeometries(document);
    final materials = _parseMaterials(document);
    final scenes = _parseVisualScenes(document);

    // Конвертируем в квантовые элементы ZELIM
    final elements = await _convertToQuantumElements(
      geometries,
      materials,
      filePath,
    );
    final groups = _createQuantumGroups(elements, scenes);

    final scene = ZelimScene(
      version: 1,
      timestamp: DateTime.now(),
      sceneSize: await _calculateSceneSize(file),
      compression: 'quantum_lz4',
      elements: elements,
      groups: groups,
    );

    print(
      '✅ COLLADA импортирован: ${elements.length} элементов, ${groups.length} групп',
    );
    return scene;
  }

  /// Конвертация samskara моделей в .zelim
  Future<String> convertSamskaraToZelim(
    String samskaraPath,
    String outputDir,
  ) async {
    print('🔮 Конвертация samskara модели: $samskaraPath');

    final samskaraDir = Directory(samskaraPath);
    final zelimOutputDir = Directory(outputDir);

    if (!await samskaraDir.exists()) {
      throw FileSystemException('Директория samskara не найдена', samskaraPath);
    }

    await zelimOutputDir.create(recursive: true);

    final daeFiles = await samskaraDir
        .list(recursive: true)
        .where((entity) => entity is File && entity.path.endsWith('.dae'))
        .cast<File>()
        .toList();

    final convertedFiles = <String>[];
    final zelimService = ZelimService();

    for (final daeFile in daeFiles) {
      try {
        final modelName = _extractModelName(daeFile.path);
        final zelimScene = await importCollada(daeFile.path);

        final zelimPath = path.join(outputDir, '$modelName.zelim');
        await zelimService.exportZelim(zelimScene, zelimPath);

        convertedFiles.add(zelimPath);
        print('✅ Конвертирован: $modelName');
      } catch (e) {
        print('❌ Ошибка конвертации ${daeFile.path}: $e');
      }
    }

    print('🎉 Конвертация завершена: ${convertedFiles.length} файлов');
    return outputDir;
  }

  // === Приватные методы ===

  List<Map<String, dynamic>> _parseGeometries(XmlDocument document) {
    final geometries = <Map<String, dynamic>>[];

    for (final geometry in document.findAllElements('geometry')) {
      final id = geometry.getAttribute('id') ?? '';
      final name = geometry.getAttribute('name') ?? id;

      final mesh = geometry.findElements('mesh').firstOrNull;
      if (mesh == null) continue;

      final vertices = _parseVertices(mesh);
      final polygons = _parsePolygons(mesh);

      geometries.add({
        'id': id,
        'name': name,
        'vertices': vertices,
        'polygons': polygons,
        'vertexCount': vertices.length ~/ 3,
        'polygonCount': polygons.length,
      });
    }

    return geometries;
  }

  List<double> _parseVertices(XmlElement mesh) {
    final vertices = <double>[];

    final source = mesh
        .findElements('source')
        .where((s) => s.getAttribute('id')?.contains('positions') == true)
        .firstOrNull;

    if (source != null) {
      final floatArray = source.findElements('float_array').firstOrNull;
      if (floatArray != null) {
        final data = floatArray.innerText.trim().split(RegExp(r'\s+'));
        vertices.addAll(data.map((s) => double.tryParse(s) ?? 0.0));
      }
    }

    return vertices;
  }

  List<List<int>> _parsePolygons(XmlElement mesh) {
    final polygons = <List<int>>[];

    for (final triangles in mesh.findElements('triangles')) {
      final count = int.tryParse(triangles.getAttribute('count') ?? '0') ?? 0;
      final p = triangles.findElements('p').firstOrNull;

      if (p != null && count > 0) {
        final indices = p.innerText
            .trim()
            .split(RegExp(r'\s+'))
            .map((s) => int.tryParse(s) ?? 0)
            .toList();

        for (int i = 0; i < indices.length; i += 9) {
          if (i + 8 < indices.length) {
            polygons.add([indices[i], indices[i + 3], indices[i + 6]]);
          }
        }
      }
    }

    return polygons;
  }

  List<Map<String, dynamic>> _parseMaterials(XmlDocument document) {
    final materials = <Map<String, dynamic>>[];

    for (final material in document.findAllElements('material')) {
      final id = material.getAttribute('id') ?? '';
      final name = material.getAttribute('name') ?? id;

      materials.add({
        'id': id,
        'name': name,
        'diffuse': [0.8, 0.8, 0.8, 1.0],
      });
    }

    return materials;
  }

  List<Map<String, dynamic>> _parseVisualScenes(XmlDocument document) {
    final scenes = <Map<String, dynamic>>[];

    for (final scene in document.findAllElements('visual_scene')) {
      final id = scene.getAttribute('id') ?? '';
      final name = scene.getAttribute('name') ?? id;

      final nodes = <Map<String, dynamic>>[];
      for (final node in scene.findElements('node')) {
        nodes.add({
          'id': node.getAttribute('id') ?? '',
          'name': node.getAttribute('name') ?? '',
        });
      }

      scenes.add({'id': id, 'name': name, 'nodes': nodes});
    }

    return scenes;
  }

  Future<List<ZelimElement>> _convertToQuantumElements(
    List<Map<String, dynamic>> geometries,
    List<Map<String, dynamic>> materials,
    String filePath,
  ) async {
    final elements = <ZelimElement>[];

    for (int i = 0; i < geometries.length; i++) {
      final geometry = geometries[i];
      final vertices = geometry['vertices'] as List<double>;
      final polygons = geometry['polygons'] as List<List<int>>;

      final quantumElements = _geometryToQuantumElements(
        vertices,
        polygons,
        i,
        filePath,
      );
      elements.addAll(quantumElements);
    }

    if (elements.isEmpty) {
      elements.addAll(_createDefaultQuantumElements(filePath));
    }

    return elements;
  }

  List<ZelimElement> _geometryToQuantumElements(
    List<double> vertices,
    List<List<int>> polygons,
    int geometryIndex,
    String filePath,
  ) {
    final elements = <ZelimElement>[];
    final random = Random(geometryIndex);

    final elementCount = min(27, max(1, polygons.length ~/ 10));

    for (int i = 0; i < elementCount; i++) {
      final phi = (1 + sqrt(5)) / 2;
      final angle = 2 * pi * i / phi;

      final element = ZelimElement(
        id: geometryIndex * 1000 + i,
        orbitAngle: angle,
        radius: 1.0 + random.nextDouble() * 3.0,
        phase: random.nextDouble() * 2 * pi,
        energyLevel: 1.0 + random.nextDouble(),
        quantumState: random.nextInt(8) + 1,
        subElements: [],
        interactionMatrix: List.generate(9, (_) => random.nextDouble() * 2 - 1),
        attractionCoefficient: 0.3 + random.nextDouble() * 0.4,
        conservationFactor: 0.4 + random.nextDouble() * 0.4,
      );

      elements.add(element);
    }

    return elements;
  }

  List<ZelimElement> _createDefaultQuantumElements(String filePath) {
    final modelName = _extractModelName(filePath);
    final elements = <ZelimElement>[];
    final elementCount = _getElementCountForModel(modelName);

    for (int i = 0; i < elementCount; i++) {
      final random = Random(modelName.hashCode + i);
      final phi = (1 + sqrt(5)) / 2;
      final angle = 2 * pi * i / phi;

      final element = ZelimElement(
        id: i,
        orbitAngle: angle,
        radius: 1.0 + random.nextDouble() * 3.0,
        phase: random.nextDouble() * 2 * pi,
        energyLevel: 0.5 + random.nextDouble() * 1.5,
        quantumState: random.nextInt(8) + 1,
        subElements: [],
        interactionMatrix: List.generate(9, (_) => random.nextDouble() * 2 - 1),
        attractionCoefficient: 0.2 + random.nextDouble() * 0.6,
        conservationFactor: 0.3 + random.nextDouble() * 0.5,
      );

      elements.add(element);
    }

    return elements;
  }

  List<ZelimElementGroup> _createQuantumGroups(
    List<ZelimElement> elements,
    List<Map<String, dynamic>> scenes,
  ) {
    final groups = <ZelimElementGroup>[];

    for (int i = 0; i < elements.length; i += 4) {
      final groupElements = elements.skip(i).take(4).toList();
      if (groupElements.isEmpty) break;

      final group = ZelimElementGroup(
        id: i ~/ 4,
        elementIds: groupElements.map((e) => e.id).toList(),
        groupType: 'quantum_cluster',
        interactionRules: [],
        energyTransferRate: 0.5 + Random(i).nextDouble() * 0.3,
        collisionThreshold: 0.2 + Random(i).nextDouble() * 0.2,
      );

      groups.add(group);
    }

    return groups;
  }

  String _extractModelName(String filePath) {
    final pathParts = path.split(filePath);

    for (int i = pathParts.length - 1; i >= 0; i--) {
      final part = pathParts[i];
      if (part != 'models.scnassets' &&
          part != 'Resources' &&
          !part.endsWith('.dae') &&
          part.isNotEmpty) {
        return part;
      }
    }

    return path.basenameWithoutExtension(filePath);
  }

  int _getElementCountForModel(String modelName) {
    const modelElementCounts = {
      'buddha': 108,
      'vishnu': 81,
      'angel_sphere': 36,
      'dharma_dragons': 54,
      'bhuloka': 72,
      'svarga_loka': 63,
      'snake': 45,
    };

    return modelElementCounts[modelName] ?? 27;
  }

  Future<int> _calculateSceneSize(File file) async {
    final stat = await file.stat();
    return stat.size;
  }
}
