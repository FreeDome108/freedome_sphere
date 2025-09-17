import 'package:flutter/material.dart';
import '../models/comics_project.dart';

/// Виджет для отображения списка импортированных .comics файлов
class ComicsListWidget extends StatelessWidget {
  final List<ComicsProject> comicsProjects;
  final Function(ComicsProject)? onComicsSelected;
  final Function(ComicsProject)? onComicsDeleted;

  const ComicsListWidget({
    super.key,
    required this.comicsProjects,
    this.onComicsSelected,
    this.onComicsDeleted,
  });

  @override
  Widget build(BuildContext context) {
    if (comicsProjects.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      itemCount: comicsProjects.length,
      itemBuilder: (context, index) {
        final project = comicsProjects[index];
        return _buildComicsCard(context, project);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.library_books_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Нет импортированных комиксов',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Импортируйте .comics файлы для начала работы',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildComicsCard(BuildContext context, ComicsProject project) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => onComicsSelected?.call(project),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок
              Row(
                children: [
                  Icon(
                    Icons.book,
                    color: Theme.of(context).primaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (project.author != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            project.author!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'info':
                          _showComicsInfo(context, project);
                          break;
                        case 'delete':
                          _confirmDelete(context, project);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'info',
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, size: 18),
                            SizedBox(width: 8),
                            Text('Информация'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Удалить', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Описание
              if (project.description != null) ...[
                Text(
                  project.description!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
              ],

              // Статистика
              Row(
                children: [
                  _buildStatChip(
                    Icons.image,
                    '${project.pageCount} страниц',
                    Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  if (project.duration != null)
                    _buildStatChip(
                      Icons.access_time,
                      _formatDuration(project.duration!),
                      Colors.green,
                    ),
                  const SizedBox(width: 8),
                  _buildStatChip(
                    Icons.folder,
                    _getFileExtension(project.originalPath),
                    Colors.orange,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Метаданные
              Row(
                children: [
                  if (project.metadata.domeOptimized)
                    _buildMetadataChip('Купол', Colors.purple),
                  if (project.metadata.quantumCompatible)
                    _buildMetadataChip('Квант', Colors.indigo),
                  const Spacer(),
                  Text(
                    'Импортирован: ${_formatDate(project.importedAt)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataChip(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _getFileExtension(String filePath) {
    final parts = filePath.split('.');
    return parts.length > 1 ? parts.last.toUpperCase() : 'UNKNOWN';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  void _showComicsInfo(BuildContext context, ComicsProject project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(project.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (project.author != null) ...[
                Text('Автор: ${project.author}'),
                const SizedBox(height: 8),
              ],
              if (project.description != null) ...[
                Text('Описание: ${project.description}'),
                const SizedBox(height: 8),
              ],
              Text('Страниц: ${project.pageCount}'),
              if (project.duration != null) ...[
                const SizedBox(height: 4),
                Text('Длительность: ${_formatDuration(project.duration!)}'),
              ],
              const SizedBox(height: 8),
              Text('Путь: ${project.originalPath}'),
              const SizedBox(height: 8),
              Text('Импортирован: ${_formatDate(project.importedAt)}'),
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

  void _confirmDelete(BuildContext context, ComicsProject project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить комикс'),
        content: Text('Вы уверены, что хотите удалить "${project.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onComicsDeleted?.call(project);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }
}
