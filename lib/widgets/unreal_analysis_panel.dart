import 'package:flutter/material.dart';
import '../models/unreal_analysis.dart';

class UnrealAnalysisPanel extends StatelessWidget {
  final AnalysisResult analysisResult;

  const UnrealAnalysisPanel({
    super.key,
    required this.analysisResult,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Общая информация
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Результаты анализа',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard(
                          'Всего файлов',
                          '${analysisResult.totalFiles}',
                          Icons.folder,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildInfoCard(
                          'Найдено проблем',
                          '${analysisResult.issues.length}',
                          Icons.warning,
                          Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard(
                          'Оценка производительности',
                          '${analysisResult.performanceScore}/100',
                          Icons.speed,
                          _getPerformanceColor(analysisResult.performanceScore),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildInfoCard(
                          'Дата анализа',
                          _formatDate(analysisResult.analysisDate),
                          Icons.calendar_today,
                          Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Статистика по типам проблем
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Статистика проблем',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildIssueTypeChart(),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Список проблем
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Детальный список проблем',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    
                    Expanded(
                      child: analysisResult.issues.isEmpty
                          ? const Center(
                              child: Text(
                                'Проблем не найдено! 🎉',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.green,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: analysisResult.issues.length,
                              itemBuilder: (context, index) {
                                final issue = analysisResult.issues[index];
                                return _buildIssueCard(issue);
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildIssueTypeChart() {
    final issueTypes = <IssueType, int>{};
    for (final issue in analysisResult.issues) {
      issueTypes[issue.type] = (issueTypes[issue.type] ?? 0) + 1;
    }

    return Column(
      children: issueTypes.entries.map((entry) {
        final type = entry.key;
        final count = entry.value;
        final percentage = (count / analysisResult.issues.length * 100).round();
        
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              SizedBox(
                width: 100,
                child: Text(
                  _getIssueTypeName(type),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              Expanded(
                child: LinearProgressIndicator(
                  value: count / analysisResult.issues.length,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getIssueTypeColor(type),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$count ($percentage%)',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildIssueCard(ProjectIssue issue) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getSeverityColor(issue.severity),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getSeverityName(issue.severity),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getIssueTypeColor(issue.type),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getIssueTypeName(issue.type),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'Строка ${issue.line}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            Text(
              issue.message,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            
            Text(
              issue.suggestion,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 8),
            
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                issue.file,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPerformanceColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  Color _getSeverityColor(IssueSeverity severity) {
    switch (severity) {
      case IssueSeverity.error:
        return Colors.red;
      case IssueSeverity.warning:
        return Colors.orange;
      case IssueSeverity.info:
        return Colors.blue;
    }
  }

  Color _getIssueTypeColor(IssueType type) {
    switch (type) {
      case IssueType.performance:
        return Colors.red;
      case IssueType.memory:
        return Colors.purple;
      case IssueType.codeQuality:
        return Colors.blue;
      case IssueType.compatibility:
        return Colors.amber;
      case IssueType.error:
        return Colors.red.shade800;
    }
  }

  String _getSeverityName(IssueSeverity severity) {
    switch (severity) {
      case IssueSeverity.error:
        return 'ОШИБКА';
      case IssueSeverity.warning:
        return 'ПРЕДУПРЕЖДЕНИЕ';
      case IssueSeverity.info:
        return 'ИНФО';
    }
  }

  String _getIssueTypeName(IssueType type) {
    switch (type) {
      case IssueType.performance:
        return 'Производительность';
      case IssueType.memory:
        return 'Память';
      case IssueType.codeQuality:
        return 'Качество кода';
      case IssueType.compatibility:
        return 'Совместимость';
      case IssueType.error:
        return 'Ошибка';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
