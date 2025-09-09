import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/lyubomir_understanding_service.dart';
import '../models/lyubomir_understanding.dart';

/// Панель настроек понимания Любомира
class LyubomirSettingsPanel extends StatefulWidget {
  const LyubomirSettingsPanel({super.key});

  @override
  State<LyubomirSettingsPanel> createState() => _LyubomirSettingsPanelState();
}

class _LyubomirSettingsPanelState extends State<LyubomirSettingsPanel> {
  late LyubomirSettings _currentSettings;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    final service = context.read<LyubomirUnderstandingService>();
    _currentSettings = service.settings;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LyubomirUnderstandingService>(
      builder: (context, service, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGeneralSettings(),
              const SizedBox(height: 24),
              _buildAnalysisSettings(),
              const SizedBox(height: 24),
              _buildTypeSettings(),
              const SizedBox(height: 24),
              _buildAdvancedSettings(),
              const SizedBox(height: 32),
              _buildActionButtons(service),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGeneralSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Общие настройки',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Включить понимание Любомира'),
              subtitle: const Text('Активирует систему понимания контента'),
              value: _currentSettings.enabled,
              onChanged: (value) {
                setState(() {
                  _currentSettings = _currentSettings.copyWith(enabled: value);
                  _hasChanges = true;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Автоматический анализ'),
              subtitle: const Text('Автоматически анализировать контент'),
              value: _currentSettings.autoAnalyze,
              onChanged: (value) {
                setState(() {
                  _currentSettings = _currentSettings.copyWith(autoAnalyze: value);
                  _hasChanges = true;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Настройки анализа',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Чувствительность'),
              subtitle: Text('${(_currentSettings.sensitivity * 100).toInt()}%'),
              trailing: SizedBox(
                width: 200,
                child: Slider(
                  value: _currentSettings.sensitivity,
                  min: 0.1,
                  max: 1.0,
                  divisions: 9,
                  label: '${(_currentSettings.sensitivity * 100).toInt()}%',
                  onChanged: (value) {
                    setState(() {
                      _currentSettings = _currentSettings.copyWith(sensitivity: value);
                      _hasChanges = true;
                    });
                  },
                ),
              ),
            ),
            const Divider(),
            ListTile(
              title: const Text('Интервал автоматического анализа'),
              subtitle: const Text('Каждые 5 минут'),
              trailing: const Icon(Icons.schedule),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Типы понимания',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Выберите типы контента для анализа',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ...UnderstandingType.values.map((type) {
              final isEnabled = _currentSettings.enabledTypes.contains(type);
              return CheckboxListTile(
                title: Text(_getTypeDisplayName(type)),
                subtitle: Text(_getTypeDescription(type)),
                value: isEnabled,
                onChanged: (value) {
                  setState(() {
                    final newTypes = List<UnderstandingType>.from(_currentSettings.enabledTypes);
                    if (value == true) {
                      newTypes.add(type);
                    } else {
                      newTypes.remove(type);
                    }
                    _currentSettings = _currentSettings.copyWith(enabledTypes: newTypes);
                    _hasChanges = true;
                  });
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Дополнительные настройки',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Сбросить к настройкам по умолчанию'),
              subtitle: const Text('Восстановить все настройки'),
              trailing: const Icon(Icons.restore),
              onTap: _showResetConfirmation,
            ),
            const Divider(),
            ListTile(
              title: const Text('Очистить все данные'),
              subtitle: const Text('Удалить все понимания и результаты'),
              trailing: const Icon(Icons.delete_forever, color: Colors.red),
              onTap: _showClearDataConfirmation,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(LyubomirUnderstandingService service) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _hasChanges ? () => _saveSettings(service) : null,
            child: const Text('Сохранить'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _hasChanges ? () => _resetChanges() : null,
            child: const Text('Отменить'),
          ),
        ),
      ],
    );
  }

  String _getTypeDisplayName(UnderstandingType type) {
    switch (type) {
      case UnderstandingType.visual:
        return 'Визуальное понимание';
      case UnderstandingType.audio:
        return 'Аудиальное понимание';
      case UnderstandingType.text:
        return 'Текстовое понимание';
      case UnderstandingType.spatial:
        return 'Пространственное понимание';
      case UnderstandingType.semantic:
        return 'Семантическое понимание';
      case UnderstandingType.interactive:
        return 'Интерактивное понимание';
    }
  }

  String _getTypeDescription(UnderstandingType type) {
    switch (type) {
      case UnderstandingType.visual:
        return 'Анализ изображений, цветов, объектов';
      case UnderstandingType.audio:
        return 'Анализ звука, музыки, речи';
      case UnderstandingType.text:
        return 'Анализ текста, эмоций, ключевых слов';
      case UnderstandingType.spatial:
        return 'Анализ 3D пространства, геометрии';
      case UnderstandingType.semantic:
        return 'Понимание смысла и контекста';
      case UnderstandingType.interactive:
        return 'Анализ взаимодействий и UX';
    }
  }

  void _saveSettings(LyubomirUnderstandingService service) async {
    service.updateSettings(_currentSettings);
    setState(() {
      _hasChanges = false;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Настройки сохранены'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _resetChanges() {
    final service = context.read<LyubomirUnderstandingService>();
    setState(() {
      _currentSettings = service.settings;
      _hasChanges = false;
    });
  }

  void _showResetConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Сбросить настройки?'),
        content: const Text('Все настройки будут восстановлены к значениям по умолчанию.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetToDefaults();
            },
            child: const Text('Сбросить'),
          ),
        ],
      ),
    );
  }

  void _showClearDataConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Очистить все данные?'),
        content: const Text('Все понимания и результаты анализа будут удалены. Это действие нельзя отменить.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _clearAllData();
            },
            child: const Text('Очистить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _resetToDefaults() async {
    final service = context.read<LyubomirUnderstandingService>();
    await service.resetToDefaults();
    setState(() {
      _currentSettings = service.settings;
      _hasChanges = false;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Настройки сброшены'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _clearAllData() async {
    final service = context.read<LyubomirUnderstandingService>();
    await service.clearAllData();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Все данные очищены'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
