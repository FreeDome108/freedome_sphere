import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_edition.dart';

class ThemeService extends ChangeNotifier {
  static const String _editionKey = 'app_edition';
  
  AppEdition _currentEdition = AppEdition.vaishnava;
  EditionInfo _currentEditionInfo = EditionInfo.editions[AppEdition.vaishnava]!;

  AppEdition get currentEdition => _currentEdition;
  EditionInfo get currentEditionInfo => _currentEditionInfo;

  ThemeService() {
    _loadSavedEdition();
  }

  Future<void> _loadSavedEdition() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final editionIndex = prefs.getInt(_editionKey) ?? AppEdition.vaishnava.index;
      _currentEdition = AppEdition.values[editionIndex];
      _currentEditionInfo = EditionInfo.getEditionInfo(_currentEdition);
      notifyListeners();
    } catch (e) {
      // Если ошибка, используем дефолтное издание
      _currentEdition = AppEdition.vaishnava;
      _currentEditionInfo = EditionInfo.editions[AppEdition.vaishnava]!;
    }
  }

  Future<void> setEdition(AppEdition edition) async {
    if (_currentEdition == edition) return;

    _currentEdition = edition;
    _currentEditionInfo = EditionInfo.getEditionInfo(edition);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_editionKey, edition.index);
    } catch (e) {
      // Игнорируем ошибки сохранения
    }
    
    notifyListeners();
  }

  ThemeData getThemeData() {
    final info = _currentEditionInfo;
    
    // Парсим цвета из строк
    Color primaryColor = Color(int.parse(info.primaryColor));
    Color secondaryColor = Color(int.parse(info.secondaryColor));
    Color backgroundColor = Color(int.parse(info.backgroundColor));
    Color surfaceColor = Color(int.parse(info.surfaceColor));
    Color textColor = Color(int.parse(info.textColor));
    Color accentColor = Color(int.parse(info.accentColor));

    // Определяем, светлая или темная тема
    bool isLightTheme = _isLightTheme(backgroundColor);

    return ThemeData(
      brightness: isLightTheme ? Brightness.light : Brightness.dark,
      primarySwatch: _createMaterialColor(primaryColor),
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: textColor,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: textColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: isLightTheme ? Colors.white : textColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isLightTheme ? Colors.grey[100] : Colors.grey[800],
        border: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        labelStyle: TextStyle(color: textColor.withOpacity(0.7)),
        hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: textColor),
        bodyMedium: TextStyle(color: textColor.withOpacity(0.8)),
        bodySmall: TextStyle(color: textColor.withOpacity(0.6)),
        headlineLarge: TextStyle(color: textColor),
        headlineMedium: TextStyle(color: textColor),
        headlineSmall: TextStyle(color: textColor),
        titleLarge: TextStyle(color: textColor),
        titleMedium: TextStyle(color: textColor),
        titleSmall: TextStyle(color: textColor.withOpacity(0.8)),
      ),
      colorScheme: ColorScheme(
        brightness: isLightTheme ? Brightness.light : Brightness.dark,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        error: Colors.red,
        onPrimary: isLightTheme ? Colors.white : textColor,
        onSecondary: isLightTheme ? Colors.white : textColor,
        onSurface: textColor,
        onError: Colors.white,
        background: backgroundColor,
        onBackground: textColor,
      ),
    );
  }

  bool _isLightTheme(Color backgroundColor) {
    // Простая проверка яркости цвета
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5;
  }

  MaterialColor _createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }
}
