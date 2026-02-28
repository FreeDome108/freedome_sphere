/// Calibration History Panel Widget
/// 
/// Displays history of calibration results

import 'package:flutter/material.dart';

class CalibrationHistoryPanel extends StatelessWidget {
  final List<Map<String, dynamic>> history;
  final VoidCallback? onClearHistory;

  const CalibrationHistoryPanel({
    super.key,
    required this.history,
    this.onClearHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.history,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'История калибровок',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                if (history.isNotEmpty && onClearHistory != null)
                  TextButton.icon(
                    onPressed: onClearHistory,
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Очистить'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (history.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.history_toggle_off, size: 48, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'История пуста',
                        style: TextStyle(color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Калибровки появятся здесь',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: history.length > 5 ? 5 : history.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final record = history[index];
                  return _CalibrationRecordTile(record: record);
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _CalibrationRecordTile extends StatelessWidget {
  final Map<String, dynamic> record;

  const _CalibrationRecordTile({required this.record});

  @override
  Widget build(BuildContext context) {
    final isSuccess = record['success'] as bool;
    final type = record['type'] as String;
    final timestamp = record['timestamp'] as DateTime;
    final latency = record['latency'] as double?;
    final resolution = record['resolution'] as String?;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isSuccess ? Icons.check_circle : Icons.error,
            color: isSuccess ? Colors.green : Colors.red,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      type == 'audio' ? 'Аудио' : 'Видео',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isSuccess ? Colors.green.shade100 : Colors.red.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isSuccess ? 'Успех' : 'Ошибка',
                        style: TextStyle(
                          fontSize: 10,
                          color: isSuccess ? Colors.green.shade800 : Colors.red.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${timestamp.day}.${timestamp.month}.${timestamp.year} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (latency != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Задержка: ${latency}мс',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                if (resolution != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Разрешение: $resolution',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
