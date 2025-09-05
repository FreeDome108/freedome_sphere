import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleService extends ChangeNotifier {
  static const String _localeKey = 'selected_locale';
  
  Locale _currentLocale = const Locale('en');
  
  Locale get currentLocale => _currentLocale;
  
  static const List<Locale> supportedLocales = [
    Locale('en', ''), // English
    Locale('ru', ''), // Russian
    Locale('th', ''), // Thai
    Locale('hi', ''), // Hindi
  ];
  
  static const Map<String, String> localeNames = {
    'en': 'English',
    'ru': 'Русский',
    'th': 'ไทย',
    'hi': 'हिन्दी',
  };
  
  Future<void> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final localeCode = prefs.getString(_localeKey) ?? 'en';
    _currentLocale = Locale(localeCode);
    notifyListeners();
  }
  
  Future<void> setLocale(Locale locale) async {
    if (!supportedLocales.contains(locale)) return;
    
    _currentLocale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
    notifyListeners();
  }
  
  String getLocaleName(String languageCode) {
    return localeNames[languageCode] ?? languageCode;
  }
}
