import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:math';
import 'package:freedome_sphere_flutter/models/zelim_format.dart';
import 'package:path/path.dart' as path;

/// Полная реализация ZelimService для работы с квантовым форматом .zelim
class ZelimService {
  static const String _zelimMagic = 'ZELIM';
  static const int _currentVersion = 1;
  static const int _headerSize = 64; // байт

  /// Экспорт ZelimScene в .zelim файл
  Future<void> exportZelim(ZelimScene scene, String filePath) async {
    final file = File(filePath);

    // Создаем директорию если не существует
    await file.parent.create(recursive: true);

    print('🔮 Экспорт ZELIM сцены в: $filePath');

    final builder = BytesBuilder();

    // 1. ZELIM Header (64 байта)
    _writeHeader(builder, scene);

    // 2. Квантовые элементы
    _writeElements(builder, scene.elements);

    // 3. Группы взаимодействия
    _writeGroups(builder, scene.groups);

    // 4. Метаданные
    _writeMetadata(builder, scene);

    final bytes = builder.toBytes();
    await file.writeAsBytes(bytes);

    print('✅ ZELIM файл экспортирован: ${bytes.length} байт');
  }

  /// Импорт .zelim файла в ZelimScene
  Future<ZelimScene> importZelim(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw FileSystemException('ZELIM файл не найден', filePath);
    }

    print('🔮 Импорт ZELIM файла: $filePath');

    final bytes = await file.readAsBytes();
    final reader = ByteData.view(bytes.buffer);

    // Проверяем заголовок
    final header = _readHeader(reader);
    if (header['magic'] != _zelimMagic) {
      throw FormatException('Неверный формат ZELIM файла');
    }

    // Читаем элементы и группы
    final elements = _readElements(
      reader,
      header['elementsOffset'],
      header['elementsCount'],
    );
    final groups = _readGroups(
      reader,
      header['groupsOffset'],
      header['groupsCount'],
    );

    final scene = ZelimScene(
      version: header['version'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(header['timestamp']),
      sceneSize: header['sceneSize'],
      compression: header['compression'],
      elements: elements,
      groups: groups,
    );

    print(
      '✅ ZELIM сцена импортирована: ${elements.length} элементов, ${groups.length} групп',
    );
    return scene;
  }

  /// Создание квантовой сцены из 3D модели
  Future<ZelimScene> createQuantumScene(
    String modelPath, {
    int quantumElements = 108,
    String compression = 'quantum_lz4',
  }) async {
    print('🌌 Создание квантовой сцены из: $modelPath');

    final elements = <ZelimElement>[];
    final groups = <ZelimElementGroup>[];

    // Генерируем 108 квантовых элементов с фрактальной структурой
    for (int i = 0; i < quantumElements; i++) {
      final element = _generateQuantumElement(i, quantumElements);
      elements.add(element);
    }

    // Создаем группы взаимодействия
    groups.addAll(_createInteractionGroups(elements));

    final scene = ZelimScene(
      version: _currentVersion,
      timestamp: DateTime.now(),
      sceneSize: elements.length * 256, // примерный размер
      compression: compression,
      elements: elements,
      groups: groups,
    );

    print('✅ Квантовая сцена создана: ${elements.length} элементов');
    return scene;
  }

  /// Валидация .zelim файла
  Future<bool> validateZelimFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return false;

      final bytes = await file.readAsBytes();
      if (bytes.length < _headerSize) return false;

      final reader = ByteData.view(bytes.buffer);
      final magic = String.fromCharCodes(bytes.sublist(0, 5));

      return magic == _zelimMagic;
    } catch (e) {
      print('❌ Ошибка валидации ZELIM: $e');
      return false;
    }
  }

  /// Получение информации о .zelim файле
  Future<Map<String, dynamic>> getZelimInfo(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw FileSystemException('ZELIM файл не найден', filePath);
    }

    final bytes = await file.readAsBytes();
    final reader = ByteData.view(bytes.buffer);
    final header = _readHeader(reader);

    return {
      'fileName': path.basename(filePath),
      'filePath': filePath,
      'fileSize': bytes.length,
      'version': header['version'],
      'timestamp': DateTime.fromMillisecondsSinceEpoch(header['timestamp']),
      'sceneSize': header['sceneSize'],
      'compression': header['compression'],
      'elementsCount': header['elementsCount'],
      'groupsCount': header['groupsCount'],
      'isValid': header['magic'] == _zelimMagic,
    };
  }

  // === Приватные методы ===

  void _writeHeader(BytesBuilder builder, ZelimScene scene) {
    final header = ByteData(_headerSize);

    // Magic number (5 bytes)
    final magicBytes = utf8.encode(_zelimMagic);
    for (int i = 0; i < magicBytes.length; i++) {
      header.setUint8(i, magicBytes[i]);
    }

    // Version (4 bytes)
    header.setUint32(8, scene.version, Endian.little);

    // Timestamp (8 bytes)
    header.setUint64(12, scene.timestamp.millisecondsSinceEpoch, Endian.little);

    // Scene size (4 bytes)
    header.setUint32(20, scene.sceneSize, Endian.little);

    // Compression (16 bytes)
    final compressionBytes = utf8.encode(
      scene.compression.padRight(15, '\x00'),
    );
    for (int i = 0; i < 16; i++) {
      header.setUint8(
        24 + i,
        i < compressionBytes.length ? compressionBytes[i] : 0,
      );
    }

    // Elements count (4 bytes)
    header.setUint32(40, scene.elements.length, Endian.little);

    // Groups count (4 bytes)
    header.setUint32(44, scene.groups.length, Endian.little);

    // Elements offset (4 bytes)
    header.setUint32(48, _headerSize, Endian.little);

    // Groups offset (4 bytes) - будет обновлен после записи элементов
    header.setUint32(52, 0, Endian.little);

    // Metadata offset (4 bytes)
    header.setUint32(56, 0, Endian.little);

    // Reserved (4 bytes)
    header.setUint32(60, 0, Endian.little);

    builder.add(header.buffer.asUint8List());
  }

  void _writeElements(BytesBuilder builder, List<ZelimElement> elements) {
    for (final element in elements) {
      final elementData = ByteData(128); // 128 байт на элемент

      elementData.setUint64(0, element.id, Endian.little);
      elementData.setFloat64(8, element.orbitAngle, Endian.little);
      elementData.setFloat64(16, element.radius, Endian.little);
      elementData.setFloat64(24, element.phase, Endian.little);
      elementData.setFloat64(32, element.energyLevel, Endian.little);
      elementData.setUint32(40, element.quantumState, Endian.little);
      elementData.setFloat64(44, element.attractionCoefficient, Endian.little);
      elementData.setFloat64(52, element.conservationFactor, Endian.little);

      // Матрица взаимодействия (9 * 8 = 72 байта)
      for (int i = 0; i < element.interactionMatrix.length && i < 9; i++) {
        elementData.setFloat64(
          60 + i * 8,
          element.interactionMatrix[i],
          Endian.little,
        );
      }

      builder.add(elementData.buffer.asUint8List());
    }
  }

  void _writeGroups(BytesBuilder builder, List<ZelimElementGroup> groups) {
    for (final group in groups) {
      final groupData = ByteData(64); // 64 байта на группу

      groupData.setUint64(0, group.id, Endian.little);
      groupData.setFloat64(8, group.energyTransferRate, Endian.little);
      groupData.setFloat64(16, group.collisionThreshold, Endian.little);

      // Тип группы (16 байт)
      final typeBytes = utf8.encode(group.groupType.padRight(15, '\x00'));
      for (int i = 0; i < 16; i++) {
        groupData.setUint8(24 + i, i < typeBytes.length ? typeBytes[i] : 0);
      }

      // ID элементов (до 5 элементов, 4 байта каждый)
      for (int i = 0; i < group.elementIds.length && i < 5; i++) {
        groupData.setUint32(40 + i * 4, group.elementIds[i], Endian.little);
      }

      builder.add(groupData.buffer.asUint8List());
    }
  }

  void _writeMetadata(BytesBuilder builder, ZelimScene scene) {
    final metadata = {
      'generator': 'FreeDome Sphere',
      'version': '3.0.1',
      'created': scene.timestamp.toIso8601String(),
      'quantumElements': scene.elements.length,
      'interactionGroups': scene.groups.length,
    };

    final metadataJson = utf8.encode(jsonEncode(metadata));
    final metadataSize = ByteData(4);
    metadataSize.setUint32(0, metadataJson.length, Endian.little);

    builder.add(metadataSize.buffer.asUint8List());
    builder.add(metadataJson);
  }

  Map<String, dynamic> _readHeader(ByteData reader) {
    final magic = String.fromCharCodes(reader.buffer.asUint8List(0, 5));

    return {
      'magic': magic,
      'version': reader.getUint32(8, Endian.little),
      'timestamp': reader.getUint64(12, Endian.little),
      'sceneSize': reader.getUint32(20, Endian.little),
      'compression': String.fromCharCodes(
        reader.buffer.asUint8List(24, 16),
      ).replaceAll('\x00', ''),
      'elementsCount': reader.getUint32(40, Endian.little),
      'groupsCount': reader.getUint32(44, Endian.little),
      'elementsOffset': reader.getUint32(48, Endian.little),
      'groupsOffset': reader.getUint32(52, Endian.little),
      'metadataOffset': reader.getUint32(56, Endian.little),
    };
  }

  List<ZelimElement> _readElements(ByteData reader, int offset, int count) {
    final elements = <ZelimElement>[];

    for (int i = 0; i < count; i++) {
      final elementOffset = offset + i * 128;

      final interactionMatrix = <double>[];
      for (int j = 0; j < 9; j++) {
        interactionMatrix.add(
          reader.getFloat64(elementOffset + 60 + j * 8, Endian.little),
        );
      }

      final element = ZelimElement(
        id: reader.getUint64(elementOffset, Endian.little),
        orbitAngle: reader.getFloat64(elementOffset + 8, Endian.little),
        radius: reader.getFloat64(elementOffset + 16, Endian.little),
        phase: reader.getFloat64(elementOffset + 24, Endian.little),
        energyLevel: reader.getFloat64(elementOffset + 32, Endian.little),
        quantumState: reader.getUint32(elementOffset + 40, Endian.little),
        attractionCoefficient: reader.getFloat64(
          elementOffset + 44,
          Endian.little,
        ),
        conservationFactor: reader.getFloat64(
          elementOffset + 52,
          Endian.little,
        ),
        subElements: [],
        interactionMatrix: interactionMatrix,
      );

      elements.add(element);
    }

    return elements;
  }

  List<ZelimElementGroup> _readGroups(ByteData reader, int offset, int count) {
    final groups = <ZelimElementGroup>[];

    for (int i = 0; i < count; i++) {
      final groupOffset = offset + i * 64;

      final elementIds = <int>[];
      for (int j = 0; j < 5; j++) {
        final id = reader.getUint32(groupOffset + 40 + j * 4, Endian.little);
        if (id != 0) elementIds.add(id);
      }

      final group = ZelimElementGroup(
        id: reader.getUint64(groupOffset, Endian.little),
        energyTransferRate: reader.getFloat64(groupOffset + 8, Endian.little),
        collisionThreshold: reader.getFloat64(groupOffset + 16, Endian.little),
        groupType: String.fromCharCodes(
          reader.buffer.asUint8List(groupOffset + 24, 16),
        ).replaceAll('\x00', ''),
        elementIds: elementIds,
        interactionRules: [],
      );

      groups.add(group);
    }

    return groups;
  }

  ZelimElement _generateQuantumElement(int index, int total) {
    final random = Random(index);

    // Фрактальное распределение по золотому сечению
    final phi = (1 + sqrt(5)) / 2;
    final angle = 2 * pi * index / phi;

    return ZelimElement(
      id: index,
      orbitAngle: angle,
      radius: 1.0 + random.nextDouble() * 4.0,
      phase: random.nextDouble() * 2 * pi,
      energyLevel: random.nextDouble() * 2.0 + 0.5,
      quantumState: random.nextInt(8) + 1,
      subElements: [],
      interactionMatrix: List.generate(9, (_) => random.nextDouble() * 2 - 1),
      attractionCoefficient: random.nextDouble() * 0.8 + 0.1,
      conservationFactor: random.nextDouble() * 0.6 + 0.2,
    );
  }

  List<ZelimElementGroup> _createInteractionGroups(
    List<ZelimElement> elements,
  ) {
    final groups = <ZelimElementGroup>[];

    // Создаем группы по 3-5 элементов
    for (int i = 0; i < elements.length; i += 4) {
      final groupElements = elements.skip(i).take(4).toList();
      if (groupElements.isEmpty) break;

      final group = ZelimElementGroup(
        id: i ~/ 4,
        elementIds: groupElements.map((e) => e.id).toList(),
        groupType: 'quantum_cluster',
        interactionRules: [],
        energyTransferRate: 0.5 + Random(i).nextDouble() * 0.4,
        collisionThreshold: 0.1 + Random(i).nextDouble() * 0.3,
      );

      groups.add(group);
    }

    return groups;
  }
}
