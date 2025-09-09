import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';
import 'screens/home_screen.dart';
import 'services/project_service.dart';
import 'services/theme_service.dart';
import 'services/locale_service.dart';
import 'services/anantasound_service.dart';
import 'services/lyubomir_understanding_service.dart';
import 'services/boranko_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final themeService = ThemeService();
  await themeService.init();

  runApp(FreedomeSphereApp(themeService: themeService));
}

class FreedomeSphereApp extends StatelessWidget {
  final ThemeService themeService;

  const FreedomeSphereApp({super.key, required this.themeService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeService>.value(
          value: themeService,
        ),
        ChangeNotifierProvider<LocaleService>(
          create: (_) => LocaleService()..loadLocale(),
        ),
        Provider<ProjectService>(
          create: (_) => ProjectService(),
        ),
        Provider<BorankoService>(
          create: (_) => BorankoService(),
        ),
        ChangeNotifierProvider<AnantaSoundService>(
          create: (_) => AnantaSoundService(),
        ),
        ChangeNotifierProvider<LyubomirUnderstandingService>(
          create: (_) => LyubomirUnderstandingService(),
        ),
      ],
      child: Consumer2<ThemeService, LocaleService>(
        builder: (context, themeService, localeService, child) {
          return MaterialApp(
            title: 'Freedome Sphere',
            theme: themeService.getThemeData(),
            locale: localeService.currentLocale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: LocaleService.supportedLocales,
            home: const HomeScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
