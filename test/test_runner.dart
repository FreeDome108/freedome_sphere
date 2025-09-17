import 'package:flutter_test/flutter_test.dart';

// Импортируем все тесты
import 'app_edition_test.dart' as app_edition_test;
import 'theme_service_test.dart' as theme_service_test;
import 'widget_test.dart' as widget_test;
import 'performance_test.dart' as performance_test;
import 'comics_import_test.dart' as comics_import_test;

void main() {
  group('Freedome Sphere Test Suite', () {
    group('App Edition Tests', () {
      app_edition_test.main();
    });

    group('Theme Service Tests', () {
      theme_service_test.main();
    });

    group('Widget Tests', () {
      widget_test.main();
    });

    group('Performance Tests', () {
      performance_test.main();
    });

    group('Comics Import Tests', () {
      comics_import_test.main();
    });
  });
}
