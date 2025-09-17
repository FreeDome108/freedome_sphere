import 'package:flutter/material.dart';
import '../models/comics_project.dart';
import '../services/comics_service.dart';

/// Диалог для отображения информации о .comics файле
class ComicsInfoDialog extends StatefulWidget {
  final String filePath;

  const ComicsInfoDialog({
    super.key,
    required this.filePath,
  });

  @override
  State<ComicsInfoDialog> createState() => _ComicsInfoDialogState();
}

class _ComicsInfoDialogState extends State<ComicsInfoDialog> {
  final ComicsService _comicsService = ComicsService();
  Map<String, dynamic>? _comicsInfo;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadComicsInfo();
  }

  Future<void> _loadComicsInfo() async {
    try {
      final info = await _comicsService.getComicsInfo(widget.filePath);
      setState(() {
        _comicsInfo = info;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Информация о .comics файле'),
      content: SizedBox(
        width: 400,
        child: _buildContent(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Закрыть'),
        ),
        if (_comicsInfo != null)
          ElevatedButton(
            onPressed: () => _importComics(),
            child: const Text('Импортировать'),
          ),
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Загрузка информации...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Ошибка загрузки:',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    if (_comicsInfo == null) {
      return const Text('Информация не найдена');
    }

    return _buildComicsInfo();
  }

  Widget _buildComicsInfo() {
    final info = _comicsInfo!;
    final metadata = info['metadata'] as Map<String, dynamic>?;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Основная информация
          _buildInfoSection(
            'Основная информация',
            [
              _buildInfoRow('Имя файла', info['fileName'] ?? 'Неизвестно'),
              _buildInfoRow('Размер файла', _formatFileSize(info['fileSize'] ?? 0)),
              _buildInfoRow('Количество страниц', '${info['pageCount'] ?? 0}'),
              _buildInfoRow('Метаданные', info['hasMetadata'] == true ? 'Есть' : 'Нет'),
            ],
          ),

          const SizedBox(height: 16),

          // Метаданные
          if (metadata != null) ...[
            _buildInfoSection(
              'Метаданные',
              [
                _buildInfoRow('Название', metadata['title'] ?? 'Не указано'),
                _buildInfoRow('Автор', metadata['author'] ?? 'Не указан'),
                _buildInfoRow('Описание', metadata['description'] ?? 'Не указано'),
                _buildInfoRow('Длительность', _formatDuration(metadata['duration'])),
                _buildInfoRow('Язык', metadata['metadata']?['language'] ?? 'Не указан'),
                _buildInfoRow('Формат', metadata['metadata']?['format'] ?? 'comics'),
                _buildInfoRow('Версия', '${metadata['metadata']?['version'] ?? 1}'),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // Список страниц
          if (info['pages'] != null && (info['pages'] as List).isNotEmpty) ...[
            _buildInfoSection(
              'Страницы',
              [
                for (int i = 0; i < (info['pages'] as List).length && i < 5; i++)
                  _buildInfoRow(
                    'Страница ${i + 1}',
                    (info['pages'] as List)[i],
                  ),
                if ((info['pages'] as List).length > 5)
                  _buildInfoRow(
                    '...',
                    'и еще ${(info['pages'] as List).length - 5} страниц',
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String _formatDuration(dynamic duration) {
    if (duration == null) return 'Не указано';
    final seconds = duration is int ? duration : duration.toInt();
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Future<void> _importComics() async {
    try {
      // TODO: Реализовать импорт через ComicsService
      // final result = await _comicsService.importComicsFile(widget.filePath);
      // if (result.success) {
      //   // Добавить в проект
      //   Navigator.of(context).pop();
      // }
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Импорт .comics файла будет реализован в следующей версии'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка импорта: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
