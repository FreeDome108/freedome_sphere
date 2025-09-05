import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'screens/home_screen.dart';
import 'services/project_service.dart';
import 'services/theme_service.dart';
import 'services/locale_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FreedomeSphereApp());
}

class FreedomeSphereApp extends StatelessWidget {
  const FreedomeSphereApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeService>(
          create: (_) => ThemeService(),
        ),
        ChangeNotifierProvider<LocaleService>(
          create: (_) => LocaleService()..loadLocale(),
        ),
        Provider<ProjectService>(
          create: (_) => ProjectService(),
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