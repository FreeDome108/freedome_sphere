
import 'dart:io';
import 'package:freedome_sphere_flutter/services/collada_service.dart';
import 'package:freedome_sphere_flutter/services/zelim_service.dart';

Future<void> main() async {
  final colladaService = ColladaService();
  final zelimService = ZelimService();

  final samplesDir = Directory('samples/collada');
  final outputDir = Directory('samples/zelim');

  if (!await outputDir.exists()) {
    await outputDir.create(recursive: true);
  }

  final files = samplesDir.listSync(recursive: true);

  for (final file in files) {
    if (file is File && file.path.endsWith('.dae')) {
      print('Converting: ${file.path}');
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

  print('Conversion process completed.');
}
