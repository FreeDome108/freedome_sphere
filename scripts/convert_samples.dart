
import 'dart:io';
import 'package:freedome_sphere_flutter/services/collada_service.dart';
import 'package:freedome_sphere_flutter/services/zelim_service.dart';
import 'package:freedome_sphere_flutter/services/blender_service.dart';

Future<void> main() async {
  final colladaService = ColladaService();
  final zelimService = ZelimService();
  final blenderService = BlenderService();

  // Конвертируем COLLADA файлы
  await _convertColladaFiles(colladaService, zelimService);
  
  // Конвертируем Blender файлы
  await _convertBlenderFiles(blenderService, zelimService);

  print('Conversion process completed.');
}

Future<void> _convertColladaFiles(ColladaService colladaService, ZelimService zelimService) async {
  final samplesDir = Directory('samples/import/collada');
  final outputDir = Directory('samples/zelim');

  if (!await outputDir.exists()) {
    await outputDir.create(recursive: true);
  }

  final files = samplesDir.listSync(recursive: true);

  for (final file in files) {
    if (file is File && file.path.endsWith('.dae')) {
      print('Converting COLLADA: ${file.path}');
      try {
        final zelimScene = await colladaService.importCollada(file.path);

        final outputFileName = file.path
            .split('/')
            .last
            .replaceAll('.dae', '.zelim');
        final outputPath = '${outputDir.path}/$outputFileName';

        await zelimService.exportZelim(zelimScene, outputPath);
        print('Saved to: $outputPath');
      } catch (e) {
        print('Error converting ${file.path}: $e');
      }
    }
  }
}

Future<void> _convertBlenderFiles(BlenderService blenderService, ZelimService zelimService) async {
  final samplesDir = Directory('samples/import/blend');
  final outputDir = Directory('samples/zelim');

  if (!await outputDir.exists()) {
    await outputDir.create(recursive: true);
  }

  final files = samplesDir.listSync(recursive: true);

  for (final file in files) {
    if (file is File && file.path.endsWith('.blend')) {
      print('Converting Blender: ${file.path}');
      try {
        // Валидируем файл
        final isValid = await blenderService.validateBlendFile(file.path);
        if (!isValid) {
          print('Invalid Blender file: ${file.path}');
          continue;
        }

        final zelimScene = await blenderService.importBlend(file.path);

        final outputFileName = file.path
            .split('/')
            .last
            .replaceAll('.blend', '.zelim');
        final outputPath = '${outputDir.path}/$outputFileName';

        await zelimService.exportZelim(zelimScene, outputPath);
        print('Saved to: $outputPath');
      } catch (e) {
        print('Error converting ${file.path}: $e');
      }
    }
  }
}
