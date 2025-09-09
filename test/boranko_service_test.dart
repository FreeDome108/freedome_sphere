
import 'package:flutter_test/flutter_test.dart';
import 'package:freedome_sphere_flutter/services/boranko_service.dart';
import 'package:freedome_sphere_flutter/models/boranko_project.dart';

void main() {
  group('BorankoService', () {
    late BorankoService borankoService;

    setUp(() {
      borankoService = BorankoService();
    });

    test('importBorankoProject imports a project', () async {
      final project = await borankoService.importBorankoProject('/path/to/dummy/project');
      expect(project, isA<BorankoProject>());
      expect(project.name, 'Dummy Boranko Project');
    });
  });
}
