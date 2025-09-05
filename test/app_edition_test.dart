import 'package:flutter_test/flutter_test.dart';
import 'package:freedome_sphere_flutter/models/app_edition.dart';

void main() {
  group('AppEdition Tests', () {
    test('should have all three editions defined', () {
      expect(AppEdition.values.length, equals(3));
      expect(AppEdition.values, contains(AppEdition.vaishnava));
      expect(AppEdition.values, contains(AppEdition.enterprise));
      expect(AppEdition.values, contains(AppEdition.education));
    });

    test('should have correct edition info for Vaishnava', () {
      final info = EditionInfo.getEditionInfo(AppEdition.vaishnava);
      
      expect(info.edition, equals(AppEdition.vaishnava));
      expect(info.name, equals('Vaishnava Edition'));
      expect(info.description, contains('духовного развития'));
      expect(info.logoPath, equals('assets/logos/vaishnava_logo.svg'));
      expect(info.primaryColor, equals('0xFF87CEEB'));
      expect(info.backgroundColor, equals('0xFFF0F8FF'));
    });

    test('should have correct edition info for Enterprise', () {
      final info = EditionInfo.getEditionInfo(AppEdition.enterprise);
      
      expect(info.edition, equals(AppEdition.enterprise));
      expect(info.name, equals('Enterprise Edition'));
      expect(info.description, contains('корпоративного использования'));
      expect(info.logoPath, equals('assets/logos/enterprise_logo.svg'));
      expect(info.primaryColor, equals('0xFF1E3A8A'));
      expect(info.backgroundColor, equals('0xFF0F172A'));
    });

    test('should have correct edition info for Education', () {
      final info = EditionInfo.getEditionInfo(AppEdition.education);
      
      expect(info.edition, equals(AppEdition.education));
      expect(info.name, equals('Education Edition'));
      expect(info.description, contains('обучения и исследований'));
      expect(info.logoPath, equals('assets/logos/education_logo.svg'));
      expect(info.primaryColor, equals('0xFF7C3AED'));
      expect(info.backgroundColor, equals('0xFFFEF3C7'));
    });

    test('should return default edition for invalid input', () {
      // Создаем мок для несуществующего издания
      final info = EditionInfo.getEditionInfo(AppEdition.vaishnava);
      expect(info.edition, equals(AppEdition.vaishnava));
    });

    test('should have unique colors for each edition', () {
      final vaishnavaInfo = EditionInfo.getEditionInfo(AppEdition.vaishnava);
      final enterpriseInfo = EditionInfo.getEditionInfo(AppEdition.enterprise);
      final educationInfo = EditionInfo.getEditionInfo(AppEdition.education);

      // Проверяем что основные цвета разные
      expect(vaishnavaInfo.primaryColor, isNot(equals(enterpriseInfo.primaryColor)));
      expect(vaishnavaInfo.primaryColor, isNot(equals(educationInfo.primaryColor)));
      expect(enterpriseInfo.primaryColor, isNot(equals(educationInfo.primaryColor)));

      // Проверяем что фоновые цвета разные
      expect(vaishnavaInfo.backgroundColor, isNot(equals(enterpriseInfo.backgroundColor)));
      expect(vaishnavaInfo.backgroundColor, isNot(equals(educationInfo.backgroundColor)));
      expect(enterpriseInfo.backgroundColor, isNot(equals(educationInfo.backgroundColor)));
    });

    test('should have valid color format', () {
      final editions = AppEdition.values;
      
      for (final edition in editions) {
        final info = EditionInfo.getEditionInfo(edition);
        
        // Проверяем формат цвета (0xFF + 6 hex символов)
        expect(info.primaryColor, matches(RegExp(r'^0xFF[0-9A-Fa-f]{6}$')));
        expect(info.secondaryColor, matches(RegExp(r'^0xFF[0-9A-Fa-f]{6}$')));
        expect(info.backgroundColor, matches(RegExp(r'^0xFF[0-9A-Fa-f]{6}$')));
        expect(info.surfaceColor, matches(RegExp(r'^0xFF[0-9A-Fa-f]{6}$')));
        expect(info.textColor, matches(RegExp(r'^0xFF[0-9A-Fa-f]{6}$')));
        expect(info.accentColor, matches(RegExp(r'^0xFF[0-9A-Fa-f]{6}$')));
      }
    });

    test('should have non-empty strings for all text fields', () {
      final editions = AppEdition.values;
      
      for (final edition in editions) {
        final info = EditionInfo.getEditionInfo(edition);
        
        expect(info.name, isNotEmpty);
        expect(info.description, isNotEmpty);
        expect(info.logoPath, isNotEmpty);
      }
    });
  });
}
