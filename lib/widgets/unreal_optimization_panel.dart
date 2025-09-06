import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/unreal_analysis.dart';
import '../services/unreal_optimizer_service.dart';

class UnrealOptimizationPanel extends StatefulWidget {
  final AnalysisResult analysisResult;

  const UnrealOptimizationPanel({
    super.key,
    required this.analysisResult,
  });

  @override
  State<UnrealOptimizationPanel> createState() => _UnrealOptimizationPanelState();
}

class _UnrealOptimizationPanelState extends State<UnrealOptimizationPanel> {
  final UnrealOptimizerService _optimizerService = UnrealOptimizerService();
  final TextEditingController _codeController = TextEditingController();
  
  bool _isOptimizing = false;
  OptimizationResult? _optimizationResult;
  String _statusMessage = '';

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _optimizeCode() async {
    if (_codeController.text.trim().isEmpty) {
      _showErrorDialog('Введите код для оптимизации');
      return;
    }

    setState(() {
      _isOptimizing = true;
      _statusMessage = 'Оптимизация кода...';
    });

    try {
      final result = await _optimizerService.optimizeCode(
        _codeController.text,
        'temp_file.cpp',
        projectPath: widget.analysisResult.projectPath,
      );

      setState(() {
        _optimizationResult = result;
        _isOptimizing = false;
        _statusMessage = 'Оптимизация завершена';
      });
    } catch (e) {
      setState(() {
        _isOptimizing = false;
        _statusMessage = 'Ошибка оптимизации: $e';
      });
      _showErrorDialog('Ошибка оптимизации кода: $e');
    }
  }

  void _applyOptimization() {
    if (_optimizationResult != null) {
      _codeController.text = _optimizationResult!.optimizedCode;
      setState(() {
        _optimizationResult = null;
        _statusMessage = 'Оптимизация применена';
      });
    }
  }

  void _copyOptimizedCode() {
    if (_optimizationResult != null) {
      Clipboard.setData(ClipboardData(text: _optimizationResult!.optimizedCode));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Оптимизированный код скопирован в буфер обмена')),
      );
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок и статус
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Оптимизация кода',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  if (_statusMessage.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _isOptimizing 
                            ? Colors.blue.shade100 
                            : Colors.green.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _isOptimizing 
                              ? Colors.blue.shade300 
                              : Colors.green.shade300,
                        ),
                      ),
                      child: Row(
                        children: [
                          if (_isOptimizing)
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          else
                            Icon(
                              Icons.check_circle,
                              color: Colors.green.shade700,
                              size: 16,
                            ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _statusMessage,
                              style: TextStyle(
                                color: _isOptimizing 
                                    ? Colors.blue.shade700 
                                    : Colors.green.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Кнопки действий
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _isOptimizing ? null : _optimizeCode,
                        icon: const Icon(Icons.auto_fix_high),
                        label: const Text('Оптимизировать'),
                      ),
                      const SizedBox(width: 16),
                      if (_optimizationResult != null) ...[
                        ElevatedButton.icon(
                          onPressed: _applyOptimization,
                          icon: const Icon(Icons.check),
                          label: const Text('Применить'),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: _copyOptimizedCode,
                          icon: const Icon(Icons.copy),
                          label: const Text('Копировать'),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Редактор кода
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Исходный код',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    
                    Expanded(
                      child: TextField(
                        controller: _codeController,
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Введите C++ код для оптимизации...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Результат оптимизации
          if (_optimizationResult != null) ...[
            const SizedBox(height: 16),
            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Результат оптимизации',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.shade300),
                          ),
                          child: Text(
                            '+${_optimizationResult!.performanceGain}% производительность',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    Container(
                      width: double.infinity,
                      height: 200,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          _optimizationResult!.optimizedCode,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    
                    if (_optimizationResult!.changes.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Внесенные изменения:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      
                      ...(_optimizationResult!.changes.map((change) => 
                        Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Строка ${change.line}: ${_getChangeTypeName(change.type)}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(change.description),
                              if (change.original.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Было: ${change.original}',
                                  style: TextStyle(
                                    color: Colors.red.shade700,
                                    fontFamily: 'monospace',
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                              if (change.optimized.isNotEmpty) ...[
                                Text(
                                  'Стало: ${change.optimized}',
                                  style: TextStyle(
                                    color: Colors.green.shade700,
                                    fontFamily: 'monospace',
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      )),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getChangeTypeName(ChangeType type) {
    switch (type) {
      case ChangeType.replacement:
        return 'Замена';
      case ChangeType.addition:
        return 'Добавление';
      case ChangeType.removal:
        return 'Удаление';
      case ChangeType.refactoring:
        return 'Рефакторинг';
    }
  }
}
