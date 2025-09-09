
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:freedome_sphere_flutter/models/app_edition.dart';
import 'package:freedome_sphere_flutter/services/theme_service.dart';
import 'package:freedome_sphere_flutter/widgets/edition_selector.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Freedome Sphere Widget Tests', () {
    
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('should display app with default theme', (WidgetTester tester) async {
      // Создаем простое приложение для тестирования
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => ThemeService(),
          child: MaterialApp(
            home: Scaffold(
              appBar: AppBar(title: const Text('Test App')),
              body: const Center(child: Text('Test Content')),
            ),
          ),
        ),
      );

      // Проверяем что приложение запустилось
      expect(find.byType(MaterialApp), findsOneWidget);
      
      // Проверяем что есть основной экран
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should display edition selector', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => ThemeService(),
          child: MaterialApp(
            home: Scaffold(
              body: EditionSelector(),
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle(const Duration(seconds: 1)); // Let the widget tree build

      // Проверяем что селектор отображается
      expect(find.byType(EditionSelector), findsOneWidget);
      
      // Проверяем что есть выпадающий список
      expect(find.byType(DropdownButton<AppEdition>), findsOneWidget);
    });

    testWidgets('should change theme when edition is selected', (WidgetTester tester) async {
      final themeService = ThemeService();
      
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: themeService,
          child: Consumer<ThemeService>(
            builder: (context, service, child) {
              return MaterialApp(
                theme: service.getThemeData(),
                home: Scaffold(
                  body: EditionSelector(),
                ),
              );
            }
          ),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Находим выпадающий список
      final dropdown = find.byType(DropdownButton<AppEdition>);
      expect(dropdown, findsOneWidget);

      // Открываем выпадающий список
      await tester.tap(dropdown);
      await tester.pumpAndSettle();

      // Выбираем Enterprise edition
      // We need to find the text inside the DropdownMenuItem
      final enterpriseOption = find.text('Enterprise Edition').last;
      expect(enterpriseOption, findsOneWidget);
      
      await tester.tap(enterpriseOption);
      await tester.pumpAndSettle();

      // Проверяем что тема изменилась
      expect(themeService.currentEdition, equals(AppEdition.enterprise));
    });

    testWidgets('should display correct colors for different editions', (WidgetTester tester) async {
      final themeService = ThemeService();
      
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: themeService,
          child: Consumer<ThemeService>(
            builder: (context, themeService, child) {
              return MaterialApp(
                theme: themeService.getThemeData(),
                home: Scaffold(
                  appBar: AppBar(title: const Text('Test')),
                  body: Container(
                    child: const Text('Test Content'),
                  ),
                ),
              );
            },
          ),
        ),
      );

      // Проверяем начальную тему (Vaishnava - светлая)
      var appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.backgroundColor, themeService.getThemeData().primaryColor);
      
      // Меняем на Enterprise (темная тема)
      await themeService.setEdition(AppEdition.enterprise);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      
      // Проверяем что тема обновилась
      expect(themeService.currentEdition, equals(AppEdition.enterprise));
      appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.backgroundColor, themeService.getThemeData().primaryColor);
    });

    testWidgets('should persist theme selection', (WidgetTester tester) async {
      final themeService = ThemeService();

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: themeService,
          child: MaterialApp(
            home: Scaffold(
              body: EditionSelector(),
            ),
          ),
        ),
      );

      // Меняем издание
      await themeService.setEdition(AppEdition.education);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Проверяем что издание сохранилось
      expect(themeService.currentEdition, equals(AppEdition.education));

      // Create a new service to check persistence
      final newThemeService = ThemeService();
      await tester.pumpAndSettle(const Duration(seconds: 1));
      expect(newThemeService.currentEdition, equals(AppEdition.education));
    });

    testWidgets('should display all edition options', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => ThemeService(),
          child: MaterialApp(
            home: Scaffold(
              body: EditionSelector(),
            ),
          ),
        ),
      );

      // Открываем выпадающий список
      final dropdown = find.byType(DropdownButton<AppEdition>);
      await tester.tap(dropdown);
      await tester.pumpAndSettle();

      // Проверяем что все опции отображаются
      expect(find.text('Vaishnava Edition').last, findsOneWidget);
      expect(find.text('Enterprise Edition').last, findsOneWidget);
      expect(find.text('Education Edition').last, findsOneWidget);
    });

    testWidgets('should handle theme service disposal', (WidgetTester tester) async {
      final themeService = ThemeService();
      
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => themeService,
          child: MaterialApp(
            home: Scaffold(
              body: EditionSelector(),
            ),
          ),
        ),
      );

      // Проверяем что сервис работает
      expect(themeService.currentEdition, equals(AppEdition.vaishnava));
      
      // Удаляем виджет
      await tester.pumpWidget(Container());
      
      // Сервис должен быть доступен для dispose
      themeService.dispose();
    });
  });

  group('Theme Integration Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('should apply correct theme colors to all components', (WidgetTester tester) async {
      final themeService = ThemeService();
      
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: themeService,
          child: Consumer<ThemeService>(
            builder: (context, themeService, child) {
              return MaterialApp(
                theme: themeService.getThemeData(),
                home: Scaffold(
                  appBar: AppBar(
                    title: const Text('Test App'),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.settings),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  body: Column(
                    children: [
                      const Card(
                        child: ListTile(
                          title: Text('Test Card'),
                          subtitle: Text('Test Subtitle'),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        child: const Text('Test Button'),
                      ),
                      const TextField(
                        decoration: InputDecoration(
                          labelText: 'Test Input',
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );

      // Проверяем что все компоненты отображаются
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      
      // Меняем тему и проверяем что все обновилось
      await themeService.setEdition(AppEdition.enterprise);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      
      expect(themeService.currentEdition, equals(AppEdition.enterprise));
      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.backgroundColor, themeService.getThemeData().primaryColor);
    });

    testWidgets('should handle rapid theme changes', (WidgetTester tester) async {
      final themeService = ThemeService();
      
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: themeService,
          child: Consumer<ThemeService>(
            builder: (context, themeService, child) {
              return MaterialApp(
                theme: themeService.getThemeData(),
                home: const Scaffold(
                  body: Center(
                    child: Text('Rapid Theme Test'),
                  ),
                ),
              );
            },
          ),
        ),
      );

      // Быстро меняем темы
      await themeService.setEdition(AppEdition.enterprise);
      await tester.pump();
      
      await themeService.setEdition(AppEdition.education);
      await tester.pump();
      
      await themeService.setEdition(AppEdition.vaishnava);
      await tester.pumpAndSettle();
      
      // Проверяем что финальная тема корректная
      expect(themeService.currentEdition, equals(AppEdition.vaishnava));
    });
  });
}
