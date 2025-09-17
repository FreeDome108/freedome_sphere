import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../services/unreal_plugin_integration_service.dart';
import '../l10n/app_localizations.dart';
import '../widgets/unreal_analysis_results_widget.dart';
import '../widgets/unreal_optimization_results_widget.dart';
import '../widgets/unreal_error_logs_widget.dart';

class UnrealPluginIntegrationScreen extends StatefulWidget {
  const UnrealPluginIntegrationScreen({super.key});

  @override
  State<UnrealPluginIntegrationScreen> createState() => _UnrealPluginIntegrationScreenState();
}

class _UnrealPluginIntegrationScreenState extends State<UnrealPluginIntegrationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedProjectPath = '';
  String _selectedFilePath = '';
  String _fileContent = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UnrealPluginIntegrationService>().init();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pluginService = context.watch<UnrealPluginIntegrationService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Unreal Engine Plugin Integration'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.analytics), text: 'Analysis'),
            Tab(icon: Icon(Icons.auto_fix_high), text: 'Optimization'),
            Tab(icon: Icon(Icons.description), text: 'Reports'),
            Tab(icon: Icon(Icons.error), text: 'Error Logs'),
          ],
        ),
        actions: [
          // Настройки плагина
          PopupMenuButton<String>(
            icon: const Icon(Icons.settings),
            onSelected: (setting) => _handleSettingChange(setting, pluginService),
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  value: 'autoOptimization',
                  child: Row(
                    children: [
                      Icon(pluginService.enableAutoOptimization ? Icons.check : Icons.close),
                      const SizedBox(width: 8),
                      Text('Auto Optimization: ${pluginService.enableAutoOptimization ? 'On' : 'Off'}'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'optimizationLevel',
                  child: Row(
                    children: [
                      const Icon(Icons.tune),
                      const SizedBox(width: 8),
                      Text('Level: ${pluginService.optimizationLevel}'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'includeBlueprints',
                  child: Row(
                    children: [
                      Icon(pluginService.includeBlueprints ? Icons.check : Icons.close),
                      const SizedBox(width: 8),
                      Text('Include Blueprints: ${pluginService.includeBlueprints ? 'On' : 'Off'}'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'backupBeforeOptimization',
                  child: Row(
                    children: [
                      Icon(pluginService.backupBeforeOptimization ? Icons.check : Icons.close),
                      const SizedBox(width: 8),
                      Text('Backup: ${pluginService.backupBeforeOptimization ? 'On' : 'Off'}'),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAnalysisTab(pluginService),
          _buildOptimizationTab(pluginService),
          _buildReportsTab(pluginService),
          _buildErrorLogsTab(pluginService),
        ],
      ),
    );
  }

  Widget _buildAnalysisTab(UnrealPluginIntegrationService pluginService) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок
          Text(
            'Project Analysis',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          
          // Выбор проекта
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Unreal Engine Project',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _selectedProjectPath.isEmpty 
                            ? 'No project selected' 
                            : _selectedProjectPath,
                          style: TextStyle(
                            color: _selectedProjectPath.isEmpty 
                              ? Colors.grey 
                              : null,
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _selectProject,
                        icon: const Icon(Icons.folder_open),
                        label: const Text('Browse'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _selectedProjectPath.isNotEmpty && !pluginService.isAnalyzing
                          ? () => _analyzeProject(pluginService)
                          : null,
                        icon: pluginService.isAnalyzing 
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.analytics),
                        label: Text(pluginService.isAnalyzing ? 'Analyzing...' : 'Analyze Project'),
                      ),
                      const SizedBox(width: 8),
                      if (pluginService.analysisResults.isNotEmpty)
                        ElevatedButton.icon(
                          onPressed: () => _clearAnalysisResults(pluginService),
                          icon: const Icon(Icons.clear),
                          label: const Text('Clear Results'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Результаты анализа
          if (pluginService.analysisResults.isNotEmpty)
            Expanded(
              child: UnrealAnalysisResultsWidget(
                results: pluginService.analysisResults,
              ),
            )
          else
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.analytics_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No analysis results yet',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Select a project and click "Analyze Project" to get started',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOptimizationTab(UnrealPluginIntegrationService pluginService) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок
          Text(
            'Code Optimization',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          
          // Выбор файла
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select C++ File to Optimize',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _selectedFilePath.isEmpty 
                            ? 'No file selected' 
                            : _selectedFilePath,
                          style: TextStyle(
                            color: _selectedFilePath.isEmpty 
                              ? Colors.grey 
                              : null,
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _selectFile,
                        icon: const Icon(Icons.file_open),
                        label: const Text('Browse'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _selectedFilePath.isNotEmpty && !pluginService.isOptimizing
                          ? () => _optimizeCode(pluginService)
                          : null,
                        icon: pluginService.isOptimizing 
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.auto_fix_high),
                        label: Text(pluginService.isOptimizing ? 'Optimizing...' : 'Optimize Code'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _selectedProjectPath.isNotEmpty && !pluginService.isOptimizing
                          ? () => _optimizeBlueprints(pluginService)
                          : null,
                        icon: pluginService.isOptimizing 
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.extension),
                        label: const Text('Optimize Blueprints'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Результаты оптимизации
          if (pluginService.optimizationResults.isNotEmpty)
            Expanded(
              child: UnrealOptimizationResultsWidget(
                results: pluginService.optimizationResults,
              ),
            )
          else
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.auto_fix_high_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No optimization results yet',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Select a file and click "Optimize Code" to get started',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReportsTab(UnrealPluginIntegrationService pluginService) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок
          Text(
            'Reports',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          
          // Кнопки генерации отчетов
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Generate Reports',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _selectedProjectPath.isNotEmpty
                          ? () => _generateReport(pluginService)
                          : null,
                        icon: const Icon(Icons.description),
                        label: const Text('Generate Analysis Report'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: pluginService.analysisResults.isNotEmpty
                          ? () => _showAnalysisSummary(pluginService)
                          : null,
                        icon: const Icon(Icons.summarize),
                        label: const Text('Show Summary'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Информация о плагине
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Plugin Information',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  FutureBuilder(
                    future: pluginService.getPluginInfo(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final info = snapshot.data!;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Name: ${info.name}'),
                            Text('Version: ${info.version}'),
                            Text('Description: ${info.description}'),
                            Text('Status: ${pluginService.isPluginAvailable() ? 'Available' : 'Not Available'}'),
                          ],
                        );
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        return const CircularProgressIndicator();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorLogsTab(UnrealPluginIntegrationService pluginService) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок
          Row(
            children: [
              Text(
                'Error Logs',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const Spacer(),
              if (pluginService.errorLogs.isNotEmpty)
                ElevatedButton.icon(
                  onPressed: () => _clearErrorLogs(pluginService),
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear Logs'),
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Логи ошибок
          Expanded(
            child: UnrealErrorLogsWidget(
              logs: pluginService.errorLogs,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectProject() async {
    try {
      final result = await FilePicker.platform.getDirectoryPath();
      if (result != null) {
        setState(() {
          _selectedProjectPath = result;
        });
      }
    } catch (e) {
      _showError('Error selecting project: $e');
    }
  }

  Future<void> _selectFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['cpp', 'h', 'cpppp'],
      );
      
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        setState(() {
          _selectedFilePath = file.path ?? '';
          _fileContent = file.bytes != null 
            ? String.fromCharCodes(file.bytes!)
            : '';
        });
      }
    } catch (e) {
      _showError('Error selecting file: $e');
    }
  }

  Future<void> _analyzeProject(UnrealPluginIntegrationService pluginService) async {
    try {
      await pluginService.analyzeProject(_selectedProjectPath);
      _showSuccess('Project analysis completed successfully!');
    } catch (e) {
      _showError('Error analyzing project: $e');
    }
  }

  Future<void> _optimizeCode(UnrealPluginIntegrationService pluginService) async {
    try {
      await pluginService.optimizeCode(_selectedFilePath, _fileContent);
      _showSuccess('Code optimization completed successfully!');
    } catch (e) {
      _showError('Error optimizing code: $e');
    }
  }

  Future<void> _optimizeBlueprints(UnrealPluginIntegrationService pluginService) async {
    try {
      await pluginService.optimizeBlueprints(_selectedProjectPath);
      _showSuccess('Blueprint optimization completed successfully!');
    } catch (e) {
      _showError('Error optimizing blueprints: $e');
    }
  }

  Future<void> _generateReport(UnrealPluginIntegrationService pluginService) async {
    try {
      final report = await pluginService.generateReport(_selectedProjectPath);
      _showReportDialog(report);
    } catch (e) {
      _showError('Error generating report: $e');
    }
  }

  void _showAnalysisSummary(UnrealPluginIntegrationService pluginService) {
    final results = pluginService.analysisResults;
    if (results.isEmpty) return;
    
    final latestResult = results.last;
    final summary = '''
Analysis Summary:
- Total Files: ${latestResult.totalFiles}
- C++ Files: ${latestResult.cppFiles}
- Blueprint Files: ${latestResult.blueprintFiles}
- Performance Score: ${latestResult.performanceScore}/100
- Issues Found: ${latestResult.issues.length}
- Recommendations: ${latestResult.recommendations.length}
''';
    
    _showReportDialog(summary);
  }

  void _clearAnalysisResults(UnrealPluginIntegrationService pluginService) {
    setState(() {
      // Очистка результатов анализа
    });
  }

  void _clearErrorLogs(UnrealPluginIntegrationService pluginService) {
    pluginService.clearErrorLogs();
  }

  void _handleSettingChange(String setting, UnrealPluginIntegrationService pluginService) {
    switch (setting) {
      case 'autoOptimization':
        pluginService.setEnableAutoOptimization(!pluginService.enableAutoOptimization);
        break;
      case 'optimizationLevel':
        _showOptimizationLevelDialog(pluginService);
        break;
      case 'includeBlueprints':
        pluginService.setIncludeBlueprints(!pluginService.includeBlueprints);
        break;
      case 'backupBeforeOptimization':
        pluginService.setBackupBeforeOptimization(!pluginService.backupBeforeOptimization);
        break;
    }
  }

  void _showOptimizationLevelDialog(UnrealPluginIntegrationService pluginService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Optimization Level'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Basic'),
              leading: Radio<String>(
                value: 'basic',
                groupValue: pluginService.optimizationLevel,
                onChanged: (value) {
                  if (value != null) {
                    pluginService.setOptimizationLevel(value);
                    Navigator.pop(context);
                  }
                },
              ),
            ),
            ListTile(
              title: const Text('Advanced'),
              leading: Radio<String>(
                value: 'advanced',
                groupValue: pluginService.optimizationLevel,
                onChanged: (value) {
                  if (value != null) {
                    pluginService.setOptimizationLevel(value);
                    Navigator.pop(context);
                  }
                },
              ),
            ),
            ListTile(
              title: const Text('Aggressive'),
              leading: Radio<String>(
                value: 'aggressive',
                groupValue: pluginService.optimizationLevel,
                onChanged: (value) {
                  if (value != null) {
                    pluginService.setOptimizationLevel(value);
                    Navigator.pop(context);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReportDialog(String report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: SingleChildScrollView(
            child: Text(
              report,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
