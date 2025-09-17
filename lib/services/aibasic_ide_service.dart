import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Сервис для работы с локальной средой разработки AIBASIC
class AIBasicIDEService extends ChangeNotifier {
  static const String _prefsKey = 'aibasic_ide_settings';
  
  // Настройки IDE
  String _currentLanguage = 'en';
  String _theme = 'dark';
  bool _autoSave = true;
  bool _syntaxHighlighting = true;
  bool _autoComplete = true;
  bool _lineNumbers = true;
  bool _wordWrap = true;
  int _fontSize = 14;
  String _fontFamily = 'monospace';
  
  // Состояние редактора
  String _currentFile = '';
  String _currentContent = '';
  List<String> _recentFiles = [];
  List<String> _openFiles = [];
  Map<String, String> _fileContents = {};
  
  // История команд
  List<String> _commandHistory = [];
  int _historyIndex = -1;
  
  // Локализованные команды
  final Map<String, Map<String, String>> _localizedCommands = {
    'en': {
      'LET': 'LET',
      'PRINT': 'PRINT',
      'GOTO': 'GOTO',
      'FOR': 'FOR',
      'NEXT': 'NEXT',
      'IF': 'IF',
      'THEN': 'THEN',
      'ELSE': 'ELSE',
      'DIM': 'DIM',
      'DATA': 'DATA',
      'READ': 'READ',
      'RESTORE': 'RESTORE',
      'RANDOMIZE': 'RANDOMIZE',
      'INPUT': 'INPUT',
      'REM': 'REM',
      'CLS': 'CLS',
      'BORDER': 'BORDER',
      'INK': 'INK',
      'PAPER': 'PAPER',
      'FLASH': 'FLASH',
      'BRIGHT': 'BRIGHT',
      'INVERSE': 'INVERSE',
      'OVER': 'OVER',
      'PLOT': 'PLOT',
      'DRAW': 'DRAW',
      'CIRCLE': 'CIRCLE',
      'SOUND': 'SOUND',
      'BEEP': 'BEEP',
      'PEEK': 'PEEK',
      'POKE': 'POKE',
    },
    'ru': {
      'LET': 'ПУСТЬ',
      'PRINT': 'ПЕЧАТЬ',
      'GOTO': 'ПЕРЕЙТИ',
      'FOR': 'ДЛЯ',
      'NEXT': 'ДАЛЕЕ',
      'IF': 'ЕСЛИ',
      'THEN': 'ТО',
      'ELSE': 'ИНАЧЕ',
      'DIM': 'РАЗМЕР',
      'DATA': 'ДАННЫЕ',
      'READ': 'ЧИТАТЬ',
      'RESTORE': 'ВОССТАНОВИТЬ',
      'RANDOMIZE': 'СЛУЧАЙНО',
      'INPUT': 'ВВОД',
      'REM': 'КОММЕНТАРИЙ',
      'CLS': 'ОЧИСТИТЬ',
      'BORDER': 'РАМКА',
      'INK': 'ЧЕРНИЛА',
      'PAPER': 'БУМАГА',
      'FLASH': 'МИГАНИЕ',
      'BRIGHT': 'ЯРКОСТЬ',
      'INVERSE': 'ОБРАТНЫЙ',
      'OVER': 'ПОВЕРХ',
      'PLOT': 'ТОЧКА',
      'DRAW': 'РИСОВАТЬ',
      'CIRCLE': 'КРУГ',
      'SOUND': 'ЗВУК',
      'BEEP': 'СИГНАЛ',
      'PEEK': 'ПРОСМОТР',
      'POKE': 'ЗАПИСАТЬ',
    },
    'de': {
      'LET': 'LASSEN',
      'PRINT': 'DRUCKEN',
      'GOTO': 'GEHE_ZU',
      'FOR': 'FÜR',
      'NEXT': 'NÄCHSTE',
      'IF': 'WENN',
      'THEN': 'DANN',
      'ELSE': 'SONST',
      'DIM': 'DIMENSION',
      'DATA': 'DATEN',
      'READ': 'LESEN',
      'RESTORE': 'WIEDERHERSTELLEN',
      'RANDOMIZE': 'ZUFÄLLIG',
      'INPUT': 'EINGABE',
      'REM': 'KOMMENTAR',
      'CLS': 'LÖSCHEN',
      'BORDER': 'RAHMEN',
      'INK': 'TINTE',
      'PAPER': 'PAPIER',
      'FLASH': 'BLINKEN',
      'BRIGHT': 'HELLIGKEIT',
      'INVERSE': 'UMGEKEHRT',
      'OVER': 'ÜBER',
      'PLOT': 'PUNKT',
      'DRAW': 'ZEICHNEN',
      'CIRCLE': 'KREIS',
      'SOUND': 'TON',
      'BEEP': 'SIGNAL',
      'PEEK': 'EINBLICK',
      'POKE': 'SCHREIBEN',
    },
    'ar': {
      'LET': 'دع',
      'PRINT': 'اطبع',
      'GOTO': 'اذهب_إلى',
      'FOR': 'لـ',
      'NEXT': 'التالي',
      'IF': 'إذا',
      'THEN': 'ثم',
      'ELSE': 'وإلا',
      'DIM': 'البعد',
      'DATA': 'البيانات',
      'READ': 'اقرأ',
      'RESTORE': 'استعادة',
      'RANDOMIZE': 'عشوائي',
      'INPUT': 'إدخال',
      'REM': 'تعليق',
      'CLS': 'مسح',
      'BORDER': 'حدود',
      'INK': 'حبر',
      'PAPER': 'ورق',
      'FLASH': 'وميض',
      'BRIGHT': 'سطوع',
      'INVERSE': 'عكسي',
      'OVER': 'فوق',
      'PLOT': 'نقطة',
      'DRAW': 'رسم',
      'CIRCLE': 'دائرة',
      'SOUND': 'صوت',
      'BEEP': 'إشارة',
      'PEEK': 'نظرة',
      'POKE': 'كتابة',
    },
    'pt': {
      'LET': 'DEIXAR',
      'PRINT': 'IMPRIMIR',
      'GOTO': 'IR_PARA',
      'FOR': 'PARA',
      'NEXT': 'PRÓXIMO',
      'IF': 'SE',
      'THEN': 'ENTÃO',
      'ELSE': 'SENÃO',
      'DIM': 'DIMENSÃO',
      'DATA': 'DADOS',
      'READ': 'LER',
      'RESTORE': 'RESTAURAR',
      'RANDOMIZE': 'ALEATÓRIO',
      'INPUT': 'ENTRADA',
      'REM': 'COMENTÁRIO',
      'CLS': 'LIMPAR',
      'BORDER': 'BORDA',
      'INK': 'TINTA',
      'PAPER': 'PAPEL',
      'FLASH': 'PISCAR',
      'BRIGHT': 'BRILHO',
      'INVERSE': 'INVERSO',
      'OVER': 'SOBRE',
      'PLOT': 'PONTO',
      'DRAW': 'DESENHAR',
      'CIRCLE': 'CÍRCULO',
      'SOUND': 'SOM',
      'BEEP': 'SINAL',
      'PEEK': 'OLHAR',
      'POKE': 'ESCREVER',
    },
    'th': {
      'LET': 'ให้',
      'PRINT': 'พิมพ์',
      'GOTO': 'ไปที่',
      'FOR': 'สำหรับ',
      'NEXT': 'ถัดไป',
      'IF': 'ถ้า',
      'THEN': 'แล้ว',
      'ELSE': 'อื่น',
      'DIM': 'มิติ',
      'DATA': 'ข้อมูล',
      'READ': 'อ่าน',
      'RESTORE': 'กู้คืน',
      'RANDOMIZE': 'สุ่ม',
      'INPUT': 'ป้อน',
      'REM': 'ความคิดเห็น',
      'CLS': 'ล้าง',
      'BORDER': 'ขอบ',
      'INK': 'หมึก',
      'PAPER': 'กระดาษ',
      'FLASH': 'กะพริบ',
      'BRIGHT': 'ความสว่าง',
      'INVERSE': 'ย้อนกลับ',
      'OVER': 'เหนือ',
      'PLOT': 'จุด',
      'DRAW': 'วาด',
      'CIRCLE': 'วงกลม',
      'SOUND': 'เสียง',
      'BEEP': 'สัญญาณ',
      'PEEK': 'ดู',
      'POKE': 'เขียน',
    },
    'hi': {
      'LET': 'दे',
      'PRINT': 'छाप',
      'GOTO': 'जाओ',
      'FOR': 'के_लिए',
      'NEXT': 'अगला',
      'IF': 'अगर',
      'THEN': 'तो',
      'ELSE': 'वरना',
      'DIM': 'आयाम',
      'DATA': 'डेटा',
      'READ': 'पढ़ें',
      'RESTORE': 'पुनर्स्थापित',
      'RANDOMIZE': 'यादृच्छिक',
      'INPUT': 'इनपुट',
      'REM': 'टिप्पणी',
      'CLS': 'साफ़',
      'BORDER': 'सीमा',
      'INK': 'स्याही',
      'PAPER': 'कागज',
      'FLASH': 'झपकी',
      'BRIGHT': 'चमक',
      'INVERSE': 'उल्टा',
      'OVER': 'ऊपर',
      'PLOT': 'बिंदु',
      'DRAW': 'खींचना',
      'CIRCLE': 'वृत्त',
      'SOUND': 'आवाज़',
      'BEEP': 'संकेत',
      'PEEK': 'देखना',
      'POKE': 'लिखना',
    },
    'kk': {
      'LET': 'БОЛСЫН',
      'PRINT': 'БАСЫП_ШЫҒАРУ',
      'GOTO': 'БАРУ',
      'FOR': 'ҮШІН',
      'NEXT': 'КЕЛЕСІ',
      'IF': 'ЕГЕР',
      'THEN': 'ОНДА',
      'ELSE': 'ӘЙТПЕСЕ',
      'DIM': 'ӨЛШЕМ',
      'DATA': 'ДЕРЕКТЕР',
      'READ': 'ОҚУ',
      'RESTORE': 'ҚАЛПЫНА_КЕЛТІРУ',
      'RANDOMIZE': 'КЕЗДЕСОҚ',
      'INPUT': 'КІРІС',
      'REM': 'ПІКІР',
      'CLS': 'ТАЗАЛАУ',
      'BORDER': 'ШЕКАРА',
      'INK': 'СИЯ',
      'PAPER': 'ҚАҒАЗ',
      'FLASH': 'ЖЫПЫЛДАУ',
      'BRIGHT': 'ЖАРҚЫНДЫҚ',
      'INVERSE': 'КЕРІ',
      'OVER': 'ҮСТІНДЕ',
      'PLOT': 'НҮКТЕ',
      'DRAW': 'СУРЕТТЕУ',
      'CIRCLE': 'ШЕҢБЕР',
      'SOUND': 'ДАУЫС',
      'BEEP': 'СИГНАЛ',
      'PEEK': 'ҚАРАУ',
      'POKE': 'ЖАЗУ',
    },
  };

  // Геттеры
  String get currentLanguage => _currentLanguage;
  String get theme => _theme;
  bool get autoSave => _autoSave;
  bool get syntaxHighlighting => _syntaxHighlighting;
  bool get autoComplete => _autoComplete;
  bool get lineNumbers => _lineNumbers;
  bool get wordWrap => _wordWrap;
  int get fontSize => _fontSize;
  String get fontFamily => _fontFamily;
  String get currentFile => _currentFile;
  String get currentContent => _currentContent;
  List<String> get recentFiles => _recentFiles;
  List<String> get openFiles => _openFiles;
  List<String> get commandHistory => _commandHistory;

  /// Инициализация сервиса
  Future<void> init() async {
    await _loadSettings();
    await _loadRecentFiles();
    notifyListeners();
  }

  /// Загрузка настроек из SharedPreferences
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString(_prefsKey);
    
    if (settingsJson != null) {
      final settings = jsonDecode(settingsJson) as Map<String, dynamic>;
      _currentLanguage = settings['currentLanguage'] ?? 'en';
      _theme = settings['theme'] ?? 'dark';
      _autoSave = settings['autoSave'] ?? true;
      _syntaxHighlighting = settings['syntaxHighlighting'] ?? true;
      _autoComplete = settings['autoComplete'] ?? true;
      _lineNumbers = settings['lineNumbers'] ?? true;
      _wordWrap = settings['wordWrap'] ?? true;
      _fontSize = settings['fontSize'] ?? 14;
      _fontFamily = settings['fontFamily'] ?? 'monospace';
    }
  }

  /// Сохранение настроек в SharedPreferences
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settings = {
      'currentLanguage': _currentLanguage,
      'theme': _theme,
      'autoSave': _autoSave,
      'syntaxHighlighting': _syntaxHighlighting,
      'autoComplete': _autoComplete,
      'lineNumbers': _lineNumbers,
      'wordWrap': _wordWrap,
      'fontSize': _fontSize,
      'fontFamily': _fontFamily,
    };
    await prefs.setString(_prefsKey, jsonEncode(settings));
  }

  /// Загрузка списка недавних файлов
  Future<void> _loadRecentFiles() async {
    final prefs = await SharedPreferences.getInstance();
    final recentFilesJson = prefs.getString('aibasic_recent_files');
    if (recentFilesJson != null) {
      _recentFiles = List<String>.from(jsonDecode(recentFilesJson));
    }
  }

  /// Сохранение списка недавних файлов
  Future<void> _saveRecentFiles() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('aibasic_recent_files', jsonEncode(_recentFiles));
  }

  /// Установка языка
  Future<void> setLanguage(String language) async {
    if (_localizedCommands.containsKey(language)) {
      _currentLanguage = language;
      await _saveSettings();
      notifyListeners();
    }
  }

  /// Установка темы
  Future<void> setTheme(String theme) async {
    _theme = theme;
    await _saveSettings();
    notifyListeners();
  }

  /// Установка размера шрифта
  Future<void> setFontSize(int size) async {
    _fontSize = size;
    await _saveSettings();
    notifyListeners();
  }

  /// Установка семейства шрифтов
  Future<void> setFontFamily(String family) async {
    _fontFamily = family;
    await _saveSettings();
    notifyListeners();
  }

  /// Переключение автосохранения
  Future<void> toggleAutoSave() async {
    _autoSave = !_autoSave;
    await _saveSettings();
    notifyListeners();
  }

  /// Переключение подсветки синтаксиса
  Future<void> toggleSyntaxHighlighting() async {
    _syntaxHighlighting = !_syntaxHighlighting;
    await _saveSettings();
    notifyListeners();
  }

  /// Переключение автодополнения
  Future<void> toggleAutoComplete() async {
    _autoComplete = !_autoComplete;
    await _saveSettings();
    notifyListeners();
  }

  /// Переключение номеров строк
  Future<void> toggleLineNumbers() async {
    _lineNumbers = !_lineNumbers;
    await _saveSettings();
    notifyListeners();
  }

  /// Переключение переноса слов
  Future<void> toggleWordWrap() async {
    _wordWrap = !_wordWrap;
    await _saveSettings();
    notifyListeners();
  }

  /// Получение локализованной команды
  String getLocalizedCommand(String command) {
    return _localizedCommands[_currentLanguage]?[command.toUpperCase()] ?? command;
  }

  /// Получение всех доступных команд для текущего языка
  Map<String, String> getAvailableCommands() {
    return _localizedCommands[_currentLanguage] ?? _localizedCommands['en']!;
  }

  /// Создание нового файла
  Future<void> createNewFile() async {
    _currentFile = '';
    _currentContent = '';
    notifyListeners();
  }

  /// Открытие файла
  Future<void> openFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        _currentFile = filePath;
        _currentContent = await file.readAsString();
        _fileContents[filePath] = _currentContent;
        
        if (!_openFiles.contains(filePath)) {
          _openFiles.add(filePath);
        }
        
        if (!_recentFiles.contains(filePath)) {
          _recentFiles.insert(0, filePath);
          if (_recentFiles.length > 10) {
            _recentFiles = _recentFiles.take(10).toList();
          }
          await _saveRecentFiles();
        }
        
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Ошибка при открытии файла: $e');
    }
  }

  /// Сохранение файла
  Future<void> saveFile() async {
    if (_currentFile.isNotEmpty) {
      try {
        final file = File(_currentFile);
        await file.writeAsString(_currentContent);
        _fileContents[_currentFile] = _currentContent;
        notifyListeners();
      } catch (e) {
        debugPrint('Ошибка при сохранении файла: $e');
      }
    }
  }

  /// Сохранение файла как
  Future<void> saveFileAs(String filePath) async {
    try {
      final file = File(filePath);
      await file.writeAsString(_currentContent);
      _currentFile = filePath;
      _fileContents[filePath] = _currentContent;
      
      if (!_openFiles.contains(filePath)) {
        _openFiles.add(filePath);
      }
      
      if (!_recentFiles.contains(filePath)) {
        _recentFiles.insert(0, filePath);
        if (_recentFiles.length > 10) {
          _recentFiles = _recentFiles.take(10).toList();
        }
        await _saveRecentFiles();
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Ошибка при сохранении файла: $e');
    }
  }

  /// Обновление содержимого файла
  void updateContent(String content) {
    _currentContent = content;
    if (_currentFile.isNotEmpty) {
      _fileContents[_currentFile] = content;
    }
    
    if (_autoSave) {
      saveFile();
    }
    
    notifyListeners();
  }

  /// Закрытие файла
  void closeFile(String filePath) {
    _openFiles.remove(filePath);
    _fileContents.remove(filePath);
    
    if (_currentFile == filePath) {
      if (_openFiles.isNotEmpty) {
        _currentFile = _openFiles.last;
        _currentContent = _fileContents[_currentFile] ?? '';
      } else {
        _currentFile = '';
        _currentContent = '';
      }
    }
    
    notifyListeners();
  }

  /// Добавление команды в историю
  void addToHistory(String command) {
    if (command.isNotEmpty && (_commandHistory.isEmpty || _commandHistory.last != command)) {
      _commandHistory.add(command);
      if (_commandHistory.length > 100) {
        _commandHistory = _commandHistory.skip(1).toList();
      }
      _historyIndex = _commandHistory.length - 1;
    }
  }

  /// Получение предыдущей команды из истории
  String? getPreviousCommand() {
    if (_historyIndex > 0) {
      _historyIndex--;
      return _commandHistory[_historyIndex];
    }
    return null;
  }

  /// Получение следующей команды из истории
  String? getNextCommand() {
    if (_historyIndex < _commandHistory.length - 1) {
      _historyIndex++;
      return _commandHistory[_historyIndex];
    }
    return null;
  }

  /// Создание проекта AIBASIC
  Future<String> createProject(String projectName, String projectPath) async {
    try {
      final projectDir = Directory('$projectPath/$projectName');
      await projectDir.create(recursive: true);
      
      // Создание основного файла
      final mainFile = File('${projectDir.path}/main.aibasic');
      await mainFile.writeAsString('''
10 REM AIBASIC Project: $projectName
20 REM Created: ${DateTime.now().toIso8601String()}
30 REM Main Program (max 108 lines)
40 
50 PRINT "Hello, AIBASIC World!"
60 LET имя_пользователя = "Developer"
70 PRINT "Welcome, " + имя_пользователя
80 
90 REM End of main program
100 END
''');
      
      // Создание файла подпрограмм
      final subroutinesFile = File('${projectDir.path}/subroutines.aibasic');
      await subroutinesFile.writeAsString('''
REM Subroutines for $projectName
REM This file contains all subroutines for the project

greet_user:
10 PARAM user_name
20 PRINT "Hello, " + user_name
30 PRINT "Welcome to AIBASIC!"
40 RETURN

calculate_sum:
10 PARAM a, b
20 LET result = a + b
30 RETURN result
''');
      
      // Создание файла конфигурации проекта
      final configFile = File('${projectDir.path}/project.json');
      await configFile.writeAsString(jsonEncode({
        'name': projectName,
        'version': '1.0.0',
        'created': DateTime.now().toIso8601String(),
        'mainFile': 'main.aibasic',
        'subroutinesFile': 'subroutines.aibasic',
        'language': _currentLanguage,
        'description': 'AIBASIC project created with FreeDome Sphere IDE'
      }));
      
      return projectDir.path;
    } catch (e) {
      debugPrint('Ошибка при создании проекта: $e');
      rethrow;
    }
  }

  /// Получение списка доступных языков
  List<String> getAvailableLanguages() {
    return _localizedCommands.keys.toList();
  }

  /// Получение названия языка
  String getLanguageName(String languageCode) {
    const languageNames = {
      'en': 'English',
      'ru': 'Русский',
      'de': 'Deutsch',
      'ar': 'العربية',
      'pt': 'Português',
      'th': 'ไทย',
      'hi': 'हिन्दी',
      'kk': 'Қазақша',
    };
    return languageNames[languageCode] ?? languageCode;
  }
}
