import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Сервис для интеграции с плагином unreal_blocks_to_code_plugin
class UnrealPluginIntegrationService extends ChangeNotifier {
  static const String _prefsKey = 'unreal_plugin_settings';
  
  // Настройки плагина
  bool _enableAutoOptimization = false;
  String _optimizationLevel = 'basic';
  bool _includeBlueprints = true;
  bool _backupBeforeOptimization = true;
  
  // Состояние плагина
  bool _isAnalyzing = false;
  bool _isOptimizing = false;
  String _currentProjectPath = '';
  List<AnalysisResult> _analysisResults = [];
  List<OptimizationResult> _optimizationResults = [];
  List<ErrorLog> _errorLogs = [];
  
  // Пути к плагину
  String? _pluginPath;
  Process? _nodeProcess;

  // Геттеры
  bool get enableAutoOptimization => _enableAutoOptimization;
  String get optimizationLevel => _optimizationLevel;
  bool get includeBlueprints => _includeBlueprints;
  bool get backupBeforeOptimization => _backupBeforeOptimization;
  bool get isAnalyzing => _isAnalyzing;
  bool get isOptimizing => _isOptimizing;
  String get currentProjectPath => _currentProjectPath;
  List<AnalysisResult> get analysisResults => _analysisResults;
  List<OptimizationResult> get optimizationResults => _optimizationResults;
  List<ErrorLog> get errorLogs => _errorLogs;

  /// Инициализация сервиса
  Future<void> init() async {
    await _loadSettings();
    await _findPluginPath();
    notifyListeners();
  }

  /// Загрузка настроек из SharedPreferences
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString(_prefsKey);
    
    if (settingsJson != null) {
      final settings = jsonDecode(settingsJson) as Map<String, dynamic>;
      _enableAutoOptimization = settings['enableAutoOptimization'] ?? false;
      _optimizationLevel = settings['optimizationLevel'] ?? 'basic';
      _includeBlueprints = settings['includeBlueprints'] ?? true;
      _backupBeforeOptimization = settings['backupBeforeOptimization'] ?? true;
    }
  }

  /// Сохранение настроек в SharedPreferences
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settings = {
      'enableAutoOptimization': _enableAutoOptimization,
      'optimizationLevel': _optimizationLevel,
      'includeBlueprints': _includeBlueprints,
      'backupBeforeOptimization': _backupBeforeOptimization,
    };
    await prefs.setString(_prefsKey, jsonEncode(settings));
  }

  /// Поиск пути к плагину
  Future<void> _findPluginPath() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final pluginDir = Directory('${appDir.path}/unreal_blocks_to_code_plugin');
      
      if (await pluginDir.exists()) {
        _pluginPath = pluginDir.path;
      } else {
        // Попытка найти плагин в рабочей директории
        final workingDir = Directory.current;
        final localPluginDir = Directory('${workingDir.path}/plugin/unreal_blocks_to_code_plugin');
        
        if (await localPluginDir.exists()) {
          _pluginPath = localPluginDir.path;
        }
      }
    } catch (e) {
      debugPrint('Ошибка при поиске плагина: $e');
    }
  }

  /// Установка настроек плагина
  Future<void> setEnableAutoOptimization(bool value) async {
    _enableAutoOptimization = value;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setOptimizationLevel(String level) async {
    if (['basic', 'advanced', 'aggressive'].contains(level)) {
      _optimizationLevel = level;
      await _saveSettings();
      notifyListeners();
    }
  }

  Future<void> setIncludeBlueprints(bool value) async {
    _includeBlueprints = value;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setBackupBeforeOptimization(bool value) async {
    _backupBeforeOptimization = value;
    await _saveSettings();
    notifyListeners();
  }

  /// Анализ проекта Unreal Engine
  Future<AnalysisResult> analyzeProject(String projectPath) async {
    if (_pluginPath == null) {
      throw Exception('Плагин не найден. Убедитесь, что плагин установлен.');
    }

    setState(() {
      _isAnalyzing = true;
      _currentProjectPath = projectPath;
    });

    try {
      // Создаем временный файл для конфигурации
      final configFile = await _createConfigFile();
      
      // Запускаем анализ через Node.js
      final result = await _runNodeScript('analyze', {
        'projectPath': projectPath,
        'configFile': configFile.path,
      });

      final analysisResult = AnalysisResult.fromJson(jsonDecode(result));
      _analysisResults.add(analysisResult);
      
      setState(() {
        _isAnalyzing = false;
      });

      return analysisResult;
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
      });
      
      _addErrorLog('ProjectAnalyzer', e.toString(), {
        'projectPath': projectPath,
      });
      
      rethrow;
    }
  }

  /// Оптимизация кода
  Future<OptimizationResult> optimizeCode(String filePath, String content) async {
    if (_pluginPath == null) {
      throw Exception('Плагин не найден. Убедитесь, что плагин установлен.');
    }

    setState(() {
      _isOptimizing = true;
    });

    try {
      // Создаем временный файл для конфигурации
      final configFile = await _createConfigFile();
      
      // Запускаем оптимизацию через Node.js
      final result = await _runNodeScript('optimize', {
        'filePath': filePath,
        'content': content,
        'configFile': configFile.path,
      });

      final optimizationResult = OptimizationResult.fromJson(jsonDecode(result));
      _optimizationResults.add(optimizationResult);
      
      setState(() {
        _isOptimizing = false;
      });

      return optimizationResult;
    } catch (e) {
      setState(() {
        _isOptimizing = false;
      });
      
      _addErrorLog('CodeOptimizer', e.toString(), {
        'filePath': filePath,
      });
      
      rethrow;
    }
  }

  /// Оптимизация Blueprints
  Future<BlueprintOptimizationResult> optimizeBlueprints(String projectPath) async {
    if (_pluginPath == null) {
      throw Exception('Плагин не найден. Убедитесь, что плагин установлен.');
    }

    setState(() {
      _isOptimizing = true;
    });

    try {
      // Создаем временный файл для конфигурации
      final configFile = await _createConfigFile();
      
      // Запускаем оптимизацию Blueprints через Node.js
      final result = await _runNodeScript('optimizeBlueprints', {
        'projectPath': projectPath,
        'configFile': configFile.path,
      });

      final blueprintResult = BlueprintOptimizationResult.fromJson(jsonDecode(result));
      
      setState(() {
        _isOptimizing = false;
      });

      return blueprintResult;
    } catch (e) {
      setState(() {
        _isOptimizing = false;
      });
      
      _addErrorLog('BlueprintOptimizer', e.toString(), {
        'projectPath': projectPath,
      });
      
      rethrow;
    }
  }

  /// Генерация отчета
  Future<String> generateReport(String projectPath) async {
    if (_pluginPath == null) {
      throw Exception('Плагин не найден. Убедитесь, что плагин установлен.');
    }

    try {
      // Создаем временный файл для конфигурации
      final configFile = await _createConfigFile();
      
      // Запускаем генерацию отчета через Node.js
      final result = await _runNodeScript('generateReport', {
        'projectPath': projectPath,
        'configFile': configFile.path,
      });

      return result;
    } catch (e) {
      _addErrorLog('ReportGenerator', e.toString(), {
        'projectPath': projectPath,
      });
      
      rethrow;
    }
  }

  /// Создание файла конфигурации
  Future<File> _createConfigFile() async {
    final tempDir = await getTemporaryDirectory();
    final configFile = File('${tempDir.path}/unreal_plugin_config.json');
    
    final config = {
      'enableAutoOptimization': _enableAutoOptimization,
      'optimizationLevel': _optimizationLevel,
      'includeBlueprints': _includeBlueprints,
      'backupBeforeOptimization': _backupBeforeOptimization,
    };
    
    await configFile.writeAsString(jsonEncode(config));
    return configFile;
  }

  /// Запуск Node.js скрипта
  Future<String> _runNodeScript(String command, Map<String, dynamic> params) async {
    if (_pluginPath == null) {
      throw Exception('Плагин не найден');
    }

    final scriptPath = '$_pluginPath/scripts/run_command.js';
    final scriptFile = File(scriptPath);
    
    if (!await scriptFile.exists()) {
      throw Exception('Скрипт плагина не найден: $scriptPath');
    }

    final process = await Process.start(
      'node',
      [scriptPath, command, jsonEncode(params)],
      workingDirectory: _pluginPath,
    );

    final output = await process.stdout.transform(utf8.decoder).join();
    final error = await process.stderr.transform(utf8.decoder).join();
    
    final exitCode = await process.exitCode;
    
    if (exitCode != 0) {
      throw Exception('Ошибка выполнения скрипта: $error');
    }

    return output;
  }

  /// Добавление ошибки в лог
  void _addErrorLog(String component, String message, Map<String, dynamic> context) {
    final errorLog = ErrorLog(
      timestamp: DateTime.now(),
      component: component,
      message: message,
      context: context,
    );
    
    _errorLogs.add(errorLog);
    
    // Ограничиваем количество логов
    if (_errorLogs.length > 100) {
      _errorLogs = _errorLogs.skip(1).toList();
    }
    
    notifyListeners();
  }

  /// Очистка логов ошибок
  void clearErrorLogs() {
    _errorLogs.clear();
    notifyListeners();
  }

  /// Генерация отчета об ошибках
  String generateErrorReport() {
    if (_errorLogs.isEmpty) {
      return 'Нет ошибок в логах.';
    }

    final buffer = StringBuffer();
    buffer.writeln('# Отчет об ошибках Unreal Plugin');
    buffer.writeln();
    buffer.writeln('**Всего ошибок:** ${_errorLogs.length}');
    buffer.writeln('**Последняя ошибка:** ${_errorLogs.last.timestamp}');
    buffer.writeln();

    for (final error in _errorLogs) {
      buffer.writeln('## ${error.component}');
      buffer.writeln('**Время:** ${error.timestamp}');
      buffer.writeln('**Сообщение:** ${error.message}');
      if (error.context.isNotEmpty) {
        buffer.writeln('**Контекст:**');
        for (final entry in error.context.entries) {
          buffer.writeln('- ${entry.key}: ${entry.value}');
        }
      }
      buffer.writeln();
    }

    return buffer.toString();
  }

  /// Проверка доступности плагина
  bool isPluginAvailable() {
    return _pluginPath != null;
  }

  /// Получение информации о плагине
  Future<PluginInfo> getPluginInfo() async {
    if (_pluginPath == null) {
      throw Exception('Плагин не найден');
    }

    try {
      final packageJsonFile = File('$_pluginPath/package.json');
      if (await packageJsonFile.exists()) {
        final packageJson = jsonDecode(await packageJsonFile.readAsString());
        return PluginInfo.fromJson(packageJson);
      }
    } catch (e) {
      debugPrint('Ошибка при чтении информации о плагине: $e');
    }

    return PluginInfo(
      name: 'Unreal Blocks to Code Optimizer',
      version: '1.0.0',
      description: 'Плагин для оптимизации кода Unreal Engine проектов',
    );
  }

  void setState(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  @override
  void dispose() {
    _nodeProcess?.kill();
    super.dispose();
  }
}

/// Результат анализа проекта
class AnalysisResult {
  final String projectPath;
  final DateTime timestamp;
  final List<AnalysisIssue> issues;
  final int totalFiles;
  final int cppFiles;
  final int blueprintFiles;
  final int performanceScore;
  final List<String> recommendations;

  AnalysisResult({
    required this.projectPath,
    required this.timestamp,
    required this.issues,
    required this.totalFiles,
    required this.cppFiles,
    required this.blueprintFiles,
    required this.performanceScore,
    required this.recommendations,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      projectPath: json['projectPath'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      issues: (json['issues'] as List<dynamic>?)
          ?.map((issue) => AnalysisIssue.fromJson(issue))
          .toList() ?? [],
      totalFiles: json['totalFiles'] ?? 0,
      cppFiles: json['cppFiles'] ?? 0,
      blueprintFiles: json['blueprintFiles'] ?? 0,
      performanceScore: json['performanceScore'] ?? 0,
      recommendations: List<String>.from(json['recommendations'] ?? []),
    );
  }
}

/// Проблема анализа
class AnalysisIssue {
  final String type;
  final String severity;
  final String file;
  final int line;
  final String message;
  final String suggestion;

  AnalysisIssue({
    required this.type,
    required this.severity,
    required this.file,
    required this.line,
    required this.message,
    required this.suggestion,
  });

  factory AnalysisIssue.fromJson(Map<String, dynamic> json) {
    return AnalysisIssue(
      type: json['type'] ?? '',
      severity: json['severity'] ?? 'info',
      file: json['file'] ?? '',
      line: json['line'] ?? 0,
      message: json['message'] ?? '',
      suggestion: json['suggestion'] ?? '',
    );
  }
}

/// Результат оптимизации кода
class OptimizationResult {
  final String filePath;
  final DateTime timestamp;
  final String originalContent;
  final String optimizedContent;
  final List<OptimizationChange> changes;
  final bool success;

  OptimizationResult({
    required this.filePath,
    required this.timestamp,
    required this.originalContent,
    required this.optimizedContent,
    required this.changes,
    required this.success,
  });

  factory OptimizationResult.fromJson(Map<String, dynamic> json) {
    return OptimizationResult(
      filePath: json['filePath'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      originalContent: json['originalContent'] ?? '',
      optimizedContent: json['optimizedContent'] ?? '',
      changes: (json['changes'] as List<dynamic>?)
          ?.map((change) => OptimizationChange.fromJson(change))
          .toList() ?? [],
      success: json['success'] ?? false,
    );
  }
}

/// Изменение оптимизации
class OptimizationChange {
  final String type;
  final int line;
  final String original;
  final String optimized;
  final String description;

  OptimizationChange({
    required this.type,
    required this.line,
    required this.original,
    required this.optimized,
    required this.description,
  });

  factory OptimizationChange.fromJson(Map<String, dynamic> json) {
    return OptimizationChange(
      type: json['type'] ?? '',
      line: json['line'] ?? 0,
      original: json['original'] ?? '',
      optimized: json['optimized'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

/// Результат оптимизации Blueprints
class BlueprintOptimizationResult {
  final String projectPath;
  final DateTime timestamp;
  final int totalBlueprints;
  final int optimizedBlueprints;
  final List<BlueprintIssue> issues;
  final List<String> recommendations;

  BlueprintOptimizationResult({
    required this.projectPath,
    required this.timestamp,
    required this.totalBlueprints,
    required this.optimizedBlueprints,
    required this.issues,
    required this.recommendations,
  });

  factory BlueprintOptimizationResult.fromJson(Map<String, dynamic> json) {
    return BlueprintOptimizationResult(
      projectPath: json['projectPath'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      totalBlueprints: json['totalBlueprints'] ?? 0,
      optimizedBlueprints: json['optimizedBlueprints'] ?? 0,
      issues: (json['issues'] as List<dynamic>?)
          ?.map((issue) => BlueprintIssue.fromJson(issue))
          .toList() ?? [],
      recommendations: List<String>.from(json['recommendations'] ?? []),
    );
  }
}

/// Проблема Blueprint
class BlueprintIssue {
  final String file;
  final String type;
  final String severity;
  final String message;
  final String suggestion;

  BlueprintIssue({
    required this.file,
    required this.type,
    required this.severity,
    required this.message,
    required this.suggestion,
  });

  factory BlueprintIssue.fromJson(Map<String, dynamic> json) {
    return BlueprintIssue(
      file: json['file'] ?? '',
      type: json['type'] ?? '',
      severity: json['severity'] ?? 'info',
      message: json['message'] ?? '',
      suggestion: json['suggestion'] ?? '',
    );
  }
}

/// Лог ошибки
class ErrorLog {
  final DateTime timestamp;
  final String component;
  final String message;
  final Map<String, dynamic> context;

  ErrorLog({
    required this.timestamp,
    required this.component,
    required this.message,
    required this.context,
  });
}

/// Информация о плагине
class PluginInfo {
  final String name;
  final String version;
  final String description;

  PluginInfo({
    required this.name,
    required this.version,
    required this.description,
  });

  factory PluginInfo.fromJson(Map<String, dynamic> json) {
    return PluginInfo(
      name: json['name'] ?? 'Unknown Plugin',
      version: json['version'] ?? '1.0.0',
      description: json['description'] ?? '',
    );
  }
}
