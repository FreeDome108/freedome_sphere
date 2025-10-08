import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:archive/archive.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

import '../models/comics_project.dart';

/// Сервис для работы с .comics файлами
class ComicsService {
  static final ComicsService _instance = ComicsService._internal();
  factory ComicsService() => _instance;
  ComicsService._internal();

  final _uuid = const Uuid();

  /// Импорт .comics файла
  Future<ComicsImportResult> importComicsFile(String filePath) async {
    try {
      // Проверяем существование файла
      final file = File(filePath);
      if (!await file.exists()) {
        return ComicsImportResult.error('Файл не найден: $filePath');
      }

      // Проверяем расширение файла
      if (!filePath.toLowerCase().endsWith('.comics')) {
        return ComicsImportResult.error(
          'Неверное расширение файла. Ожидается .comics',
        );
      }

      // Читаем файл как ZIP архив
      final bytes = await file.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      // BORANKO V1.1: Ищем data.json в архиве
      final dataJson = await _extractDataJson(archive);

      if (dataJson != null) {
        // Новый формат с data.json (поддерживает layers и sounds)
        return await _importFromDataJson(archive, filePath, dataJson);
      } else {
        // Старый формат без data.json (legacy)
        return await _importLegacyFormat(archive, filePath);
      }
    } catch (e) {
      return ComicsImportResult.error('Ошибка импорта: $e');
    }
  }

  /// Извлечение data.json из архива
  Future<Map<String, dynamic>?> _extractDataJson(Archive archive) async {
    try {
      final dataFile = archive.files.firstWhere(
        (file) => file.name == 'data.json' || file.name.endsWith('/data.json'),
        orElse: () => throw Exception('data.json not found'),
      );

      final content = String.fromCharCodes(dataFile.content);
      return jsonDecode(content) as Map<String, dynamic>;
    } catch (e) {
      return null; // data.json не найден - это нормально для старого формата
    }
  }

  /// Импорт из нового формата с data.json
  Future<ComicsImportResult> _importFromDataJson(
    Archive archive,
    String filePath,
    Map<String, dynamic> dataJson,
  ) async {
    try {
      print('📦 BORANKO V1.1: Обнаружен data.json в архиве');

      // Парсим layers
      final layers = <ComicsLayer>[];
      if (dataJson['layers'] != null) {
        for (int i = 0; i < (dataJson['layers'] as List).length; i++) {
          final layerJson = dataJson['layers'][i];
          layers.add(ComicsLayer.fromJson({'id': 'layer_$i', ...layerJson}));
        }
      }
      print('   📁 Найдено слоев: ${layers.length}');

      // Парсим sounds
      final sounds = <ComicsSound>[];
      if (dataJson['sounds'] != null) {
        for (int i = 0; i < (dataJson['sounds'] as List).length; i++) {
          final soundJson = dataJson['sounds'][i];
          sounds.add(ComicsSound.fromJson({'id': 'sound_$i', ...soundJson}));
        }
      }
      print('   🔊 Найдено звуков: ${sounds.length}');

      // Создаем страницы на основе layers
      final pages = <ComicsPage>[];
      for (int i = 0; i < layers.length; i++) {
        final layer = layers[i];
        final imageFile = layer.mainImageFile;
        if (imageFile != null) {
          pages.add(
            ComicsPage.fromFile(
              fileName: imageFile,
              originalPath: filePath,
              pageNumber: i + 1,
              properties: {'layerId': layer.id},
            ),
          );
        }
      }

      // Извлекаем метаданные
      final metadata = await _extractMetadata(archive);

      // Создаем проект с поддержкой layers и sounds
      final project = ComicsProject(
        id: _uuid.v4(),
        name: metadata.title,
        author: metadata.author,
        description: metadata.description,
        duration: metadata.duration,
        audioFile: metadata.audioFile,
        pages: pages,
        metadata: metadata,
        originalPath: filePath,
        importedAt: DateTime.now(),
        layers: layers,
        sounds: sounds,
        height: dataJson['height'],
        width: dataJson['width'],
      );

      print('✅ BORANKO V1.1: Импорт завершен');
      return ComicsImportResult.success(project);
    } catch (e) {
      return ComicsImportResult.error('Ошибка импорта data.json: $e');
    }
  }

  /// Импорт из старого формата (legacy)
  Future<ComicsImportResult> _importLegacyFormat(
    Archive archive,
    String filePath,
  ) async {
    try {
      print('📦 Legacy: Импорт старого формата без data.json');

      // Извлекаем метаданные
      final metadata = await _extractMetadata(archive);

      // Извлекаем страницы
      final pages = await _extractPages(archive, filePath);

      if (pages.isEmpty) {
        return ComicsImportResult.error('В архиве не найдено изображений');
      }

      // Создаем проект
      final project = ComicsProject.fromMetadata(
        id: _uuid.v4(),
        originalPath: filePath,
        metadata: metadata,
        pages: pages,
      );

      return ComicsImportResult.success(project);
    } catch (e) {
      return ComicsImportResult.error('Ошибка импорта legacy формата: $e');
    }
  }

  /// Извлечение метаданных из архива
  Future<ComicsMetadata> _extractMetadata(Archive archive) async {
    // Ищем файл метаданных
    ArchiveFile? metadataFile;
    for (final file in archive) {
      if (file.name == 'metadata.json' || file.name == 'info.json') {
        metadataFile = file;
        break;
      }
    }

    if (metadataFile != null) {
      try {
        final content = String.fromCharCodes(metadataFile.content);
        final json = jsonDecode(content) as Map<String, dynamic>;
        return ComicsMetadata.fromJson(json);
      } catch (e) {
        print('Ошибка парсинга метаданных: $e');
      }
    }

    // Если метаданные не найдены, создаем по умолчанию
    final fileName = path.basenameWithoutExtension(archive.files.first.name);
    return ComicsMetadata.defaultMetadata(title: fileName);
  }

  /// Извлечение страниц из архива
  Future<List<ComicsPage>> _extractPages(
    Archive archive,
    String originalPath,
  ) async {
    final pages = <ComicsPage>[];
    int pageNumber = 1;

    // Сортируем файлы по имени для правильного порядка страниц
    final imageFiles =
        archive.files
            .where((file) => file.isFile && _isImageFile(file.name))
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name));

    for (final file in imageFiles) {
      final page = ComicsPage.fromFile(
        fileName: file.name,
        originalPath: originalPath,
        pageNumber: pageNumber++,
        properties: {
          'fileSize': file.size,
          'compressedSize':
              file.size, // compressedSize не доступен в новой версии archive
        },
      );
      pages.add(page);
    }

    return pages;
  }

  /// Проверка, является ли файл изображением
  bool _isImageFile(String fileName) {
    final extension = path.extension(fileName).toLowerCase();
    const imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'];
    return imageExtensions.contains(extension);
  }

  /// Валидация .comics файла
  Future<bool> validateComicsFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return false;
      if (!filePath.toLowerCase().endsWith('.comics')) return false;

      final bytes = await file.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      // Проверяем, что в архиве есть хотя бы одно изображение
      return archive.files.any(
        (file) => file.isFile && _isImageFile(file.name),
      );
    } catch (e) {
      return false;
    }
  }

  /// Получение информации о .comics файле без полного импорта
  Future<Map<String, dynamic>?> getComicsInfo(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return null;

      final bytes = await file.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      final imageFiles = archive.files
          .where((file) => file.isFile && _isImageFile(file.name))
          .toList();

      final metadataFile = archive.files
          .where(
            (file) => file.name == 'metadata.json' || file.name == 'info.json',
          )
          .firstOrNull;

      Map<String, dynamic>? metadata;
      if (metadataFile != null) {
        try {
          final content = String.fromCharCodes(metadataFile.content);
          metadata = jsonDecode(content) as Map<String, dynamic>;
        } catch (e) {
          print('Ошибка парсинга метаданных: $e');
        }
      }

      return {
        'fileName': path.basename(filePath),
        'fileSize': await file.length(),
        'pageCount': imageFiles.length,
        'hasMetadata': metadataFile != null,
        'metadata': metadata,
        'pages': imageFiles.map((f) => f.name).toList(),
      };
    } catch (e) {
      return null;
    }
  }

  /// Извлечение изображения страницы из архива
  Future<Uint8List?> extractPageImage(String filePath, String pageName) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return null;

      final bytes = await file.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      final pageFile = archive.files
          .where((file) => file.name == pageName && file.isFile)
          .firstOrNull;

      if (pageFile != null) {
        return Uint8List.fromList(pageFile.content);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Создание превью для страницы
  Future<String?> createPagePreview(
    String filePath,
    String pageName, {
    int maxSize = 200,
  }) async {
    try {
      final imageData = await extractPageImage(filePath, pageName);
      if (imageData == null) return null;

      // TODO: Реализовать создание превью изображения
      // Здесь должна быть логика создания миниатюры
      // Пока возвращаем путь к оригинальному файлу
      return '$filePath::$pageName';
    } catch (e) {
      return null;
    }
  }

  /// Конвертация .comics в .boranko
  Future<ComicsImportResult> convertToBoranko(
    ComicsProject comicsProject,
  ) async {
    try {
      // TODO: Реализовать конвертацию в .boranko формат
      // Пока возвращаем исходный проект
      return ComicsImportResult.success(comicsProject);
    } catch (e) {
      return ComicsImportResult.error('Ошибка конвертации: $e');
    }
  }

  /// Массовый импорт .comics файлов из папки
  Future<List<ComicsImportResult>> importComicsFromFolder(
    String folderPath,
  ) async {
    final results = <ComicsImportResult>[];

    try {
      final folder = Directory(folderPath);
      if (!await folder.exists()) {
        return [ComicsImportResult.error('Папка не найдена: $folderPath')];
      }

      final files = await folder
          .list()
          .where(
            (entity) =>
                entity is File && entity.path.toLowerCase().endsWith('.comics'),
          )
          .cast<File>()
          .toList();

      for (final file in files) {
        final result = await importComicsFile(file.path);
        results.add(result);
      }

      return results;
    } catch (e) {
      return [ComicsImportResult.error('Ошибка импорта из папки: $e')];
    }
  }

  /// Получение списка .comics файлов в папке
  Future<List<String>> findComicsFiles(String folderPath) async {
    try {
      final folder = Directory(folderPath);
      if (!await folder.exists()) return [];

      final files = await folder
          .list()
          .where(
            (entity) =>
                entity is File && entity.path.toLowerCase().endsWith('.comics'),
          )
          .map((entity) => entity.path)
          .toList();

      return files;
    } catch (e) {
      return [];
    }
  }

  /// Извлечение папок layers/ и sounds/ из архива
  ///
  /// BORANKO V1.1: Извлекает ассеты из архива в указанную директорию
  Future<Map<String, String>> extractLayersAndSounds(
    String comicsPath,
    String outputDir,
  ) async {
    try {
      final file = File(comicsPath);
      if (!await file.exists()) {
        throw Exception('Файл не найден: $comicsPath');
      }

      // Читаем архив
      final bytes = await file.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      // Создаем выходные директории
      final layersDir = path.join(outputDir, 'layers');
      final soundsDir = path.join(outputDir, 'sounds');
      await Directory(layersDir).create(recursive: true);
      await Directory(soundsDir).create(recursive: true);

      int layersCount = 0;
      int soundsCount = 0;

      // Извлекаем файлы
      for (final file in archive.files) {
        if (!file.isFile) continue;

        // Проверяем, находится ли файл в layers/ или sounds/
        if (file.name.startsWith('layers/') || file.name.contains('/layers/')) {
          // Извлекаем файл слоя
          final fileName = path.basename(file.name);
          final targetPath = path.join(layersDir, fileName);
          final targetFile = File(targetPath);
          await targetFile.writeAsBytes(file.content);
          layersCount++;
        } else if (file.name.startsWith('sounds/') ||
            file.name.contains('/sounds/')) {
          // Извлекаем звуковой файл
          final fileName = path.basename(file.name);
          final targetPath = path.join(soundsDir, fileName);
          final targetFile = File(targetPath);
          await targetFile.writeAsBytes(file.content);
          soundsCount++;
        }
      }

      print('✅ Извлечено:');
      print('   📁 Слоев (layers): $layersCount');
      print('   🔊 Звуков (sounds): $soundsCount');

      return {
        'layersDir': layersDir,
        'soundsDir': soundsDir,
        'layersCount': layersCount.toString(),
        'soundsCount': soundsCount.toString(),
      };
    } catch (e) {
      throw Exception('Ошибка извлечения layers/sounds: $e');
    }
  }

  /// Извлечение конкретного файла из архива
  Future<Uint8List?> extractFileFromArchive(
    String comicsPath,
    String fileName,
  ) async {
    try {
      final file = File(comicsPath);
      if (!await file.exists()) return null;

      final bytes = await file.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      for (final archiveFile in archive.files) {
        if (archiveFile.isFile &&
            (archiveFile.name == fileName ||
                archiveFile.name.endsWith('/$fileName'))) {
          return Uint8List.fromList(archiveFile.content);
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }
}
