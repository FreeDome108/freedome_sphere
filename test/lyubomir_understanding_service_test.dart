
import 'package:flutter_test/flutter_test.dart';
import 'package:freedome_sphere_flutter/models/lyubomir_understanding.dart';
import 'package:freedome_sphere_flutter/services/lyubomir_understanding_service.dart';

void main() {
  group('LyubomirUnderstandingService', () {
    late LyubomirUnderstandingService service;

    setUp(() {
      service = LyubomirUnderstandingService();
    });

    test('initializes with default values', () {
      expect(service.isEnabled, isFalse);
      expect(service.settings.enabled, isFalse);
      expect(service.settings.enabledTypes, isEmpty);
      expect(service.understandings, isEmpty);
    });

    test('updateSettings updates the settings and isEnabled flag', () {
      final newSettings = LyubomirSettings(
        enabled: true,
        enabledTypes: [UnderstandingType.visual, UnderstandingType.audio],
      );

      service.updateSettings(newSettings);

      expect(service.isEnabled, isTrue);
      expect(service.settings, newSettings);
    });

    test('updateSettings notifies listeners', () {
      bool notified = false;
      service.addListener(() {
        notified = true;
      });

      final newSettings = LyubomirSettings(
        enabled: true,
        enabledTypes: [UnderstandingType.visual],
      );

      service.updateSettings(newSettings);

      expect(notified, isTrue);
    });
  });
}
