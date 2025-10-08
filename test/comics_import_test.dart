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

    test('import Ch1_Book01.comics and save as data.json (V1.1)', () async {
      // Путь к тестовому .comics файлу
      const comicsPath = 'samples/import/comics/Ch1_Book01.comics';

      // Путь для сохранения (V1.1: создастся project_boranko/data.json)
      const borankoPath = 'test_output/mahabharata_s01e01.boranko';

      // Проверяем, что .comics файл существует
      final comicsFile = File(comicsPath);
      expect(
        await comicsFile.exists(),
        isTrue,
        reason: 'Comics file should exist at $comicsPath',
      );

      // 1. Импортируем .comics файл
      final importResult = await comicsService.importComicsFile(comicsPath);
      expect(
        importResult.success,
        isTrue,
        reason: 'Comics import should succeed',
      );
      expect(
        importResult.project,
        isNotNull,
        reason: 'Imported project should not be null',
      );

      // 2. Конвертируем в BorankoProject
      // Отключаем перевод и векторизацию для ускорения теста
      final borankoProject = await borankoService.importComicsAsBoranko(
        comicsPath,
        enableTranslation: false, // Отключаем перевод для ускорения
        enableVectorization: false, // Отключаем векторизацию для ускорения
      );
      expect(
        borankoProject,
        isA<BorankoProject>(),
        reason: 'Should return a BorankoProject instance',
      );
      expect(
        borankoProject.pages.isNotEmpty,
        isTrue,
        reason: 'Boranko project should have pages',
      );

      // 3. Проверяем соответствие спецификации BORANKO_V1.1

      // Проверяем версию V1.1
      expect(
        borankoProject.version,
        equals('1.1.0'),
        reason: 'Version should be 1.1.0',
      );

      // zDepth должен быть 100 по умолчанию
      for (final page in borankoProject.pages) {
        expect(
          page.zDepth,
          equals(100.0),
          reason: 'zDepth should be 100.0 by default (BORANKO_V1 spec)',
        );
      }

      // Проверяем наличие локализаций
      expect(
        borankoProject.localizations,
        isNotNull,
        reason: 'Project should have localizations',
      );

      // Проверяем структуру ассетов
      expect(
        borankoProject.assets,
        isNotNull,
        reason: 'Project should have assets structure',
      );

      // 4. Обновляем имя проекта на "mahabharata_s01e01"
      final renamedProject = BorankoProject(
        id: borankoProject.id,
        name: 'mahabharata_s01e01',
        version: borankoProject.version,
        pages: borankoProject.pages,
        localizations: borankoProject.localizations,
        assets: borankoProject.assets,
      );

      // 5. Сохраняем (V1.1: создастся data.json)
      await borankoService.saveBorankoProject(renamedProject, borankoPath);

      // 6. Проверяем, что создался data.json (V1.1)
      const dataJsonPath = 'test_output/mahabharata_s01e01_boranko/data.json';
      final dataJsonFile = File(dataJsonPath);
      expect(
        await dataJsonFile.exists(),
        isTrue,
        reason: 'data.json should be created at $dataJsonPath (V1.1)',
      );

      // 7. Проверяем содержимое data.json
      final fileContent = await dataJsonFile.readAsString();
      expect(
        fileContent.isNotEmpty,
        isTrue,
        reason: 'data.json should not be empty',
      );
      expect(
        fileContent.contains('mahabharata_s01e01'),
        isTrue,
        reason: 'data.json should contain the project name',
      );
      expect(
        fileContent.contains('1.1.0'),
        isTrue,
        reason: 'data.json should contain version 1.1.0',
      );

      // 8. Проверяем, что можем загрузить проект обратно
      final loadedProject = await borankoService.importBorankoProject(
        dataJsonPath,
      );
      expect(
        loadedProject,
        isA<BorankoProject>(),
        reason: 'Should be able to load saved project',
      );
      expect(
        loadedProject.version,
        equals('1.1.0'),
        reason: 'Loaded project should be V1.1',
      );

      // Очистка: удаляем созданную директорию проекта
      final projectDir = Directory('test_output/mahabharata_s01e01_boranko');
      if (await projectDir.exists()) {
        await projectDir.delete(recursive: true);
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
      expect(
        () async => await borankoService.importComicsAsBoranko(nonExistentPath),
        throwsA(isA<Exception>()),
      );
    });

    test('validate layerId for sounds (BORANKO_V1.1 spec)', () {
      // Тест привязки звуков к слоям согласно спецификации BORANKO_V1.1

      // Звук без layerId (глобальный)
      final globalSound = BorankoSound(
        id: 'sound_global',
        soundPath: 'audio/global.mp3',
        startTime: 0.0,
        volume: 1.0,
      );
      expect(
        globalSound.layerId,
        isNull,
        reason: 'Global sound should have null layerId',
      );

      // Звук с layerId (привязан к слою)
      final layerSound = BorankoSound(
        id: 'sound_layer',
        soundPath: 'audio/layer.mp3',
        startTime: 1.0,
        volume: 0.8,
        layerId: 'layer_character_1',
      );
      expect(
        layerSound.layerId,
        equals('layer_character_1'),
        reason: 'Layer sound should have specific layerId',
      );

      // Страница со звуками
      final page = BorankoPage(
        id: 'test_page',
        pageNumber: 1,
        imagePath: 'test.png',
        fileName: 'test.png',
        originalPath: 'test.png',
        sounds: [globalSound, layerSound],
      );

      expect(page.sounds.length, equals(2));
      expect(page.sounds[0].layerId, isNull);
      expect(page.sounds[1].layerId, equals('layer_character_1'));

      // Проверка JSON сериализации
      final pageJson = page.toJson();
      final soundsJson = pageJson['sounds'] as List;

      // Глобальный звук не должен иметь layerId в JSON
      expect(soundsJson[0].containsKey('layerId'), isFalse);

      // Звук слоя должен иметь layerId в JSON
      expect(soundsJson[1]['layerId'], equals('layer_character_1'));
    });

    test('validate zDepth range 0-108 (BORANKO_V1 spec)', () {
      // Тест валидации Z-Depth согласно спецификации BORANKO_V1

      // Нормальные значения
      final page1 = BorankoPage(
        id: 'test1',
        pageNumber: 1,
        imagePath: 'test.png',
        fileName: 'test.png',
        originalPath: 'test.png',
        zDepth: 50.0,
      );
      expect(page1.zDepth, equals(50.0));

      // Значение по умолчанию должно быть 100
      final page2 = BorankoPage(
        id: 'test2',
        pageNumber: 2,
        imagePath: 'test.png',
        fileName: 'test.png',
        originalPath: 'test.png',
      );
      expect(
        page2.zDepth,
        equals(100.0),
        reason: 'Default zDepth should be 100.0',
      );

      // Валидация минимума: значения < 0 должны стать 0
      final page3 = BorankoPage(
        id: 'test3',
        pageNumber: 3,
        imagePath: 'test.png',
        fileName: 'test.png',
        originalPath: 'test.png',
        zDepth: -10.0,
      );
      expect(
        page3.zDepth,
        equals(0.0),
        reason: 'Negative zDepth should be clamped to 0.0',
      );

      // Валидация максимума: значения > 108 должны стать 108
      final page4 = BorankoPage(
        id: 'test4',
        pageNumber: 4,
        imagePath: 'test.png',
        fileName: 'test.png',
        originalPath: 'test.png',
        zDepth: 200.0,
      );
      expect(
        page4.zDepth,
        equals(108.0),
        reason: 'zDepth > 108 should be clamped to 108.0',
      );

      // Граничные значения
      final page5 = BorankoPage(
        id: 'test5',
        pageNumber: 5,
        imagePath: 'test.png',
        fileName: 'test.png',
        originalPath: 'test.png',
        zDepth: 108.0,
      );
      expect(
        page5.zDepth,
        equals(108.0),
        reason: 'Max zDepth 108.0 should be valid',
      );

      final page6 = BorankoPage(
        id: 'test6',
        pageNumber: 6,
        imagePath: 'test.png',
        fileName: 'test.png',
        originalPath: 'test.png',
        zDepth: 0.0,
      );
      expect(
        page6.zDepth,
        equals(0.0),
        reason: 'Min zDepth 0.0 should be valid',
      );
    });
  });
}
