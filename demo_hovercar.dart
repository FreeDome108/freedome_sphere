#!/usr/bin/env dart

import 'dart:io';
import 'package:freedome_sphere_flutter/services/blender_service.dart';
import 'package:freedome_sphere_flutter/services/zelim_service.dart';

/// Демонстрация Free Cyberpunk Hovercar в FreeDome Sphere
Future<void> main() async {
  print('🚗 =============================================');
  print('   FREEDOME SPHERE - FREE CYBERPUNK HOVERCAR');
  print('   Демонстрация интеграции');
  print('🚗 =============================================');
  print('');

  final blenderService = BlenderService();
  final zelimService = ZelimService();

  // Путь к hovercar модели
  final hovercarPath = 'samples/import/blend/free-cyberpunk-hovercar/source/cdp-test-7.blend';
  
  print('📁 Проверка файлов...');
  
  // Проверяем существование файла
  final blendFile = File(hovercarPath);
  if (!await blendFile.exists()) {
    print('❌ Файл не найден: $hovercarPath');
    return;
  }
  
  print('✅ Blender файл найден: $hovercarPath');
  
  // Проверяем размер файла
  final stat = await blendFile.stat();
  print('📊 Размер файла: ${(stat.size / 1024).toStringAsFixed(1)} KB');
  
  // Валидируем файл
  print('🔍 Валидация Blender файла...');
  final isValid = await blenderService.validateBlendFile(hovercarPath);
  if (isValid) {
    print('✅ Файл валиден');
  } else {
    print('❌ Файл невалиден');
    return;
  }
  
  print('');
  print('🎨 Импорт в квантовый формат...');
  
  try {
    // Импортируем в Zelim
    final zelimScene = await blenderService.importBlend(hovercarPath);
    
    print('✅ Сцена импортирована:');
    print('   - Версия: ${zelimScene.version}');
    print('   - Временная метка: ${zelimScene.timestamp}');
    print('   - Размер сцены: ${zelimScene.sceneSize} байт');
    print('   - Сжатие: ${zelimScene.compression}');
    print('   - Квантовых элементов: ${zelimScene.elements.length}');
    print('   - Групп элементов: ${zelimScene.groups.length}');
    
    // Показываем детали квантовых элементов
    for (int i = 0; i < zelimScene.elements.length; i++) {
      final element = zelimScene.elements[i];
      print('   Элемент $i:');
      print('     - ID: ${element.id}');
      print('     - Угол орбиты: ${element.orbitAngle}°');
      print('     - Радиус: ${element.radius}');
      print('     - Фаза: ${element.phase}');
      print('     - Уровень энергии: ${element.energyLevel}');
      print('     - Квантовое состояние: ${element.quantumState}');
    }
    
    print('');
    print('💾 Экспорт в .zelim файл...');
    
    // Экспортируем в .zelim
    final outputPath = 'samples/zelim/demo-hovercar.zelim';
    await zelimService.exportZelim(zelimScene, outputPath);
    
    print('✅ Экспорт завершен: $outputPath');
    
    // Проверяем созданный файл
    final outputFile = File(outputPath);
    if (await outputFile.exists()) {
      final outputStat = await outputFile.stat();
      print('📊 Размер .zelim файла: ${outputStat.size} байт');
    }
    
  } catch (e) {
    print('❌ Ошибка импорта: $e');
    return;
  }
  
  print('');
  print('🎯 Проверка текстур...');
  
  final texturesDir = Directory('samples/import/blend/free-cyberpunk-hovercar/textures');
  if (await texturesDir.exists()) {
    final textures = await texturesDir.list().toList();
    print('✅ Найдено текстур: ${textures.length}');
    
    for (final texture in textures) {
      if (texture is File) {
        final textureStat = await texture.stat();
        print('   - ${texture.path.split('/').last}: ${(textureStat.size / 1024).toStringAsFixed(1)} KB');
      }
    }
  }
  
  print('');
  print('📋 Метаданные модели...');
  
  final metadataFile = File('samples/import/blend/free-cyberpunk-hovercar/metadata.json');
  if (await metadataFile.exists()) {
    print('✅ Метаданные найдены');
    final metadata = await metadataFile.readAsString();
    print('📄 Размер метаданных: ${metadata.length} символов');
  }
  
  print('');
  print('🚀 =============================================');
  print('   ДЕМОНСТРАЦИЯ ЗАВЕРШЕНА УСПЕШНО!');
  print('   Free Cyberpunk Hovercar готов к использованию');
  print('   в FreeDome Sphere!');
  print('🚀 =============================================');
  print('');
  print('🎮 Для использования в редакторе:');
  print('   1. Откройте FreeDome Sphere');
  print('   2. File → Import → 3D Model');
  print('   3. Выберите: $hovercarPath');
  print('   4. Настройте квантовые параметры');
  print('   5. Экспортируйте в mbharata_client');
  print('');
  print('🔬 Квантовые возможности:');
  print('   - 108 квантовых элементов');
  print('   - Квантовые резонансы (432 Hz)');
  print('   - Фрактальная структура');
  print('   - anAntaSound интеграция');
  print('');
  print('🎨 Материалы:');
  print('   - CDP Body (металлический корпус)');
  print('   - CDP Metal (металлические детали)');
  print('   - CDP Plastic (пластиковые элементы)');
  print('   - White Light (эмиссивное освещение)');
}

