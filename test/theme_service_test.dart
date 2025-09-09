
import 'package:flutter_test/flutter_test.dart';
import 'package:freedome_sphere_flutter/models/app_edition.dart';
import 'package:freedome_sphere_flutter/services/theme_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ThemeService', () {
    late ThemeService themeService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      themeService = ThemeService();
      await themeService.init();
    });

    test('initializes with default theme', () {
      expect(themeService.currentEdition, AppEdition.vaishnava);
    });

    test('setEdition updates the theme', () async {
      await themeService.setEdition(AppEdition.enterprise);
      expect(themeService.currentEdition, AppEdition.enterprise);
    });

    test('setEdition persists the theme', () async {
      await themeService.setEdition(AppEdition.education);
      final newThemeService = ThemeService();
      await newThemeService.init();
      expect(newThemeService.currentEdition, AppEdition.education);
    });
  });
}
