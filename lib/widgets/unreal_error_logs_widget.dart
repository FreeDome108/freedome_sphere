import 'package:flutter/material.dart';
import '../services/unreal_plugin_integration_service.dart';

class UnrealErrorLogsWidget extends StatelessWidget {
  final List<ErrorLog> logs;

  const UnrealErrorLogsWidget({
    super.key,
    required this.logs,
  });

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: Colors.green[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No errors in logs',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.green[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'All operations completed successfully',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ExpansionTile(
            title: Row(
              children: [
                Icon(
                  _getErrorIcon(log.component),
                  color: _getErrorColor(log.component),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    log.component,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  _formatTime(log.timestamp),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            subtitle: Text(
              log.message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Сообщение об ошибке
                    _buildErrorMessage(log.message),
                    const SizedBox(height: 16),
                    
                    // Контекст
                    if (log.context.isNotEmpty) ...[
                      _buildContextSection(context, log.context),
                      const SizedBox(height: 16),
                    ],
                    
                    // Время и компонент
                    _buildMetadataSection(log),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorMessage(String message) {
    return Card(
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.error, color: Colors.red[700], size: 20),
                const SizedBox(width: 8),
                Text(
                  'Error Message',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                color: Colors.red[800],
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContextSection(BuildContext context, Map<String, dynamic> contextData) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: Colors.blue[700], size: 20),
                const SizedBox(width: 8),
                Text(
                  'Context',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...contextData.entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 100,
                    child: Text(
                      '${entry.key}:',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      entry.value.toString(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataSection(ErrorLog log) {
    return Card(
      color: Colors.grey[50],
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.grey[700], size: 20),
                const SizedBox(width: 8),
                Text(
                  'Metadata',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildMetadataItem('Component', log.component),
                ),
                Expanded(
                  child: _buildMetadataItem('Timestamp', _formatDateTime(log.timestamp)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  IconData _getErrorIcon(String component) {
    switch (component.toLowerCase()) {
      case 'projectanalyzer':
        return Icons.analytics;
      case 'codeoptimizer':
        return Icons.auto_fix_high;
      case 'blueprintoptimizer':
        return Icons.extension;
      case 'reportgenerator':
        return Icons.description;
      case 'autooptimizer':
        return Icons.settings;
      default:
        return Icons.error;
    }
  }

  Color _getErrorColor(String component) {
    switch (component.toLowerCase()) {
      case 'projectanalyzer':
        return Colors.blue;
      case 'codeoptimizer':
        return Colors.orange;
      case 'blueprintoptimizer':
        return Colors.purple;
      case 'reportgenerator':
        return Colors.green;
      case 'autooptimizer':
        return Colors.grey;
      default:
        return Colors.red;
    }
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${_formatTime(dateTime)}';
  }
}
