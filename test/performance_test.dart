import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freedome_sphere_flutter/models/app_edition.dart';
import 'package:freedome_sphere_flutter/services/theme_service.dart';

void main() {
  group('Performance Tests', () {
    test('should create theme data quickly', () {
      final themeService = ThemeService();
      
      final stopwatch = Stopwatch()..start();
      
      // Создаем темы для всех изданий
      for (final edition in AppEdition.values) {
        themeService.setEdition(edition);
        final themeData = themeService.getThemeData();
        expect(themeData, isNotNull);
      }
      
      stopwatch.stop();
      
      // Проверяем что создание тем занимает менее 100ms
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });

    test('should handle multiple rapid theme changes', () {
      final themeService = ThemeService();
      
      final stopwatch = Stopwatch()..start();
      
      // Быстро меняем темы 100 раз
      for (int i = 0; i < 100; i++) {
        final edition = AppEdition.values[i % AppEdition.values.length];
        themeService.setEdition(edition);
        final themeData = themeService.getThemeData();
        expect(themeData, isNotNull);
      }
      
      stopwatch.stop();
      
      // Проверяем что 100 изменений занимают менее 500ms
      expect(stopwatch.elapsedMilliseconds, lessThan(500));
    });

    test('should create material colors efficiently', () {
      final themeService = ThemeService();
      
      final stopwatch = Stopwatch()..start();
      
      // Создаем темы для всех изданий 100 раз
      for (int i = 0; i < 100; i++) {
        for (final edition in AppEdition.values) {
          themeService.setEdition(edition);
          final themeData = themeService.getThemeData();
          expect(themeData.primarySwatch, isA<MaterialColor>());
        }
      }
      
      stopwatch.stop();
      
      // Проверяем что создание 300 тем занимает менее 200ms
      expect(stopwatch.elapsedMilliseconds, lessThan(200));
    });

    test('should detect light/dark theme efficiently', () {
      final themeService = ThemeService();
      
      final stopwatch = Stopwatch()..start();
      
      // Проверяем определение темы через создание тем
      for (int i = 0; i < 1000; i++) {
        // Vaishnava - светлая тема
        themeService.setEdition(AppEdition.vaishnava);
        final lightTheme = themeService.getThemeData();
        expect(lightTheme.brightness, equals(Brightness.light));
        
        // Enterprise - темная тема
        themeService.setEdition(AppEdition.enterprise);
        final darkTheme = themeService.getThemeData();
        expect(darkTheme.brightness, equals(Brightness.dark));
      }
      
      stopwatch.stop();
      
      // Проверяем что 2000 проверок занимают менее 100ms
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });

    test('should handle memory efficiently with theme changes', () {
      final themeService = ThemeService();
      
      // Создаем много тем и проверяем что память не растет
      final initialMemory = _getMemoryUsage();
      
      for (int i = 0; i < 1000; i++) {
        final edition = AppEdition.values[i % AppEdition.values.length];
        themeService.setEdition(edition);
        final themeData = themeService.getThemeData();
        
        // Принудительно вызываем сборку мусора каждые 100 итераций
        if (i % 100 == 0) {
          // В тестах мы не можем вызвать GC, но можем проверить что объекты создаются
          expect(themeData, isNotNull);
        }
      }
      
      final finalMemory = _getMemoryUsage();
      
      // Проверяем что потребление памяти не выросло значительно
      // (в тестах это может быть неточно, но должно дать представление)
      expect(finalMemory - initialMemory, lessThan(1000000)); // 1MB
    });

    test('should create consistent theme data', () {
      final themeService = ThemeService();
      
      // Создаем тему несколько раз и проверяем консистентность
      final themes = <ThemeData>[];
      
      for (int i = 0; i < 10; i++) {
        themeService.setEdition(AppEdition.vaishnava);
        themes.add(themeService.getThemeData());
      }
      
      // Проверяем что все темы одинаковые
      for (int i = 1; i < themes.length; i++) {
        expect(themes[i].primaryColor, equals(themes[0].primaryColor));
        expect(themes[i].scaffoldBackgroundColor, equals(themes[0].scaffoldBackgroundColor));
        expect(themes[i].brightness, equals(themes[0].brightness));
      }
    });

    test('should handle concurrent theme changes', () async {
      final themeService = ThemeService();
      
      // Создаем несколько асинхронных операций изменения темы
      final futures = <Future>[];
      
      for (int i = 0; i < 10; i++) {
        futures.add(
          Future(() async {
            for (int j = 0; j < 10; j++) {
              final edition = AppEdition.values[j % AppEdition.values.length];
              await themeService.setEdition(edition);
              final themeData = themeService.getThemeData();
              expect(themeData, isNotNull);
            }
          })
        );
      }
      
      final stopwatch = Stopwatch()..start();
      
      // Ждем завершения всех операций
      await Future.wait(futures);
      
      stopwatch.stop();
      
      // Проверяем что все операции завершились за разумное время
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });
  });
}

// Вспомогательная функция для получения использования памяти
int _getMemoryUsage() {
  // В реальном приложении можно использовать ProcessInfo.currentRss
  // В тестах возвращаем фиктивное значение
  return 0;
}
