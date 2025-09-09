
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

      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should display edition selector', (WidgetTester tester) async {
      final themeService = ThemeService();
      await themeService.init();

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
      
      await tester.pumpAndSettle();

      expect(find.byType(EditionSelector), findsOneWidget);
      expect(find.byType(PopupMenuButton<AppEdition>), findsOneWidget);
    });

    testWidgets('should change theme when edition is selected', (WidgetTester tester) async {
      final themeService = ThemeService();
      await themeService.init();
      
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

      await tester.pumpAndSettle();

      final dropdown = find.byType(PopupMenuButton<AppEdition>);
      expect(dropdown, findsOneWidget);

      await tester.tap(dropdown);
      await tester.pumpAndSettle();

      final enterpriseOption = find.text('Enterprise Edition').last;
      expect(enterpriseOption, findsOneWidget);
      
      await tester.tap(enterpriseOption);
      await tester.pumpAndSettle();

      expect(themeService.currentEdition, equals(AppEdition.enterprise));
    });

    testWidgets('should display correct colors for different editions', (WidgetTester tester) async {
      final themeService = ThemeService();
      await themeService.init();
      
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

      await tester.pumpAndSettle();

      Material appBarMaterial = tester.widget<Material>(find.descendant(
        of: find.byType(AppBar),
        matching: find.byType(Material),
      ));
      expect(appBarMaterial.color, themeService.getThemeData().appBarTheme.backgroundColor);
      
      await themeService.setEdition(AppEdition.enterprise);
      await tester.pumpAndSettle();
      
      expect(themeService.currentEdition, equals(AppEdition.enterprise));

      appBarMaterial = tester.widget<Material>(find.descendant(
        of: find.byType(AppBar),
        matching: find.byType(Material),
      ));
      expect(appBarMaterial.color, themeService.getThemeData().appBarTheme.backgroundColor);
    });

    testWidgets('should persist theme selection', (WidgetTester tester) async {
      final themeService = ThemeService();
      await themeService.init();

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

      await themeService.setEdition(AppEdition.education);
      await tester.pumpAndSettle();

      expect(themeService.currentEdition, equals(AppEdition.education));

      final newThemeService = ThemeService();
      await newThemeService.init();
      await tester.pumpAndSettle();
      expect(newThemeService.currentEdition, equals(AppEdition.education));
    });

    testWidgets('should display all edition options', (WidgetTester tester) async {
       final themeService = ThemeService();
      await themeService.init();
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

      final dropdown = find.byType(PopupMenuButton<AppEdition>);
      await tester.tap(dropdown);
      await tester.pumpAndSettle();

      expect(find.text('Vaishnava Edition').last, findsOneWidget);
      expect(find.text('Enterprise Edition').last, findsOneWidget);
      expect(find.text('Education Edition').last, findsOneWidget);
    });

    testWidgets('should handle theme service disposal', (WidgetTester tester) async {
      final themeService = ThemeService();
      await themeService.init();
      
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

      expect(themeService.currentEdition, equals(AppEdition.vaishnava));
      
      await tester.pumpWidget(Container());
    });
  });

  group('Theme Integration Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('should apply correct theme colors to all components', (WidgetTester tester) async {
      final themeService = ThemeService();
      await themeService.init();
      
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

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      
      await themeService.setEdition(AppEdition.enterprise);
      await tester.pumpAndSettle();
      
      expect(themeService.currentEdition, equals(AppEdition.enterprise));
      final appBarMaterial = tester.widget<Material>(find.descendant(
        of: find.byType(AppBar),
        matching: find.byType(Material),
      ));
      expect(appBarMaterial.color, themeService.getThemeData().appBarTheme.backgroundColor);
    });

    testWidgets('should handle rapid theme changes', (WidgetTester tester) async {
      final themeService = ThemeService();
      await themeService.init();
      
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

      await themeService.setEdition(AppEdition.enterprise);
      await tester.pump();
      
      await themeService.setEdition(AppEdition.education);
      await tester.pump();
      
      await themeService.setEdition(AppEdition.vaishnava);
      await tester.pumpAndSettle();
      
      expect(themeService.currentEdition, equals(AppEdition.vaishnava));
    });
  });
}
