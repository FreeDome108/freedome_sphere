
import '../models/boranko_project.dart';
import '../models/comics_project.dart';
import 'comics_service.dart';

class BorankoService {
  final ComicsService _comicsService = ComicsService();

  /// Импорт .boranko проекта
  Future<BorankoProject> importBorankoProject(String path) async {
    // TODO: Implement actual file reading and parsing logic
    print('Importing Boranko project from: $path');

    // For now, return a dummy project
    return BorankoProject(
      id: 'dummy-id',
      name: 'Dummy Boranko Project',
      pages: [],
    );
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
        pages: comicsProject.pages.map((page) => BorankoPage(
          id: '${comicsProject.id}_page_${page.pageNumber}',
          fileName: page.fileName,
          originalPath: page.originalPath,
          pageNumber: page.pageNumber,
          zDepth: 0.0, // По умолчанию без глубины
          domeOptimized: false,
          quantumCompatible: false,
        )).toList(),
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
      final importResults = await _comicsService.importComicsFromFolder(folderPath);
      
      for (final result in importResults) {
        if (result.success && result.project != null) {
          final borankoProject = await importComicsAsBoranko(result.project!.originalPath);
          results.add(borankoProject);
        }
      }
      
      return results;
    } catch (e) {
      throw Exception('Ошибка массового импорта: $e');
    }
  }
}
