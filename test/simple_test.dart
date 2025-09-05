import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freedome_sphere_flutter/models/app_edition.dart';
import 'package:freedome_sphere_flutter/services/theme_service.dart';

void main() {
  group('Simple Freedome Sphere Tests', () {
    test('should create theme service', () {
      final themeService = ThemeService();
      expect(themeService, isNotNull);
      expect(themeService.currentEdition, equals(AppEdition.vaishnava));
    });

    test('should change edition', () async {
      final themeService = ThemeService();
      
      await themeService.setEdition(AppEdition.enterprise);
      expect(themeService.currentEdition, equals(AppEdition.enterprise));
      
      await themeService.setEdition(AppEdition.education);
      expect(themeService.currentEdition, equals(AppEdition.education));
    });

    test('should generate theme data', () {
      final themeService = ThemeService();
      final themeData = themeService.getThemeData();
      
      expect(themeData, isNotNull);
      expect(themeData.primaryColor, equals(Color(0xFF87CEEB)));
      expect(themeData.brightness, equals(Brightness.light));
    });

    test('should have all editions defined', () {
      expect(AppEdition.values.length, equals(3));
      expect(AppEdition.values, contains(AppEdition.vaishnava));
      expect(AppEdition.values, contains(AppEdition.enterprise));
      expect(AppEdition.values, contains(AppEdition.education));
    });

    test('should have correct edition info', () {
      final vaishnavaInfo = EditionInfo.getEditionInfo(AppEdition.vaishnava);
      expect(vaishnavaInfo.name, equals('Vaishnava Edition'));
      
      final enterpriseInfo = EditionInfo.getEditionInfo(AppEdition.enterprise);
      expect(enterpriseInfo.name, equals('Enterprise Edition'));
      
      final educationInfo = EditionInfo.getEditionInfo(AppEdition.education);
      expect(educationInfo.name, equals('Education Edition'));
    });
  });
}
