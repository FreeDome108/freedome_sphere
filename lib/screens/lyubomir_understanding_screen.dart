import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/lyubomir_understanding_service.dart';
import '../models/lyubomir_understanding.dart';
import '../widgets/lyubomir_understanding_panel.dart';
import '../widgets/lyubomir_settings_panel.dart';

/// Экран управления пониманием Любомира
class LyubomirUnderstandingScreen extends StatefulWidget {
  const LyubomirUnderstandingScreen({super.key});

  @override
  State<LyubomirUnderstandingScreen> createState() => _LyubomirUnderstandingScreenState();
}

class _LyubomirUnderstandingScreenState extends State<LyubomirUnderstandingScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeService();
  }

  Future<void> _initializeService() async {
    final service = context.read<LyubomirUnderstandingService>();
    await service.initialize();
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Понимание Любомира'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.psychology),
              text: 'Понимания',
            ),
            Tab(
              icon: Icon(Icons.analytics),
              text: 'Анализ',
            ),
            Tab(
              icon: Icon(Icons.settings),
              text: 'Настройки',
            ),
          ],
        ),
        actions: [
          Consumer<LyubomirUnderstandingService>(
            builder: (context, service, child) {
              return Switch(
                value: service.isEnabled,
                onChanged: (value) async {
                  final newSettings = service.settings.copyWith(enabled: value);
                  service.updateSettings(newSettings);
                },
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _UnderstandingsTab(),
          _AnalysisTab(),
          _SettingsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateUnderstandingDialog,
        tooltip: 'Создать понимание',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateUnderstandingDialog() {
    showDialog(
      context: context,
      builder: (context) => const _CreateUnderstandingDialog(),
    );
  }
}

/// Вкладка с пониманиями
class _UnderstandingsTab extends StatelessWidget {
  const _UnderstandingsTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<LyubomirUnderstandingService>(
      builder: (context, service, child) {
        final understandings = service.understandings;

        if (understandings.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.psychology_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'Нет пониманий',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Создайте новое понимание для анализа контента',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: understandings.length,
          itemBuilder: (context, index) {
            final understanding = understandings[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getTypeColor(understanding.type),
                  child: Icon(
                    _getTypeIcon(understanding.type),
                    color: Colors.white,
                  ),
                ),
                title: Text(understanding.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(understanding.description),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _StatusChip(status: understanding.status),
                        const SizedBox(width: 8),
                        Text(
                          '${understanding.results.length} результатов',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) => _handleMenuAction(context, understanding, value),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'analyze',
                      child: ListTile(
                        leading: Icon(Icons.analytics),
                        title: Text('Анализировать'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'view',
                      child: ListTile(
                        leading: Icon(Icons.visibility),
                        title: Text('Просмотреть'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete, color: Colors.red),
                        title: Text('Удалить', style: TextStyle(color: Colors.red)),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
                onTap: () => _showUnderstandingDetails(context, understanding),
              ),
            );
          },
        );
      },
    );
  }

  Color _getTypeColor(UnderstandingType type) {
    switch (type) {
      case UnderstandingType.visual:
        return Colors.blue;
      case UnderstandingType.audio:
        return Colors.green;
      case UnderstandingType.text:
        return Colors.orange;
      case UnderstandingType.spatial:
        return Colors.purple;
      case UnderstandingType.semantic:
        return Colors.red;
      case UnderstandingType.interactive:
        return Colors.teal;
    }
  }

  IconData _getTypeIcon(UnderstandingType type) {
    switch (type) {
      case UnderstandingType.visual:
        return Icons.visibility;
      case UnderstandingType.audio:
        return Icons.audiotrack;
      case UnderstandingType.text:
        return Icons.text_fields;
      case UnderstandingType.spatial:
        return Icons.view_in_ar;
      case UnderstandingType.semantic:
        return Icons.psychology;
      case UnderstandingType.interactive:
        return Icons.touch_app;
    }
  }

  void _handleMenuAction(
    BuildContext context,
    LyubomirUnderstanding understanding,
    String action,
  ) {
    final service = context.read<LyubomirUnderstandingService>();

    switch (action) {
      case 'analyze':
        service.analyzeContent(understanding.id);
        break;
      case 'view':
        _showUnderstandingDetails(context, understanding);
        break;
      case 'delete':
        _showDeleteConfirmation(context, understanding, service);
        break;
    }
  }

  void _showUnderstandingDetails(
    BuildContext context,
    LyubomirUnderstanding understanding,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _UnderstandingDetailsScreen(understanding: understanding),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    LyubomirUnderstanding understanding,
    LyubomirUnderstandingService service,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить понимание?'),
        content: Text('Вы уверены, что хотите удалить "${understanding.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              service.deleteUnderstanding(understanding.id);
              Navigator.of(context).pop();
            },
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

/// Чип статуса
class _StatusChip extends StatelessWidget {
  final UnderstandingStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        _getStatusText(status),
        style: const TextStyle(fontSize: 12, color: Colors.white),
      ),
      backgroundColor: _getStatusColor(status),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  String _getStatusText(UnderstandingStatus status) {
    switch (status) {
      case UnderstandingStatus.idle:
        return 'Ожидание';
      case UnderstandingStatus.analyzing:
        return 'Анализ';
      case UnderstandingStatus.processing:
        return 'Обработка';
      case UnderstandingStatus.completed:
        return 'Завершено';
      case UnderstandingStatus.error:
        return 'Ошибка';
      case UnderstandingStatus.paused:
        return 'Приостановлено';
    }
  }

  Color _getStatusColor(UnderstandingStatus status) {
    switch (status) {
      case UnderstandingStatus.idle:
        return Colors.grey;
      case UnderstandingStatus.analyzing:
        return Colors.blue;
      case UnderstandingStatus.processing:
        return Colors.orange;
      case UnderstandingStatus.completed:
        return Colors.green;
      case UnderstandingStatus.error:
        return Colors.red;
      case UnderstandingStatus.paused:
        return Colors.amber;
    }
  }
}

/// Вкладка анализа
class _AnalysisTab extends StatelessWidget {
  const _AnalysisTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<LyubomirUnderstandingService>(
      builder: (context, service, child) {
        final understandings = service.understandings;
        final completedUnderstandings = understandings
            .where((u) => u.status == UnderstandingStatus.completed)
            .toList();

        if (completedUnderstandings.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.analytics_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'Нет завершенных анализов',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Запустите анализ пониманий для просмотра результатов',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: completedUnderstandings.length,
          itemBuilder: (context, index) {
            final understanding = completedUnderstandings[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                title: Text(understanding.name),
                subtitle: Text('${understanding.results.length} результатов'),
                children: understanding.results.map((result) {
                  return ListTile(
                    title: Text(result.type),
                    subtitle: Text('Уверенность: ${(result.confidence * 100).toStringAsFixed(1)}%'),
                    trailing: Text(
                      '${result.tags.length} тегов',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    onTap: () => _showResultDetails(context, result),
                  );
                }).toList(),
              ),
            );
          },
        );
      },
    );
  }

  void _showResultDetails(BuildContext context, UnderstandingResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(result.type),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Уверенность: ${(result.confidence * 100).toStringAsFixed(1)}%'),
              const SizedBox(height: 8),
              Text('Теги: ${result.tags.join(', ')}'),
              const SizedBox(height: 8),
              const Text('Данные:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                result.data.toString(),
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }
}

/// Вкладка настроек
class _SettingsTab extends StatelessWidget {
  const _SettingsTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<LyubomirUnderstandingService>(
      builder: (context, service, child) {
        return const LyubomirSettingsPanel();
      },
    );
  }
}

/// Диалог создания понимания
class _CreateUnderstandingDialog extends StatefulWidget {
  const _CreateUnderstandingDialog();

  @override
  State<_CreateUnderstandingDialog> createState() => _CreateUnderstandingDialogState();
}

class _CreateUnderstandingDialogState extends State<_CreateUnderstandingDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  UnderstandingType _selectedType = UnderstandingType.semantic;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Создать понимание'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Название',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Введите название';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Описание',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Введите описание';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<UnderstandingType>(
              initialValue: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Тип понимания',
                border: OutlineInputBorder(),
              ),
              items: UnderstandingType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(_getTypeDisplayName(type)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedType = value;
                  });
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: _createUnderstanding,
          child: const Text('Создать'),
        ),
      ],
    );
  }

  String _getTypeDisplayName(UnderstandingType type) {
    switch (type) {
      case UnderstandingType.visual:
        return 'Визуальное';
      case UnderstandingType.audio:
        return 'Аудиальное';
      case UnderstandingType.text:
        return 'Текстовое';
      case UnderstandingType.spatial:
        return 'Пространственное';
      case UnderstandingType.semantic:
        return 'Семантическое';
      case UnderstandingType.interactive:
        return 'Интерактивное';
    }
  }

  void _createUnderstanding() {
    if (_formKey.currentState!.validate()) {
      final service = context.read<LyubomirUnderstandingService>();
      service.createUnderstanding(
        name: _nameController.text,
        description: _descriptionController.text,
        type: _selectedType,
      );
      Navigator.of(context).pop();
    }
  }
}

/// Экран деталей понимания
class _UnderstandingDetailsScreen extends StatelessWidget {
  final LyubomirUnderstanding understanding;

  const _UnderstandingDetailsScreen({required this.understanding});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(understanding.name),
        actions: [
          Consumer<LyubomirUnderstandingService>(
            builder: (context, service, child) {
              return IconButton(
                icon: const Icon(Icons.analytics),
                onPressed: () => service.analyzeContent(understanding.id),
                tooltip: 'Анализировать',
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
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
                    Text(
                      'Описание',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(understanding.description),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text(
                          'Тип: ',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Text(_getTypeDisplayName(understanding.type)),
                        const Spacer(),
                        _StatusChip(status: understanding.status),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Создано: ${_formatDateTime(understanding.createdAt)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (understanding.lastAnalyzed != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Последний анализ: ${_formatDateTime(understanding.lastAnalyzed!)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Результаты анализа (${understanding.results.length})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (understanding.results.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: Text(
                      'Нет результатов анализа',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              )
            else
              ...understanding.results.map((result) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(result.type),
                    subtitle: Text('Уверенность: ${(result.confidence * 100).toStringAsFixed(1)}%'),
                    trailing: Text(
                      '${result.tags.length} тегов',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    onTap: () => _showResultDetails(context, result),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  String _getTypeDisplayName(UnderstandingType type) {
    switch (type) {
      case UnderstandingType.visual:
        return 'Визуальное';
      case UnderstandingType.audio:
        return 'Аудиальное';
      case UnderstandingType.text:
        return 'Текстовое';
      case UnderstandingType.spatial:
        return 'Пространственное';
      case UnderstandingType.semantic:
        return 'Семантическое';
      case UnderstandingType.interactive:
        return 'Интерактивное';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}.${dateTime.month}.${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _showResultDetails(BuildContext context, UnderstandingResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(result.type),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Уверенность: ${(result.confidence * 100).toStringAsFixed(1)}%'),
              const SizedBox(height: 8),
              Text('Теги: ${result.tags.join(', ')}'),
              const SizedBox(height: 8),
              const Text('Данные:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                result.data.toString(),
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }
}
