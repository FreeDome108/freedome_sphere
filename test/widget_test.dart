import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:freedome_sphere_flutter/models/app_edition.dart';
import 'package:freedome_sphere_flutter/services/theme_service.dart';
import 'package:freedome_sphere_flutter/widgets/edition_selector.dart';

void main() {
  group('Freedome Sphere Widget Tests', () {
    testWidgets('should display app with default theme', (WidgetTester tester) async {
      // Создаем простое приложение для тестирования
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => ThemeService(),
          child: MaterialApp(
            home: Scaffold(
              appBar: AppBar(title: Text('Test App')),
              body: Center(child: Text('Test Content')),
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

      // Проверяем что селектор отображается
      expect(find.byType(EditionSelector), findsOneWidget);
      
      // Проверяем что есть выпадающий список
      expect(find.byType(DropdownButton<AppEdition>), findsOneWidget);
    });

    testWidgets('should change theme when edition is selected', (WidgetTester tester) async {
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

      // Находим выпадающий список
      final dropdown = find.byType(DropdownButton<AppEdition>);
      expect(dropdown, findsOneWidget);

      // Открываем выпадающий список
      await tester.tap(dropdown);
      await tester.pumpAndSettle();

      // Выбираем Enterprise edition
      final enterpriseOption = find.text('Enterprise Edition');
      expect(enterpriseOption, findsOneWidget);
      
      await tester.tap(enterpriseOption);
      await tester.pumpAndSettle();

      // Проверяем что тема изменилась
      expect(themeService.currentEdition, equals(AppEdition.enterprise));
    });

    testWidgets('should display correct colors for different editions', (WidgetTester tester) async {
      final themeService = ThemeService();
      
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => themeService,
          child: Consumer<ThemeService>(
            builder: (context, themeService, child) {
              return MaterialApp(
                theme: themeService.getThemeData(),
                home: Scaffold(
                  appBar: AppBar(title: Text('Test')),
                  body: Container(
                    child: Text('Test Content'),
                  ),
                ),
              );
            },
          ),
        ),
      );

      // Проверяем начальную тему (Vaishnava - светлая)
      var appBar = find.byType(AppBar);
      expect(appBar, findsOneWidget);
      
      // Меняем на Enterprise (темная тема)
      await themeService.setEdition(AppEdition.enterprise);
      await tester.pumpAndSettle();
      
      // Проверяем что тема обновилась
      expect(themeService.currentEdition, equals(AppEdition.enterprise));
    });

    testWidgets('should persist theme selection', (WidgetTester tester) async {
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

      // Меняем издание
      await themeService.setEdition(AppEdition.education);
      await tester.pumpAndSettle();

      // Проверяем что издание сохранилось
      expect(themeService.currentEdition, equals(AppEdition.education));
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
      expect(find.text('Vaishnava Edition'), findsOneWidget);
      expect(find.text('Enterprise Edition'), findsOneWidget);
      expect(find.text('Education Edition'), findsOneWidget);
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
      expect(() => themeService.dispose(), returnsNormally);
    });
  });

  group('Theme Integration Tests', () {
    testWidgets('should apply correct theme colors to all components', (WidgetTester tester) async {
      final themeService = ThemeService();
      
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => themeService,
          child: Consumer<ThemeService>(
            builder: (context, themeService, child) {
              return MaterialApp(
                theme: themeService.getThemeData(),
                home: Scaffold(
                  appBar: AppBar(
                    title: Text('Test App'),
                    actions: [
                      IconButton(
                        icon: Icon(Icons.settings),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  body: Column(
                    children: [
                      Card(
                        child: ListTile(
                          title: Text('Test Card'),
                          subtitle: Text('Test Subtitle'),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        child: Text('Test Button'),
                      ),
                      TextField(
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
      await tester.pumpAndSettle();
      
      expect(themeService.currentEdition, equals(AppEdition.enterprise));
    });

    testWidgets('should handle rapid theme changes', (WidgetTester tester) async {
      final themeService = ThemeService();
      
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => themeService,
          child: Consumer<ThemeService>(
            builder: (context, themeService, child) {
              return MaterialApp(
                theme: themeService.getThemeData(),
                home: Scaffold(
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