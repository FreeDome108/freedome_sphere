import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;
import '../models/boranko_project.dart';
import 'comics_service.dart';
import 'boranko_translation_service.dart';
import 'boranko_layer_sound_mapper.dart';

class BorankoService {
  final ComicsService _comicsService = ComicsService();
  final BorankoTranslationService _translationService =
      BorankoTranslationService();
  final BorankoLayerSoundMapper _layerSoundMapper = BorankoLayerSoundMapper();

  /// Импорт BORANKO проекта
  ///
  /// Поддерживает:
  /// - data.json (V1.1)
  /// - .boranko файлы (legacy V1.0)
  /// - директории проектов (ищет data.json внутри)
  Future<BorankoProject> importBorankoProject(String importPath) async {
    try {
      String dataJsonPath;

      // Определяем путь к файлу данных
      if (importPath.endsWith('data.json')) {
        // Прямой путь к data.json
        dataJsonPath = importPath;
      } else if (importPath.endsWith('.boranko')) {
        // Legacy формат - ищем data.json в папке или читаем как JSON файл
        final file = File(importPath);
        if (await file.exists()) {
          // Это старый формат - один JSON файл
          dataJsonPath = importPath;
        } else {
          // Проверяем директорию с _boranko
          final dir = path.dirname(importPath);
          final basename = path.basenameWithoutExtension(importPath);
          final projectDir = path.join(dir, '${basename}_boranko');
          dataJsonPath = path.join(projectDir, 'data.json');
        }
      } else {
        // Считаем что это директория проекта
        final dir = Directory(importPath);
        if (await dir.exists()) {
          dataJsonPath = path.join(importPath, 'data.json');
        } else {
          throw Exception('Директория не найдена: $importPath');
        }
      }

      // Читаем файл
      final file = File(dataJsonPath);
      if (!await file.exists()) {
        throw Exception('Файл data.json не найден: $dataJsonPath');
      }

      final jsonString = await file.readAsString();
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;

      final project = BorankoProject.fromJson(jsonData);
      print('✅ Загружен BORANKO V${project.version} проект из: $dataJsonPath');

      return project;
    } catch (e) {
      throw Exception('Ошибка импорта BORANKO проекта: $e');
    }
  }

  /// Импорт .comics файла с конвертацией в .boranko (полная спецификация V1.1)
  ///
  /// BORANKO V1.1:
  /// 1. Извлечение layers/ и sounds/ из архива
  /// 2. Создание маппинга между слоями и звуками
  /// 3. Автоматический перевод на 108 языков
  /// 4. Привязка звуков к конкретным слоям через layerId
  Future<BorankoProject> importComicsAsBoranko(
    String comicsPath, {
    String? outputDir,
    bool enableTranslation = true,
    bool enableVectorization = true,
  }) async {
    try {
      print('📂 BORANKO V1.1: Импорт .comics файла: $comicsPath');

      // Импортируем .comics файл
      final importResult = await _comicsService.importComicsFile(comicsPath);

      if (!importResult.success || importResult.project == null) {
        throw Exception('Ошибка импорта .comics файла: ${importResult.error}');
      }

      final comicsProject = importResult.project!;

      // Определяем выходную директорию
      final baseOutputDir = outputDir ?? path.dirname(comicsPath);
      final projectName = path.basenameWithoutExtension(comicsPath);
      final projectDir = path.join(baseOutputDir, '${projectName}_boranko');

      // Создаем структуру директорий
      await _createDirectoryStructure([projectDir]);

      print('📁 Структура проекта: $projectDir');

      // BORANKO V1.1: Проверяем наличие layers и sounds
      if (comicsProject.layers.isNotEmpty && comicsProject.sounds.isNotEmpty) {
        print('✨ Обнаружен новый формат с layers и sounds!');
        return await _importWithLayersAndSounds(
          comicsProject,
          comicsPath,
          projectDir,
          enableTranslation,
        );
      } else {
        print('📦 Legacy формат без layers/sounds');
        return await _importLegacyFormat(
          comicsProject,
          projectDir,
          enableTranslation,
          enableVectorization,
        );
      }
    } catch (e) {
      throw Exception('Ошибка конвертации .comics в .boranko: $e');
    }
  }

  /// Импорт с поддержкой layers и sounds (BORANKO V1.1)
  Future<BorankoProject> _importWithLayersAndSounds(
    dynamic comicsProject,
    String comicsPath,
    String projectDir,
    bool enableTranslation,
  ) async {
    print('\n🎯 BORANKO V1.1: Импорт с layers и sounds');

    // Извлекаем layers/ и sounds/ из архива
    final extracted = await _comicsService.extractLayersAndSounds(
      comicsPath,
      projectDir,
    );

    final layersDir = extracted['layersDir']!;
    final soundsDir = extracted['soundsDir']!;

    // Создаем маппинг между слоями и звуками
    print('\n🔗 Создание маппинга слоев и звуков...');
    final mapping = _layerSoundMapper.mapSoundsToLayers(
      comicsProject.layers,
      comicsProject.sounds,
    );

    // Выводим статистику
    _layerSoundMapper.printMappingStats(mapping, comicsProject.sounds);

    // Создаем BorankoSound с привязкой к слоям
    final borankoSounds = _layerSoundMapper.createBorankoSounds(
      comicsProject.sounds,
      mapping,
      soundsDir,
    );

    // Создаем страницы с привязанными звуками
    final pages = _layerSoundMapper.createBorankoPages(
      comicsProject.layers,
      borankoSounds,
      mapping,
      layersDir,
    );

    print('\n✅ Создано страниц: ${pages.length}');
    print('✅ Создано звуков: ${borankoSounds.length}');

    // Автоматический перевод (если есть баллоны)
    Map<String, BorankoLocalization> localizations = {};
    if (enableTranslation) {
      // TODO: Извлечь баллоны из layers и перевести
      print('⏭️  Перевод баллонов пропущен (требуется OCR)');
    }

    // Создаем структуру ассетов
    final assets = BorankoAssets(
      basePath: projectDir,
      originalImages: [],
      vectorizedImages: [],
      balloonsOriginalPath: path.join(projectDir, 'balloons_original'),
      balloonsCleanedPath: path.join(projectDir, 'balloons'),
    );

    // Создаем финальный BorankoProject
    final borankoProject = BorankoProject(
      id: comicsProject.id,
      name: comicsProject.name,
      version: '1.1.0', // V1.1: поддержка привязки звуков к layer id
      pages: pages,
      localizations: localizations,
      assets: assets,
    );

    print('✅ BORANKO V1.1: Конвертация завершена успешно!');
    return borankoProject;
  }

  /// Импорт legacy формата без layers/sounds
  Future<BorankoProject> _importLegacyFormat(
    dynamic comicsProject,
    String projectDir,
    bool enableTranslation,
    bool enableVectorization,
  ) async {
    final assetsDir = path.join(projectDir, 'assets');
    final balloonsOriginalDir = path.join(assetsDir, 'balloons_original');
    final balloonsCleanedDir = path.join(assetsDir, 'balloons');

    // Создаем структуру директорий
    await _createDirectoryStructure([
      assetsDir,
      balloonsOriginalDir,
      balloonsCleanedDir,
    ]);

    // Обрабатываем страницы
    final pages = <BorankoPage>[];
    final allBalloons = <BorankoBalloon>[];
    final originalImages = <String>[];
    final vectorizedImages = <String>[];

    for (final page in comicsProject.pages) {
      print('🔄 Обработка страницы ${page.pageNumber}...');

      // Копируем оригинальное изображение
      final originalImagePath = path.join(
        assetsDir,
        path.basename(page.fileName),
      );
      originalImages.add(originalImagePath);

      // Векторизация (если включена)
      String? vectorizedPath;
      if (enableVectorization) {
        vectorizedPath = await _vectorizeImage(
          page.originalPath,
          path.join(assetsDir, 'vector_${path.basename(page.fileName)}'),
        );
        if (vectorizedPath != null) {
          vectorizedImages.add(vectorizedPath);
        }
      }

      // Извлечение и обработка баллонов
      final pageBalloons = await _extractAndProcessBalloons(
        page.originalPath,
        page.pageNumber,
        balloonsOriginalDir,
        balloonsCleanedDir,
      );
      allBalloons.addAll(pageBalloons);

      // Создаем BorankoPage
      pages.add(
        BorankoPage(
          id: '${comicsProject.id}_page_${page.pageNumber}',
          pageNumber: page.pageNumber,
          imagePath: vectorizedPath ?? originalImagePath,
          fileName: path.basename(vectorizedPath ?? originalImagePath),
          originalPath: page.originalPath,
          zDepth: 100.0,
          domeOptimized: false,
          quantumCompatible: false,
          balloons: pageBalloons,
        ),
      );
    }

    print('✅ Обработано страниц: ${pages.length}');

    // Автоматический перевод на 108 языков
    Map<String, BorankoLocalization> localizations = {};
    if (enableTranslation && allBalloons.isNotEmpty) {
      print('🌐 Запуск автоматического перевода на 108 языков...');
      localizations = await _translationService.translateBalloons(
        allBalloons,
        quantumMode: true,
      );
      print('✅ Перевод завершен: ${localizations.length} языков');
    }

    // Создаем структуру ассетов
    final assets = BorankoAssets(
      basePath: assetsDir,
      originalImages: originalImages,
      vectorizedImages: vectorizedImages,
      balloonsOriginalPath: balloonsOriginalDir,
      balloonsCleanedPath: balloonsCleanedDir,
    );

    // Создаем финальный BorankoProject
    final borankoProject = BorankoProject(
      id: comicsProject.id,
      name: comicsProject.name,
      version: '1.0.0', // Legacy формат
      pages: pages,
      localizations: localizations,
      assets: assets,
    );

    print('✅ Конвертация завершена (Legacy)');
    return borankoProject;
  }

  /// Создание структуры директорий
  Future<void> _createDirectoryStructure(List<String> dirs) async {
    for (final dir in dirs) {
      final directory = Directory(dir);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
    }
  }

  /// Векторизация изображения
  ///
  /// TODO: Реализовать реальную векторизацию
  /// Сейчас просто копируем изображение в .png формате
  Future<String?> _vectorizeImage(String sourcePath, String targetPath) async {
    try {
      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) {
        return null;
      }

      // В реальной реализации здесь должна быть векторизация
      // Сейчас просто копируем файл
      await sourceFile.copy(targetPath);
      return targetPath;
    } catch (e) {
      print('⚠️ Ошибка векторизации: $e');
      return null;
    }
  }

  /// Извлечение и обработка баллонов из страницы
  ///
  /// TODO: Реализовать реальное извлечение баллонов через CV/ML
  /// Сейчас это заглушка для демонстрации архитектуры
  Future<List<BorankoBalloon>> _extractAndProcessBalloons(
    String imagePath,
    int pageNumber,
    String balloonsOriginalDir,
    String balloonsCleanedDir,
  ) async {
    final balloons = <BorankoBalloon>[];

    try {
      // В реальной реализации здесь должно быть:
      // 1. Детекция баллонов на изображении (CV/ML)
      // 2. Извлечение текста (OCR)
      // 3. Определение типа баллона
      // 4. Вычисление метаданных (соотношение сторон, форма)
      // 5. Очистка от текста

      // Заглушка: создаем один демо-баллон
      final balloonId = 'balloon_page${pageNumber}_1';

      balloons.add(
        BorankoBalloon(
          id: balloonId,
          originalImagePath: path.join(balloonsOriginalDir, '$balloonId.png'),
          cleanedImagePath: path.join(balloonsCleanedDir, '$balloonId.png'),
          originalText: 'Demo text from page $pageNumber',
          type: BalloonType.speech,
          aspectRatio: 1.5,
          analogDigitalCoefficient: 0.5,
        ),
      );
    } catch (e) {
      print('⚠️ Ошибка обработки баллонов: $e');
    }

    return balloons;
  }

  /// Валидация .comics файла
  Future<bool> validateComicsFile(String filePath) async {
    return await _comicsService.validateComicsFile(filePath);
  }

  /// Получение информации о .comics файле
  Future<Map<String, dynamic>?> getComicsInfo(String filePath) async {
    return await _comicsService.getComicsInfo(filePath);
  }

  /// Массовый импорт .comics файлов
  Future<List<BorankoProject>> importComicsFromFolder(String folderPath) async {
    final results = <BorankoProject>[];

    try {
      final importResults = await _comicsService.importComicsFromFolder(
        folderPath,
      );

      for (final result in importResults) {
        if (result.success && result.project != null) {
          final borankoProject = await importComicsAsBoranko(
            result.project!.originalPath,
          );
          results.add(borankoProject);
        }
      }

      return results;
    } catch (e) {
      throw Exception('Ошибка массового импорта: $e');
    }
  }

  /// Сохранение BORANKO проекта
  ///
  /// В BORANKO V1.1 основной файл называется data.json
  /// Структура: project_name_boranko/data.json
  Future<void> saveBorankoProject(
    BorankoProject project,
    String outputPath,
  ) async {
    try {
      // Определяем путь к data.json
      String dataJsonPath;

      if (outputPath.endsWith('.boranko')) {
        // Если передан путь с расширением .boranko, преобразуем в структуру папок
        final dir = path.dirname(outputPath);
        final basename = path.basenameWithoutExtension(outputPath);
        final projectDir = path.join(dir, '${basename}_boranko');
        dataJsonPath = path.join(projectDir, 'data.json');
      } else if (outputPath.endsWith('data.json')) {
        // Если уже указан data.json, используем как есть
        dataJsonPath = outputPath;
      } else {
        // Иначе считаем что это директория проекта
        dataJsonPath = path.join(outputPath, 'data.json');
      }

      // Создаем директорию если не существует
      final file = File(dataJsonPath);
      final directory = file.parent;
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // Конвертируем проект в JSON и сохраняем
      final jsonString = jsonEncode(project.toJson());
      await file.writeAsString(jsonString);

      print('✅ BORANKO V${project.version} project saved to: $dataJsonPath');
    } catch (e) {
      throw Exception('Ошибка сохранения BORANKO проекта: $e');
    }
  }
}
