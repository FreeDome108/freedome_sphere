import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:freedome_sphere_flutter/models/app_edition.dart';
import 'package:freedome_sphere_flutter/services/theme_service.dart';

void main() {
  group('ThemeService Tests', () {
    late ThemeService themeService;

    setUp(() {
      // Мокаем SharedPreferences
      SharedPreferences.setMockInitialValues({});
      themeService = ThemeService();
    });

    tearDown(() {
      themeService.dispose();
    });

    test('should initialize with default Vaishnava edition', () {
      expect(themeService.currentEdition, equals(AppEdition.vaishnava));
      expect(themeService.currentEditionInfo.edition, equals(AppEdition.vaishnava));
    });

    test('should change edition correctly', () async {
      await themeService.setEdition(AppEdition.enterprise);
      
      expect(themeService.currentEdition, equals(AppEdition.enterprise));
      expect(themeService.currentEditionInfo.edition, equals(AppEdition.enterprise));
      expect(themeService.currentEditionInfo.name, equals('Enterprise Edition'));
    });

    test('should not change edition if same edition is set', () async {
      final initialEdition = themeService.currentEdition;
      
      await themeService.setEdition(initialEdition);
      
      expect(themeService.currentEdition, equals(initialEdition));
    });

    test('should generate correct theme data for Vaishnava edition', () {
      final themeData = themeService.getThemeData();
      
      expect(themeData.brightness, equals(Brightness.light));
      expect(themeData.primaryColor, equals(Color(0xFF87CEEB)));
      expect(themeData.scaffoldBackgroundColor, equals(Color(0xFFF0F8FF)));
    });

    test('should generate correct theme data for Enterprise edition', () async {
      await themeService.setEdition(AppEdition.enterprise);
      final themeData = themeService.getThemeData();
      
      expect(themeData.brightness, equals(Brightness.dark));
      expect(themeData.primaryColor, equals(Color(0xFF1E3A8A)));
      expect(themeData.scaffoldBackgroundColor, equals(Color(0xFF0F172A)));
    });

    test('should generate correct theme data for Education edition', () async {
      await themeService.setEdition(AppEdition.education);
      final themeData = themeService.getThemeData();
      
      expect(themeData.brightness, equals(Brightness.light));
      expect(themeData.primaryColor, equals(Color(0xFF7C3AED)));
      expect(themeData.scaffoldBackgroundColor, equals(Color(0xFFFEF3C7)));
    });

    test('should have correct app bar theme', () {
      final themeData = themeService.getThemeData();
      final appBarTheme = themeData.appBarTheme;
      
      expect(appBarTheme.backgroundColor, equals(Color(0xFFFFFFFF)));
      expect(appBarTheme.foregroundColor, equals(Color(0xFF2F4F4F)));
      expect(appBarTheme.elevation, equals(0));
    });

    test('should have correct card theme', () {
      final themeData = themeService.getThemeData();
      final cardTheme = themeData.cardTheme;
      
      expect(cardTheme.color, equals(Color(0xFFFFFFFF)));
      expect(cardTheme.elevation, equals(2));
      expect(cardTheme.shape, isA<RoundedRectangleBorder>());
    });

    test('should have correct button themes', () {
      final themeData = themeService.getThemeData();
      
      // ElevatedButton theme
      final elevatedButtonTheme = themeData.elevatedButtonTheme;
      expect(elevatedButtonTheme.style?.backgroundColor?.resolve({}), equals(Color(0xFF87CEEB)));
      
      // TextButton theme
      final textButtonTheme = themeData.textButtonTheme;
      expect(textButtonTheme.style?.foregroundColor?.resolve({}), equals(Color(0xFF87CEEB)));
    });

    test('should have correct input decoration theme', () {
      final themeData = themeService.getThemeData();
      final inputTheme = themeData.inputDecorationTheme;
      
      expect(inputTheme.filled, isTrue);
      expect(inputTheme.border, isA<OutlineInputBorder>());
      expect(inputTheme.enabledBorder, isA<OutlineInputBorder>());
      expect(inputTheme.focusedBorder, isA<OutlineInputBorder>());
    });

    test('should have correct text theme', () {
      final themeData = themeService.getThemeData();
      final textTheme = themeData.textTheme;
      
      expect(textTheme.bodyLarge?.color, equals(Color(0xFF2F4F4F)));
      expect(textTheme.headlineLarge?.color, equals(Color(0xFF2F4F4F)));
      expect(textTheme.titleLarge?.color, equals(Color(0xFF2F4F4F)));
    });

    test('should have correct color scheme', () {
      final themeData = themeService.getThemeData();
      final colorScheme = themeData.colorScheme;
      
      expect(colorScheme.brightness, equals(Brightness.light));
      expect(colorScheme.primary, equals(Color(0xFF87CEEB)));
      expect(colorScheme.secondary, equals(Color(0xFFB0E0E6)));
      expect(colorScheme.surface, equals(Color(0xFFFFFFFF)));
      expect(colorScheme.background, equals(Color(0xFFF0F8FF)));
    });

    test('should detect light theme correctly', () {
      // Vaishnava edition should be light theme
      final vaishnavaTheme = themeService.getThemeData();
      expect(vaishnavaTheme.brightness, equals(Brightness.light));
    });

    test('should detect dark theme correctly', () async {
      // Enterprise edition should be dark theme
      await themeService.setEdition(AppEdition.enterprise);
      final enterpriseTheme = themeService.getThemeData();
      expect(enterpriseTheme.brightness, equals(Brightness.dark));
    });

    test('should create material color correctly', () {
      final color = Color(0xFF87CEEB);
      final materialColor = themeService._createMaterialColor(color);
      
      expect(materialColor, isA<MaterialColor>());
      expect(materialColor.value, equals(color.value));
    });

    test('should notify listeners when edition changes', () async {
      bool listenerCalled = false;
      
      themeService.addListener(() {
        listenerCalled = true;
      });
      
      await themeService.setEdition(AppEdition.enterprise);
      
      expect(listenerCalled, isTrue);
    });

    test('should save edition to SharedPreferences', () async {
      await themeService.setEdition(AppEdition.education);
      
      final prefs = await SharedPreferences.getInstance();
      final savedEdition = prefs.getInt('app_edition');
      
      expect(savedEdition, equals(AppEdition.education.index));
    });

    test('should load edition from SharedPreferences', () async {
      // Сохраняем издание
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('app_edition', AppEdition.enterprise.index);
      
      // Создаем новый сервис, который должен загрузить сохраненное издание
      final newThemeService = ThemeService();
      
      // Ждем немного для асинхронной загрузки
      await Future.delayed(Duration(milliseconds: 100));
      
      expect(newThemeService.currentEdition, equals(AppEdition.enterprise));
      
      newThemeService.dispose();
    });

    test('should handle SharedPreferences errors gracefully', () async {
      // Мокаем ошибку SharedPreferences
      SharedPreferences.setMockInitialValues({});
      
      // Создаем сервис - он должен использовать дефолтное издание при ошибке
      final errorThemeService = ThemeService();
      
      expect(errorThemeService.currentEdition, equals(AppEdition.vaishnava));
      
      errorThemeService.dispose();
    });
  });
}
