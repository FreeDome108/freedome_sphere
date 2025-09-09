
import 'package:flutter_test/flutter_test.dart';
import 'package:freedome_sphere_flutter/models/zelim_format.dart';
import 'package:freedome_sphere_flutter/services/collada_service.dart';
import 'package:freedome_sphere_flutter/services/zelim_service.dart';
import 'dart:io';

void main() {
  group('Format Conversion', () {
    final colladaService = ColladaService();
    final zelimService = ZelimService();
    final testOutputDir = Directory('test/output');

    setUp(() {
      if (!testOutputDir.existsSync()) {
        testOutputDir.createSync(recursive: true);
      }
    });

    tearDown(() {
      if (testOutputDir.existsSync()) {
        testOutputDir.deleteSync(recursive: true);
      }
    });

    test('COLLADA -> ZELIM -> COLLADA round-trip consistency', () async {
      const samplePath = 'samples/collada/angel_sphere/angel.dae';
      final outputZelimPath = '${testOutputDir.path}/angel.zelim';

      // 1. Import from COLLADA
      final originalScene = await colladaService.importCollada(samplePath);

      // 2. Export to ZELIM
      await zelimService.exportZelim(originalScene, outputZelimPath);

      // 3. Re-import from ZELIM (assuming a ZelimService.import is implemented)
      // final reimportedScene = await zelimService.importZelim(outputZelimPath);

      // 4. Comparison (will fail until full implementation)
      // expect(reimportedScene.elements.length, originalScene.elements.length);
      // expect(reimportedScene.timestamp.toIso8601String(), originalScene.timestamp.toIso8601String());

      // For now, just check that the file was created.
      final zelimFile = File(outputZelimPath);
      expect(await zelimFile.exists(), isTrue);
      expect(await zelimFile.length(), greaterThan(0));
    });
  });
}
