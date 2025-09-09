
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:freedome_sphere_flutter/services/locale_service.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocaleService', () {
    late LocaleService localeService;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      localeService = LocaleService();
    });

    test('loadLocale loads the locale', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_locale', 'ru');

      await localeService.loadLocale();

      expect(localeService.currentLocale, const Locale('ru'));
    });

    test('setLocale sets the locale', () async {
      await localeService.setLocale(const Locale('ru'));

      final prefs = await SharedPreferences.getInstance();
      final localeCode = prefs.getString('selected_locale');

      expect(localeService.currentLocale, const Locale('ru'));
      expect(localeCode, 'ru');
    });
  });
}
