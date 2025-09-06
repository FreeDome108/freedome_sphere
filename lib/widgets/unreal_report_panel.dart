import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UnrealReportPanel extends StatelessWidget {
  final String reportContent;

  const UnrealReportPanel({
    super.key,
    required this.reportContent,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок и действия
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text(
                    'Отчет об анализе',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: () => _copyReport(context),
                    icon: const Icon(Icons.copy),
                    label: const Text('Копировать'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _shareReport(context),
                    icon: const Icon(Icons.share),
                    label: const Text('Поделиться'),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Содержимое отчета
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: _buildReportContent(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportContent() {
    final lines = reportContent.split('\n');
    final widgets = <Widget>[];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      
      if (line.startsWith('# ')) {
        // Заголовок H1
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Text(
              line.substring(2),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
        );
      } else if (line.startsWith('## ')) {
        // Заголовок H2
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 6),
            child: Text(
              line.substring(3),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
        );
      } else if (line.startsWith('### ')) {
        // Заголовок H3
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: Text(
              line.substring(4),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ),
        );
      } else if (line.startsWith('**') && line.endsWith('**')) {
        // Жирный текст
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              line.substring(2, line.length - 2),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        );
      } else if (line.startsWith('• ')) {
        // Список
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 2, bottom: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(
                  child: Text(
                    line.substring(2),
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        );
      } else if (line.trim().isEmpty) {
        // Пустая строка
        widgets.add(const SizedBox(height: 8));
      } else {
        // Обычный текст
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              line,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  void _copyReport(BuildContext context) {
    Clipboard.setData(ClipboardData(text: reportContent));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Отчет скопирован в буфер обмена'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _shareReport(BuildContext context) {
    // Здесь можно добавить логику для отправки отчета
    // Например, через email, мессенджеры и т.д.
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Поделиться отчетом'),
        content: const Text(
          'Функция отправки отчета будет добавлена в следующих версиях. '
          'Пока что вы можете скопировать отчет и отправить его вручную.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
