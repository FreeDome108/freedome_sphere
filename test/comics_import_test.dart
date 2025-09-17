import 'package:flutter_test/flutter_test.dart';
import 'package:freedome_sphere_flutter/services/boranko_service.dart';
import 'package:freedome_sphere_flutter/services/comics_service.dart';
import 'package:freedome_sphere_flutter/models/boranko_project.dart';
import 'dart:io';

void main() {
  group('Comics Import Tests', () {
    late BorankoService borankoService;
    late ComicsService comicsService;

    setUp(() {
      borankoService = BorankoService();
      comicsService = ComicsService();
    });

    test('import Ch1_Book01.comics and save as mahabharata_s01e01.boranko', () async {
      // Путь к тестовому .comics файлу
      const comicsPath = 'samples/import/comics/Ch1_Book01.comics';
      
      // Путь для сохранения .boranko файла
      const borankoPath = 'test_output/mahabharata_s01e01.boranko';

      // Проверяем, что .comics файл существует
      final comicsFile = File(comicsPath);
      expect(await comicsFile.exists(), isTrue, 
        reason: 'Comics file should exist at $comicsPath');

      // 1. Импортируем .comics файл
      final importResult = await comicsService.importComicsFile(comicsPath);
      expect(importResult.success, isTrue, 
        reason: 'Comics import should succeed');
      expect(importResult.project, isNotNull, 
        reason: 'Imported project should not be null');

      // 2. Конвертируем в BorankoProject
      final borankoProject = await borankoService.importComicsAsBoranko(comicsPath);
      expect(borankoProject, isA<BorankoProject>(), 
        reason: 'Should return a BorankoProject instance');
      expect(borankoProject.pages.isNotEmpty, isTrue, 
        reason: 'Boranko project should have pages');

      // 3. Обновляем имя проекта на "mahabharata_s01e01"
      final renamedProject = BorankoProject(
        id: borankoProject.id,
        name: 'mahabharata_s01e01',
        version: borankoProject.version,
        pages: borankoProject.pages,
      );

      // 4. Сохраняем как .boranko файл
      await borankoService.saveBorankoProject(renamedProject, borankoPath);

      // 5. Проверяем, что файл был создан
      final borankoFile = File(borankoPath);
      expect(await borankoFile.exists(), isTrue, 
        reason: 'Boranko file should be created at $borankoPath');

      // 6. Проверяем содержимое файла
      final fileContent = await borankoFile.readAsString();
      expect(fileContent.isNotEmpty, isTrue, 
        reason: 'Boranko file should not be empty');
      expect(fileContent.contains('mahabharata_s01e01'), isTrue, 
        reason: 'File should contain the project name');

      // 7. Проверяем, что можем загрузить проект обратно
      final loadedProject = await borankoService.importBorankoProject(borankoPath);
      expect(loadedProject, isA<BorankoProject>(), 
        reason: 'Should be able to load saved project');

      // Очистка: удаляем созданный тестовый файл
      if (await borankoFile.exists()) {
        await borankoFile.delete();
      }
      
      // Удаляем директорию test_output если она пуста
      final testDir = Directory('test_output');
      if (await testDir.exists()) {
        final contents = await testDir.list().toList();
        if (contents.isEmpty) {
          await testDir.delete();
        }
      }
    });

    test('validate comics file structure', () async {
      const comicsPath = 'samples/import/comics/Ch1_Book01.comics';
      
      // Проверяем валидность .comics файла
      final isValid = await borankoService.validateComicsFile(comicsPath);
      expect(isValid, isTrue, reason: 'Comics file should be valid');

      // Получаем информацию о файле
      final info = await borankoService.getComicsInfo(comicsPath);
      expect(info, isNotNull, reason: 'Should be able to get comics info');
    });

    test('handle non-existent comics file', () async {
      const nonExistentPath = 'samples/import/comics/non_existent.comics';
      
      // Попытка импорта несуществующего файла должна завершиться ошибкой
      expect(() async => await borankoService.importComicsAsBoranko(nonExistentPath),
        throwsA(isA<Exception>()));
    });
  });
}
