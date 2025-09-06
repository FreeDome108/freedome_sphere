import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/unreal_optimizer_service.dart';
import '../models/unreal_analysis.dart';
import '../widgets/unreal_analysis_panel.dart';
import '../widgets/unreal_report_panel.dart';

class UnrealOptimizerScreen extends StatefulWidget {
  const UnrealOptimizerScreen({super.key});

  @override
  State<UnrealOptimizerScreen> createState() => _UnrealOptimizerScreenState();
}

class _UnrealOptimizerScreenState extends State<UnrealOptimizerScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final UnrealOptimizerService _optimizerService = UnrealOptimizerService();
  
  bool _isInitialized = false;
  bool _isLoading = false;
  String _statusMessage = 'Инициализация...';
  
  AnalysisResult? _analysisResult;
  String? _selectedProjectPath;
  String? _reportContent;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeService();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _optimizerService.dispose();
    super.dispose();
  }

  Future<void> _initializeService() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Инициализация Unreal Optimizer...';
    });

    try {
      final success = await _optimizerService.initialize();
      setState(() {
        _isInitialized = success;
        _isLoading = false;
        _statusMessage = success 
            ? 'Unreal Optimizer готов к работе' 
            : 'Ошибка инициализации Unreal Optimizer';
      });
    } catch (e) {
      setState(() {
        _isInitialized = false;
        _isLoading = false;
        _statusMessage = 'Ошибка инициализации: $e';
      });
    }
  }

  Future<void> _selectProject() async {
    try {
      final result = await FilePicker.platform.getDirectoryPath();
      if (result != null) {
        setState(() {
          _selectedProjectPath = result;
        });
        
        // Проверяем, является ли это проектом Unreal Engine
        final isUnrealProject = await _optimizerService.isUnrealProject(result);
        if (!isUnrealProject) {
          _showErrorDialog('Выбранная папка не является проектом Unreal Engine. '
              'Убедитесь, что в папке есть файл .uproject');
          return;
        }
        
        _showSuccessDialog('Проект Unreal Engine выбран: $result');
      }
    } catch (e) {
      _showErrorDialog('Ошибка выбора проекта: $e');
    }
  }

  Future<void> _analyzeProject() async {
    if (_selectedProjectPath == null) {
      _showErrorDialog('Сначала выберите проект Unreal Engine');
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = 'Анализ проекта...';
    });

    try {
      final result = await _optimizerService.analyzeProject(_selectedProjectPath!);
      setState(() {
        _analysisResult = result;
        _isLoading = false;
        _statusMessage = 'Анализ завершен. Найдено ${result.issues.length} проблем';
      });
      
      // Переключаемся на вкладку анализа
      _tabController.animateTo(1);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Ошибка анализа: $e';
      });
      _showErrorDialog('Ошибка анализа проекта: $e');
    }
  }

  Future<void> _generateReport() async {
    if (_analysisResult == null) {
      _showErrorDialog('Сначала выполните анализ проекта');
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = 'Генерация отчета...';
    });

    try {
      final report = await _optimizerService.generateReport(_analysisResult!);
      setState(() {
        _reportContent = report;
        _isLoading = false;
        _statusMessage = 'Отчет сгенерирован';
      });
      
      // Переключаемся на вкладку отчета
      _tabController.animateTo(2);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Ошибка генерации отчета: $e';
      });
      _showErrorDialog('Ошибка генерации отчета: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ошибка'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Успех'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Unreal Engine Optimizer'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.settings), text: 'Настройки'),
            Tab(icon: Icon(Icons.analytics), text: 'Анализ'),
            Tab(icon: Icon(Icons.description), text: 'Отчет'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Статусная панель
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: _isInitialized ? Colors.green.shade100 : Colors.red.shade100,
            child: Row(
              children: [
                Icon(
                  _isInitialized ? Icons.check_circle : Icons.error,
                  color: _isInitialized ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _statusMessage,
                    style: TextStyle(
                      color: _isInitialized ? Colors.green.shade800 : Colors.red.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (_isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          ),
          
          // Основной контент
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Вкладка настроек
                _buildSettingsTab(),
                
                // Вкладка анализа
                _analysisResult != null
                    ? UnrealAnalysisPanel(analysisResult: _analysisResult!)
                    : const Center(
                        child: Text('Выполните анализ проекта для просмотра результатов'),
                      ),
                
                // Вкладка отчета
                _reportContent != null
                    ? UnrealReportPanel(reportContent: _reportContent!)
                    : const Center(
                        child: Text('Сгенерируйте отчет для просмотра'),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Выбор проекта',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  if (_selectedProjectPath != null) ...[
                    Text(
                      'Выбранный проект:',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        _selectedProjectPath!,
                        style: const TextStyle(fontFamily: 'monospace'),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _isInitialized ? _selectProject : null,
                        icon: const Icon(Icons.folder_open),
                        label: const Text('Выбрать проект'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: _isInitialized && _selectedProjectPath != null
                            ? _analyzeProject
                            : null,
                        icon: const Icon(Icons.analytics),
                        label: const Text('Анализировать'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Действия',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _analysisResult != null ? _generateReport : null,
                        icon: const Icon(Icons.description),
                        label: const Text('Сгенерировать отчет'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: _isInitialized ? _initializeService : null,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Переинициализировать'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Информация о плагине',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  const Text(
                    'Unreal Blocks to Code Optimizer - это мощный инструмент для анализа и оптимизации проектов Unreal Engine. '
                    'Плагин помогает выявить проблемы производительности, утечки памяти и улучшить качество кода.',
                  ),
                  const SizedBox(height: 16),
                  
                  const Text(
                    'Возможности:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  
                  const Text('• Анализ C++ файлов на предмет неоптимальных паттернов'),
                  const Text('• Проверка Blueprint файлов на соответствие конвенциям'),
                  const Text('• Оптимизация циклов и строковых операций'),
                  const Text('• Добавление const ключевых слов'),
                  const Text('• Генерация детальных отчетов'),
                  const Text('• Рекомендации по улучшению производительности'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
