import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;
import '../models/boranko_project.dart';
import 'comics_service.dart';
import 'boranko_translation_service.dart';

class BorankoService {
  final ComicsService _comicsService = ComicsService();
  final BorankoTranslationService _translationService = BorankoTranslationService();

  /// Импорт .boranko проекта
  Future<BorankoProject> importBorankoProject(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) {
        throw Exception('Файл не найден: $path');
      }

      final jsonString = await file.readAsString();
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;

      return BorankoProject.fromJson(jsonData);
    } catch (e) {
      throw Exception('Ошибка импорта .boranko проекта: $e');
    }
  }

  /// Импорт .comics файла с конвертацией в .boranko (полная спецификация V1)
  /// 
  /// Согласно BORANKO_V1 спецификации:
  /// 1. Все графические ассеты векторизуются и сохраняются в assets/
  /// 2. Баллоны извлекаются и сохраняются в assets/balloons_original/
  /// 3. Баллоны очищаются от текста и сохраняются в assets/balloons/
  /// 4. Автоматический перевод на 108 языков
  Future<BorankoProject> importComicsAsBoranko(
    String comicsPath, {
    String? outputDir,
    bool enableTranslation = true,
    bool enableVectorization = true,
  }) async {
    try {
      print('📂 Импорт .comics файла: $comicsPath');
      
      // Импортируем .comics файл
      final importResult = await _comicsService.importComicsFile(comicsPath);

      if (!importResult.success || importResult.project == null) {
        throw Exception('Ошибка импорта .comics файла: ${importResult.error}');
      }

      final comicsProject = importResult.project!;
      
      // Определяем выходную директорию
      final baseOutputDir = outputDir ?? path.dirname(comicsPath);
      final projectDir = path.join(baseOutputDir, '${comicsProject.name}_boranko');
      final assetsDir = path.join(projectDir, 'assets');
      final balloonsOriginalDir = path.join(assetsDir, 'balloons_original');
      final balloonsCleanedDir = path.join(assetsDir, 'balloons');
      
      // Создаем структуру директорий
      await _createDirectoryStructure([
        projectDir,
        assetsDir,
        balloonsOriginalDir,
        balloonsCleanedDir,
      ]);

      print('📁 Создана структура директорий');
      print('   assets/');
      print('   assets/balloons_original/');
      print('   assets/balloons/');

      // Обрабатываем страницы
      final pages = <BorankoPage>[];
      final allBalloons = <BorankoBalloon>[];
      final originalImages = <String>[];
      final vectorizedImages = <String>[];

      for (final page in comicsProject.pages) {
        print('🔄 Обработка страницы ${page.pageNumber}...');
        
        // Копируем оригинальное изображение
        final originalImagePath = path.join(assetsDir, path.basename(page.fileName));
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
        pages.add(BorankoPage(
          id: '${comicsProject.id}_page_${page.pageNumber}',
          pageNumber: page.pageNumber,
          imagePath: vectorizedPath ?? originalImagePath,
          fileName: path.basename(vectorizedPath ?? originalImagePath),
          originalPath: page.originalPath,
          zDepth: 100.0, // По умолчанию 100 согласно спецификации
          domeOptimized: false,
          quantumCompatible: false,
          balloons: pageBalloons,
        ));
      }

      print('✅ Обработано страниц: ${pages.length}');
      print('✅ Извлечено баллонов: ${allBalloons.length}');

      // Автоматический перевод на 108 языков
      Map<String, BorankoLocalization> localizations = {};
      if (enableTranslation && allBalloons.isNotEmpty) {
        print('🌐 Запуск автоматического перевода на 108 языков...');
        localizations = await _translationService.translateBalloons(
          allBalloons,
          quantumMode: true, // Режим квантовой запутанности
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
        version: '1.0.0',
        pages: pages,
        localizations: localizations,
        assets: assets,
      );

      print('✅ Конвертация завершена успешно!');
      return borankoProject;
    } catch (e) {
      throw Exception('Ошибка конвертации .comics в .boranko: $e');
    }
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
      
      balloons.add(BorankoBalloon(
        id: balloonId,
        originalImagePath: path.join(balloonsOriginalDir, '$balloonId.png'),
        cleanedImagePath: path.join(balloonsCleanedDir, '$balloonId.png'),
        originalText: 'Demo text from page $pageNumber',
        type: BalloonType.speech,
        aspectRatio: 1.5,
        analogDigitalCoefficient: 0.5,
      ));
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

  /// Сохранение .boranko проекта в файл
  Future<void> saveBorankoProject(
    BorankoProject project,
    String filePath,
  ) async {
    try {
      // Создаем директорию если не существует
      final file = File(filePath);
      final directory = file.parent;
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // Конвертируем проект в JSON и сохраняем
      final jsonString = jsonEncode(project.toJson());
      await file.writeAsString(jsonString);

      print('Boranko project saved to: $filePath');
    } catch (e) {
      throw Exception('Ошибка сохранения .boranko проекта: $e');
    }
  }
}
