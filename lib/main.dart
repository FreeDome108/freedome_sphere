
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n/app_localizations.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/project_service.dart';
import 'services/theme_service.dart';
import 'services/locale_service.dart';
import 'services/anantasound_service.dart';
import 'services/unreal_optimizer_service.dart';
import 'services/boranko_service.dart';
import 'services/aibasic_ide_service.dart';
import 'services/unreal_plugin_integration_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final themeService = ThemeService();
  await themeService.init();

  final prefs = await SharedPreferences.getInstance();
  final seenOnboarding = prefs.getBool('seenOnboarding') ?? false;

  runApp(FreedomeSphereApp(themeService: themeService, seenOnboarding: seenOnboarding));
}

class FreedomeSphereApp extends StatelessWidget {
  final ThemeService themeService;
  final bool seenOnboarding;

  const FreedomeSphereApp({super.key, required this.themeService, required this.seenOnboarding});

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
        ChangeNotifierProvider<UnrealOptimizerService>(
          create: (_) => UnrealOptimizerService(),
        ),
        ChangeNotifierProvider<AIBasicIDEService>(
          create: (_) => AIBasicIDEService(),
        ),
        ChangeNotifierProvider<UnrealPluginIntegrationService>(
          create: (_) => UnrealPluginIntegrationService(),
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
            home: seenOnboarding ? const HomeScreen() : const OnboardingScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
