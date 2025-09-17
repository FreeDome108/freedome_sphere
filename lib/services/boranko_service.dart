import 'dart:io';
import 'dart:convert';
import '../models/boranko_project.dart';
import 'comics_service.dart';

class BorankoService {
  final ComicsService _comicsService = ComicsService();

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

  /// Импорт .comics файла с конвертацией в .boranko
  Future<BorankoProject> importComicsAsBoranko(String comicsPath) async {
    try {
      // Импортируем .comics файл
      final importResult = await _comicsService.importComicsFile(comicsPath);

      if (!importResult.success || importResult.project == null) {
        throw Exception('Ошибка импорта .comics файла: ${importResult.error}');
      }

      final comicsProject = importResult.project!;

      // Конвертируем в BorankoProject
      final borankoProject = BorankoProject(
        id: comicsProject.id,
        name: comicsProject.name,
        pages: comicsProject.pages
            .map(
              (page) => BorankoPage(
                id: '${comicsProject.id}_page_${page.pageNumber}',
                pageNumber: page.pageNumber,
                imagePath: page.fileName,
                fileName: page.fileName,
                originalPath: page.originalPath,
                zDepth: 0.0, // По умолчанию без глубины
                domeOptimized: false,
                quantumCompatible: false,
              ),
            )
            .toList(),
      );

      return borankoProject;
    } catch (e) {
      throw Exception('Ошибка конвертации .comics в .boranko: $e');
    }
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
