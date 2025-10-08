import 'package:flutter_test/flutter_test.dart';
import 'package:freedome_sphere_flutter/services/boranko_service.dart';
import 'package:freedome_sphere_flutter/services/comics_service.dart';
import 'dart:io';

/// Тесты для BORANKO V1.1
///
/// Проверяют импорт .comics файлов с layers и sounds,
/// создание маппинга и привязку звуков к слоям
void main() {
  group('BORANKO V1.1 Import Tests', () {
    late BorankoService borankoService;
    late ComicsService comicsService;

    setUp(() {
      borankoService = BorankoService();
      comicsService = ComicsService();
    });

    test('import real comics file with data.json, layers and sounds', () async {
      // Путь к реальному .comics файлу с layers и sounds
      const comicsPath = 'samples/import/comics/Ch1_Book01.comics';

      // Проверяем существование файла
      final file = File(comicsPath);
      if (!await file.exists()) {
        print('⚠️  Файл не найден: $comicsPath');
        print('   Тест пропущен - требуется реальный .comics файл');
        return;
      }

      print('\n🧪 Тестирование BORANKO V1.1 импорта...');
      print('   Файл: $comicsPath');

      // Импортируем .comics файл
      final importResult = await comicsService.importComicsFile(comicsPath);

      expect(
        importResult.success,
        isTrue,
        reason: 'Импорт должен быть успешным',
      );
      expect(
        importResult.project,
        isNotNull,
        reason: 'Проект должен быть создан',
      );

      final comicsProject = importResult.project!;

      print('✅ Импорт .comics успешен');
      print('   Название: ${comicsProject.name}');
      print('   Слоев: ${comicsProject.layers.length}');
      print('   Звуков: ${comicsProject.sounds.length}');
      print('   Размер: ${comicsProject.width}x${comicsProject.height}');

      // Проверяем что есть layers
      expect(
        comicsProject.layers.isNotEmpty,
        isTrue,
        reason: 'Должны быть layers',
      );

      // Проверяем что есть sounds
      expect(
        comicsProject.sounds.isNotEmpty,
        isTrue,
        reason: 'Должны быть sounds',
      );

      // Проверяем структуру слоев
      for (final layer in comicsProject.layers) {
        expect(
          layer.images,
          isNotEmpty,
          reason: 'Каждый слой должен иметь изображения',
        );
        expect(
          layer.animations,
          isNotEmpty,
          reason: 'Каждый слой должен иметь анимации',
        );
      }

      // Проверяем структуру звуков
      for (final sound in comicsProject.sounds) {
        expect(sound.file, isNotEmpty, reason: 'Каждый звук должен иметь файл');
        expect(
          sound.animations,
          isNotEmpty,
          reason: 'Каждый звук должен иметь анимации',
        );
      }
    });

    test('convert comics to boranko v1.1 with layer-sound mapping', () async {
      const comicsPath = 'samples/import/comics/Ch1_Book01.comics';

      final file = File(comicsPath);
      if (!await file.exists()) {
        print('⚠️  Файл не найден: $comicsPath');
        print('   Тест пропущен - требуется реальный .comics файл');
        return;
      }

      print('\n🧪 Тестирование конвертации в BORANKO V1.1...');

      // Конвертируем в Boranko
      final outputDir = 'test_output';
      final borankoProject = await borankoService.importComicsAsBoranko(
        comicsPath,
        outputDir: outputDir,
        enableTranslation: false, // Отключаем перевод для скорости
        enableVectorization: false,
      );

      print('✅ Конвертация в BORANKO V1.1 завершена');
      print('   Версия: ${borankoProject.version}');
      print('   Страниц: ${borankoProject.pages.length}');

      // Проверяем версию
      expect(
        borankoProject.version,
        equals('1.1.0'),
        reason: 'Должна быть версия 1.1.0',
      );

      // Проверяем что есть страницы
      expect(borankoProject.pages, isNotEmpty, reason: 'Должны быть страницы');

      // Подсчитываем звуки с layerId (привязанные к слоям)
      int soundsWithLayerId = 0;
      int globalSounds = 0;

      for (final page in borankoProject.pages) {
        for (final sound in page.sounds) {
          if (sound.layerId != null) {
            soundsWithLayerId++;
            print('   🔗 Звук ${sound.id} привязан к слою ${sound.layerId}');
          } else {
            globalSounds++;
            print('   🌍 Звук ${sound.id} глобальный');
          }
        }
      }

      print('\n📊 Статистика:');
      print('   🔗 Звуков привязанных к слоям: $soundsWithLayerId');
      print('   🌍 Глобальных звуков: $globalSounds');

      // Проверяем что создалась правильная структура
      final projectDir = '$outputDir/Ch1_Book01_boranko';
      final layersDir = Directory('$projectDir/layers');
      final soundsDir = Directory('$projectDir/sounds');

      expect(
        await layersDir.exists(),
        isTrue,
        reason: 'Должна быть папка layers/',
      );
      expect(
        await soundsDir.exists(),
        isTrue,
        reason: 'Должна быть папка sounds/',
      );

      // Подсчитываем файлы
      if (await layersDir.exists()) {
        final layerFiles = await layersDir.list().length;
        print('   📁 Файлов в layers/: $layerFiles');
        expect(
          layerFiles,
          greaterThan(0),
          reason: 'В layers/ должны быть файлы',
        );
      }

      if (await soundsDir.exists()) {
        final soundFiles = await soundsDir.list().length;
        print('   🔊 Файлов в sounds/: $soundFiles');
        expect(
          soundFiles,
          greaterThan(0),
          reason: 'В sounds/ должны быть файлы',
        );
      }
    });

    test('save and load boranko v1.1 project', () async {
      const comicsPath = 'samples/import/comics/Ch1_Book01.comics';

      final file = File(comicsPath);
      if (!await file.exists()) {
        print('⚠️  Файл не найден: $comicsPath');
        print('   Тест пропущен - требуется реальный .comics файл');
        return;
      }

      print('\n🧪 Тестирование сохранения/загрузки BORANKO V1.1...');

      // Конвертируем в Boranko
      final outputDir = 'test_output';
      final borankoProject = await borankoService.importComicsAsBoranko(
        comicsPath,
        outputDir: outputDir,
        enableTranslation: false,
        enableVectorization: false,
      );

      // Сохраняем проект
      final projectPath = '$outputDir/test_boranko_v11.boranko';
      await borankoService.saveBorankoProject(borankoProject, projectPath);

      print('✅ Проект сохранен: $projectPath');

      // Проверяем что создался data.json
      final dataJsonPath = '$outputDir/test_boranko_v11_boranko/data.json';
      final dataJsonFile = File(dataJsonPath);
      expect(
        await dataJsonFile.exists(),
        isTrue,
        reason: 'Должен быть создан data.json',
      );

      // Загружаем проект обратно
      final loadedProject = await borankoService.importBorankoProject(
        '$outputDir/test_boranko_v11_boranko',
      );

      print('✅ Проект загружен обратно');

      // Проверяем что данные сохранились
      expect(
        loadedProject.version,
        equals(borankoProject.version),
        reason: 'Версия должна совпадать',
      );
      expect(
        loadedProject.pages.length,
        equals(borankoProject.pages.length),
        reason: 'Количество страниц должно совпадать',
      );
      expect(
        loadedProject.id,
        equals(borankoProject.id),
        reason: 'ID проекта должен совпадать',
      );

      print('✅ Все данные сохранились корректно');
    });

    test('extract layers and sounds from comics archive', () async {
      const comicsPath = 'samples/import/comics/Ch1_Book01.comics';

      final file = File(comicsPath);
      if (!await file.exists()) {
        print('⚠️  Файл не найден: $comicsPath');
        print('   Тест пропущен - требуется реальный .comics файл');
        return;
      }

      print('\n🧪 Тестирование извлечения layers и sounds...');

      // Извлекаем layers и sounds
      final outputDir = 'test_output/extracted';
      final result = await comicsService.extractLayersAndSounds(
        comicsPath,
        outputDir,
      );

      expect(
        result,
        isNotEmpty,
        reason: 'Результат должен содержать информацию',
      );
      expect(
        result['layersDir'],
        isNotEmpty,
        reason: 'Должна быть указана папка layers',
      );
      expect(
        result['soundsDir'],
        isNotEmpty,
        reason: 'Должна быть указана папка sounds',
      );

      print('✅ Извлечение завершено');
      print('   Layers: ${result["layersCount"]} файлов');
      print('   Sounds: ${result["soundsCount"]} файлов');

      // Проверяем что папки созданы
      final layersDir = Directory(result['layersDir']!);
      final soundsDir = Directory(result['soundsDir']!);

      expect(
        await layersDir.exists(),
        isTrue,
        reason: 'Папка layers должна существовать',
      );
      expect(
        await soundsDir.exists(),
        isTrue,
        reason: 'Папка sounds должна существовать',
      );
    });
  });
}
