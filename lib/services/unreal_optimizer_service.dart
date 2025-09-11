import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../models/unreal_analysis.dart';

class UnrealOptimizerService extends ChangeNotifier {
  // static const MethodChannel _channel = MethodChannel('unreal_optimizer');
  static const String _pluginPath = 'unreal_blocks_to_code_plugin';
  
  static final UnrealOptimizerService _instance = UnrealOptimizerService._internal();
  factory UnrealOptimizerService() => _instance;
  UnrealOptimizerService._internal();

  bool _isInitialized = false;
  String? _nodeProcessPath;

  /// Инициализация сервиса
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Копируем плагин в директорию приложения
      await _copyPluginToAppDirectory();
      
      // Инициализируем Node.js процесс
      await _initializeNodeProcess();
      
      _isInitialized = true;
      return true;
    } catch (e) {
      // print('Ошибка инициализации UnrealOptimizerService: $e');
      return false;
    }
  }

  /// Копирование плагина в директорию приложения
  Future<void> _copyPluginToAppDirectory() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final pluginDir = Directory('${appDir.path}/$_pluginPath');
      
      if (!await pluginDir.exists()) {
        await pluginDir.create(recursive: true);
      }

      // Здесь должна быть логика копирования файлов плагина
      // Для демонстрации создаем базовую структуру
      await _createPluginStructure(pluginDir);
    } catch (e) {
      throw Exception('Ошибка копирования плагина: $e');
    }
  }

  /// Создание базовой структуры плагина
  Future<void> _createPluginStructure(Directory pluginDir) async {
    // Создаем package.json
    final packageJson = {
      "name": "unreal-blocks-to-code-optimizer",
      "version": "1.0.0",
      "main": "dist/extension.js",
      "dependencies": {
        "fs-extra": "^11.1.1",
        "glob": "^7.2.3",
        "xml2js": "^0.6.2"
      }
    };

    final packageJsonFile = File('${pluginDir.path}/package.json');
    await packageJsonFile.writeAsString(jsonEncode(packageJson));

    // Создаем dist директорию
    final distDir = Directory('${pluginDir.path}/dist');
    if (!await distDir.exists()) {
      await distDir.create();
    }

    // Создаем базовый extension.js
    final extensionJs = '''
const fs = require('fs-extra');
const path = require('path');
const glob = require('glob');

class UnrealProjectAnalyzer {
  async analyzeProject(projectPath) {
    const issues = [];
    const suggestions = [];
    
    // Базовая логика анализа
    const cppFiles = await this.findCppFiles(projectPath);
    const blueprintFiles = await this.findBlueprintFiles(projectPath);
    
    for (const file of cppFiles) {
      const fileIssues = await this.analyzeCppFile(file);
      issues.push(...fileIssues);
    }
    
    return {
      projectPath,
      totalFiles: cppFiles.length + blueprintFiles.length,
      issues,
      suggestions,
      analysisDate: new Date().toISOString(),
      performanceScore: this.calculatePerformanceScore(issues)
    };
  }
  
  async findCppFiles(projectPath) {
    const patterns = ['**/*.cpp', '**/*.h', '**/*.cpppp'];
    const files = [];
    
    for (const pattern of patterns) {
      const matches = await glob(pattern, { cwd: projectPath });
      files.push(...matches.map(file => path.join(projectPath, file)));
    }
    
    return files;
  }
  
  async findBlueprintFiles(projectPath) {
    const patterns = ['**/*.uasset', '**/*.umap'];
    const files = [];
    
    for (const pattern of patterns) {
      const matches = await glob(pattern, { cwd: projectPath });
      files.push(...matches.map(file => path.join(projectPath, file)));
    }
    
    return files;
  }
  
  async analyzeCppFile(filePath) {
    const issues = [];
    
    try {
      const content = await fs.readFile(filePath, 'utf-8');
      const lines = content.split('\\n');
      
      for (let i = 0; i < lines.length; i++) {
        const line = lines[i];
        const lineNumber = i + 1;
        
        // Проверка на неэффективные циклы
        if (this.hasInefficientLoop(line)) {
          issues.push({
            type: 'performance',
            severity: 'warning',
            file: filePath,
            line: lineNumber,
            message: 'Неэффективный цикл - рассмотрите использование итераторов или алгоритмов STL',
            suggestion: 'Используйте std::for_each, std::transform или range-based for loops'
          });
        }
        
        // Проверка на неоптимальные строковые операции
        if (this.hasInefficientStringOperation(line)) {
          issues.push({
            type: 'performance',
            severity: 'warning',
            file: filePath,
            line: lineNumber,
            message: 'Неэффективная работа со строками',
            suggestion: 'Используйте FString::Append или FString::Format для конкатенации'
          });
        }
        
        // Проверка на отсутствие const
        if (this.missingConst(line)) {
          issues.push({
            type: 'code-quality',
            severity: 'info',
            file: filePath,
            line: lineNumber,
            message: 'Отсутствует const для неизменяемых переменных',
            suggestion: 'Добавьте const для переменных, которые не изменяются'
          });
        }
      }
    } catch (error) {
      issues.push({
        type: 'error',
        severity: 'error',
        file: filePath,
        line: 0,
        message: `Ошибка чтения файла: \${error}`,
        suggestion: 'Проверьте права доступа к файлу'
      });
    }
    
    return issues;
  }
  
  hasInefficientLoop(line) {
    const patterns = [
      /for\\s*\\(\\s*int\\s+\\w+\\s*=\\s*0\\s*;\\s*\\w+\\s*<\\s*\\w+\\.size\\(\\)\\s*;\\s*\\w+\\+\\+\\s*\\)/,
      /for\\s*\\(\\s*int\\s+\\w+\\s*=\\s*0\\s*;\\s*\\w+\\s*<\\s*\\w+\\.Num\\(\\)\\s*;\\s*\\w+\\+\\+\\s*\\)/,
      /while\\s*\\(\\s*\\w+\\s*<\\s*\\w+\\.size\\(\\)\\s*\\)/,
    ];
    return patterns.some(pattern => pattern.test(line));
  }
  
  hasInefficientStringOperation(line) {
    const patterns = [
      /FString.*\\+.*FString/,
      /TEXT\\([^)]*\\)\\s*\\+\\s*TEXT\\([^)]*\\)/,
      /FString::Printf.*%s.*%s/,
    ];
    return patterns.some(pattern => pattern.test(line)) && !line.includes('FString::Format');
  }
  
  missingConst(line) {
    const patterns = [
      /^\\s*(int|float|bool|FString|FVector|FRotator|FTransform|FQuat)\\s+\\w+\\s*=/,
      /^\\s*(int|float|bool|FString|FVector|FRotator|FTransform|FQuat)\\s+\\w+\\s*\\)/,
    ];
    return patterns.some(pattern => pattern.test(line)) && !line.includes('const');
  }
  
  calculatePerformanceScore(issues) {
    let score = 100;
    
    for (const issue of issues) {
      switch (issue.severity) {
        case 'error':
          score -= 10;
          break;
        case 'warning':
          score -= 5;
          break;
        case 'info':
          score -= 1;
          break;
      }
    }
    
    return Math.max(0, score);
  }
}

class CodeOptimizer {
  async optimizeCode(code, fileName, projectPath) {
    let optimizedCode = code;
    
    // Базовая оптимизация циклов
    optimizedCode = this.optimizeLoops(optimizedCode);
    
    // Оптимизация строковых операций
    optimizedCode = this.optimizeStringOperations(optimizedCode);
    
    // Добавление const
    optimizedCode = this.addConstKeywords(optimizedCode);
    
    return optimizedCode;
  }
  
  optimizeLoops(code) {
    // Замена неэффективных циклов на range-based for loops
    return code.replace(
      /for\\s*\\(\\s*int\\s+(\\w+)\\s*=\\s*0\\s*;\\s*\\1\\s*<\\s*(\\w+)\\.size\\(\\)\\s*;\\s*\\1\\+\\+\\s*\\)\\s*\\{([^}]+)\\}/g,
      'for (const auto& item : \$2) {\$3}'
    );
  }
  
  optimizeStringOperations(code) {
    // Замена конкатенации строк на FString::Format
    return code.replace(
      /FString\\s+(\\w+)\\s*=\\s*(\\w+)\\s*\\+\\s*(\\w+)\\s*\\+\\s*(\\w+);/g,
      'FString \$1 = FString::Format(TEXT("{0}{1}{2}"), {\$2, \$3, \$4});'
    );
  }
  
  addConstKeywords(code) {
    // Добавление const для локальных переменных
    return code.replace(
      /^\\s*(int|float|bool|FString|FVector|FRotator|FTransform|FQuat)\\s+(\\w+)\\s*=\\s*([^;]+);/gm,
      'const \$1 \$2 = \$3;'
    );
  }
}

// Экспорт классов
module.exports = { UnrealProjectAnalyzer, CodeOptimizer };
''';

    final extensionJsFile = File('${distDir.path}/extension.js');
    await extensionJsFile.writeAsString(extensionJs);
  }

  /// Инициализация Node.js процесса
  Future<void> _initializeNodeProcess() async {
    try {
      // Проверяем наличие Node.js
      final result = await Process.run('node', ['--version']);
      if (result.exitCode != 0) {
        throw Exception('Node.js не найден. Установите Node.js для работы плагина.');
      }

      final appDir = await getApplicationDocumentsDirectory();
      _nodeProcessPath = '${appDir.path}/$_pluginPath';
      
      // Устанавливаем зависимости
      await _installDependencies();
    } catch (e) {
      throw Exception('Ошибка инициализации Node.js: $e');
    }
  }

  /// Установка зависимостей
  Future<void> _installDependencies() async {
    if (_nodeProcessPath == null) return;

    try {
      final result = await Process.run(
        'npm',
        ['install'],
        workingDirectory: _nodeProcessPath,
      );

      if (result.exitCode != 0) {
        // print('Предупреждение: Не удалось установить зависимости npm: ${result.stderr}');
      }
    } catch (e) {
      // print('Предупреждение: Ошибка установки зависимостей: $e');
    }
  }

  /// Анализ проекта Unreal Engine
  Future<AnalysisResult> analyzeProject(String projectPath) async {
    if (!_isInitialized) {
      throw Exception('Сервис не инициализирован. Вызовите initialize() сначала.');
    }

    try {
      final result = await Process.run(
        'node',
        ['-e', '''
          const { UnrealProjectAnalyzer } = require('./dist/extension.js');
          const analyzer = new UnrealProjectAnalyzer();
          analyzer.analyzeProject('$projectPath').then(result => {
            console.log(JSON.stringify(result));
          }).catch(error => {
            console.error(JSON.stringify({error: error.message}));
          });
        '''],
        workingDirectory: _nodeProcessPath,
      );

      if (result.exitCode != 0) {
        throw Exception('Ошибка анализа проекта: ${result.stderr}');
      }

      final output = result.stdout.trim();
      final jsonData = jsonDecode(output);
      
      if (jsonData.containsKey('error')) {
        throw Exception('Ошибка анализа: ${jsonData['error']}');
      }

      return AnalysisResult.fromJson(jsonData);
    } catch (e) {
      throw Exception('Ошибка выполнения анализа: $e');
    }
  }

  /// Оптимизация кода
  Future<OptimizationResult> optimizeCode(String code, String fileName, {String? projectPath}) async {
    if (!_isInitialized) {
      throw Exception('Сервис не инициализирован. Вызовите initialize() сначала.');
    }

    try {
      final escapedCode = code.replaceAll("'", "\\'").replaceAll('\n', '\\n');
      final result = await Process.run(
        'node',
        ['-e', '''
          const { CodeOptimizer } = require('./dist/extension.js');
          const optimizer = new CodeOptimizer();
          optimizer.optimizeCode('$escapedCode', '$fileName', '${projectPath ?? ''}').then(optimizedCode => {
            console.log(JSON.stringify({
              originalCode: '$escapedCode',
              optimizedCode: optimizedCode,
              changes: [],
              performanceGain: 10,
              memoryGain: 5
            }));
          }).catch(error => {
            console.error(JSON.stringify({error: error.message}));
          });
        '''],
        workingDirectory: _nodeProcessPath,
      );

      if (result.exitCode != 0) {
        throw Exception('Ошибка оптимизации кода: ${result.stderr}');
      }

      final output = result.stdout.trim();
      final jsonData = jsonDecode(output);
      
      if (jsonData.containsKey('error')) {
        throw Exception('Ошибка оптимизации: ${jsonData['error']}');
      }

      return OptimizationResult.fromJson(jsonData);
    } catch (e) {
      throw Exception('Ошибка выполнения оптимизации: $e');
    }
  }

  /// Генерация отчета
  Future<String> generateReport(AnalysisResult analysisResult) async {
    final buffer = StringBuffer();
    
    buffer.writeln('# Отчет об анализе проекта Unreal Engine');
    buffer.writeln();
    buffer.writeln('**Путь к проекту:** ${analysisResult.projectPath}');
    buffer.writeln('**Дата анализа:** ${analysisResult.analysisDate}');
    buffer.writeln('**Всего файлов:** ${analysisResult.totalFiles}');
    buffer.writeln('**Оценка производительности:** ${analysisResult.performanceScore}/100');
    buffer.writeln();
    
    if (analysisResult.issues.isNotEmpty) {
      buffer.writeln('## Найденные проблемы');
      buffer.writeln();
      
      for (final issue in analysisResult.issues) {
        buffer.writeln('### ${issue.severity.toString().split('.').last.toUpperCase()}: ${issue.message}');
        buffer.writeln('**Файл:** ${issue.file}:${issue.line}');
        buffer.writeln('**Тип:** ${issue.type.toString().split('.').last}');
        buffer.writeln('**Предложение:** ${issue.suggestion}');
        buffer.writeln();
      }
    }
    
    if (analysisResult.suggestions.isNotEmpty) {
      buffer.writeln('## Рекомендации по оптимизации');
      buffer.writeln();
      
      for (final suggestion in analysisResult.suggestions) {
        buffer.writeln('### ${suggestion.title}');
        buffer.writeln('**Приоритет:** ${suggestion.priority.toString().split('.').last}');
        buffer.writeln('**Влияние:** ${suggestion.estimatedImpact.toString().split('.').last}');
        buffer.writeln('**Описание:** ${suggestion.description}');
        buffer.writeln();
      }
    }
    
    return buffer.toString();
  }

  /// Проверка, является ли директория проектом Unreal Engine
  Future<bool> isUnrealProject(String projectPath) async {
    try {
      final dir = Directory(projectPath);
      if (!await dir.exists()) return false;
      
      final uprojectFiles = await dir
          .list(recursive: true)
          .where((entity) => entity.path.endsWith('.uproject'))
          .toList();
      
      return uprojectFiles.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Получение статуса сервиса
  bool get isInitialized => _isInitialized;
  
  /// Очистка ресурсов
  @override
  void dispose() {
    _isInitialized = false;
    _nodeProcessPath = null;
    super.dispose();
  }
}
