import 'package:flutter/material.dart';
import '../services/unreal_plugin_integration_service.dart';

class UnrealAnalysisResultsWidget extends StatelessWidget {
  final List<AnalysisResult> results;

  const UnrealAnalysisResultsWidget({
    super.key,
    required this.results,
  });

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return const Center(
        child: Text('No analysis results available'),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final result = results[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ExpansionTile(
            title: Text('Analysis ${index + 1}'),
            subtitle: Text(
              '${result.totalFiles} files, ${result.issues.length} issues, Score: ${result.performanceScore}/100',
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Основная информация
                    _buildInfoSection(context, result),
                    const SizedBox(height: 16),
                    
                    // Проблемы
                    if (result.issues.isNotEmpty) ...[
                      _buildIssuesSection(context, result.issues),
                      const SizedBox(height: 16),
                    ],
                    
                    // Рекомендации
                    if (result.recommendations.isNotEmpty) ...[
                      _buildRecommendationsSection(context, result.recommendations),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoSection(BuildContext context, AnalysisResult result) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Project Information',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem('Project Path', result.projectPath),
                ),
                Expanded(
                  child: _buildInfoItem('Analysis Date', _formatDate(result.timestamp)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem('Total Files', result.totalFiles.toString()),
                ),
                Expanded(
                  child: _buildInfoItem('C++ Files', result.cppFiles.toString()),
                ),
                Expanded(
                  child: _buildInfoItem('Blueprint Files', result.blueprintFiles.toString()),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem('Performance Score', '${result.performanceScore}/100'),
                ),
                Expanded(
                  child: _buildInfoItem('Issues Found', result.issues.length.toString()),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Индикатор производительности
            _buildPerformanceIndicator(result.performanceScore),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
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
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildPerformanceIndicator(int score) {
    Color color;
    if (score >= 80) {
      color = Colors.green;
    } else if (score >= 60) {
      color = Colors.orange;
    } else {
      color = Colors.red;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Performance Score'),
            Text('$score/100'),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: score / 100,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  Widget _buildIssuesSection(BuildContext context, List<AnalysisIssue> issues) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Issues Found (${issues.length})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 300,
              child: ListView.builder(
                itemCount: issues.length,
                itemBuilder: (context, index) {
                  final issue = issues[index];
                  return _buildIssueItem(context, issue);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIssueItem(BuildContext context, AnalysisIssue issue) {
    Color severityColor;
    IconData severityIcon;
    
    switch (issue.severity.toLowerCase()) {
      case 'error':
        severityColor = Colors.red;
        severityIcon = Icons.error;
        break;
      case 'warning':
        severityColor = Colors.orange;
        severityIcon = Icons.warning;
        break;
      case 'info':
        severityColor = Colors.blue;
        severityIcon = Icons.info;
        break;
      default:
        severityColor = Colors.grey;
        severityIcon = Icons.help;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(severityIcon, color: severityColor),
        title: Text(issue.message),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('File: ${issue.file}'),
            if (issue.line > 0) Text('Line: ${issue.line}'),
            Text('Type: ${issue.type}'),
            if (issue.suggestion.isNotEmpty)
              Text('Suggestion: ${issue.suggestion}'),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildRecommendationsSection(BuildContext context, List<String> recommendations) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recommendations (${recommendations.length})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...recommendations.map((recommendation) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb, color: Colors.amber, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      recommendation,
                      style: const TextStyle(fontSize: 14),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
