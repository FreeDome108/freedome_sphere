
import 'package:flutter_test/flutter_test.dart';
import 'package:freedome_sphere_flutter/services/freedome_learning_service.dart';

void main() {
  group('FreedomeLearningService', () {
    late FreedomeLearningService freedomeLearningService;

    setUp(() {
      freedomeLearningService = FreedomeLearningService();
    });

    test('service is created', () {
      expect(freedomeLearningService, isNotNull);
    });
  });
}
