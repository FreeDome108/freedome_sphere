
import 'package:flutter_test/flutter_test.dart';
import 'package:freedome_sphere_flutter/services/collada_service.dart';
import 'dart:io';

void main() {
  group('Format Conversion', () {
    final colladaService = ColladaService();

    test('COLLADA import test', () async {
      const samplePath = 'samples/import/collada/angel_sphere/angel.dae';

      // 1. Import from COLLADA
      final scene = await colladaService.importCollada(samplePath);

      // 2. Check that the scene is not null
      expect(scene, isNotNull);
    });
  });
}
