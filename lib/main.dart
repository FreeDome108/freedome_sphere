import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'services/project_service.dart';
import 'services/theme_service.dart';

void main() {
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
        Provider<ProjectService>(
          create: (_) => ProjectService(),
        ),
      ],
      child: Consumer<ThemeService>(
        builder: (context, themeService, child) {
          return MaterialApp(
            title: 'Freedome Sphere',
            theme: themeService.getThemeData(),
            home: const HomeScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}