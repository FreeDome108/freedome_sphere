import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/lyubomir_understanding_service.dart';
import '../models/lyubomir_understanding.dart';
import '../screens/lyubomir_understanding_screen.dart';

/// Панель понимания Любомира для главного экрана
class LyubomirUnderstandingPanel extends StatelessWidget {
  const LyubomirUnderstandingPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LyubomirUnderstandingService>(
      builder: (context, service, child) {
        if (!service.isEnabled) {
          return const SizedBox.shrink();
        }

        return Card(
          margin: const EdgeInsets.all(8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.psychology, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      'Понимание Любомира',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Spacer(),
                    _StatusIndicator(service: service),
                  ],
                ),
                const SizedBox(height: 12),
                _buildStats(service),
                const SizedBox(height: 12),
                _buildQuickActions(context, service),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStats(LyubomirUnderstandingService service) {
    final understandings = service.understandings;
    final completedCount = understandings.where((u) => u.status == UnderstandingStatus.completed).length;
    final analyzingCount = understandings.where((u) => u.status == UnderstandingStatus.analyzing).length;
    final totalResults = understandings.fold<int>(0, (sum, u) => sum + u.results.length);

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'Всего',
            value: understandings.length.toString(),
            icon: Icons.psychology_outlined,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            title: 'Завершено',
            value: completedCount.toString(),
            icon: Icons.check_circle_outline,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            title: 'Анализ',
            value: analyzingCount.toString(),
            icon: Icons.analytics_outlined,
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            title: 'Результаты',
            value: totalResults.toString(),
            icon: Icons.insights_outlined,
            color: Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context, LyubomirUnderstandingService service) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _navigateToUnderstandingScreen(context),
            icon: const Icon(Icons.psychology),
            label: const Text('Управление'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: service.understandings.isNotEmpty 
                ? () => _startQuickAnalysis(service)
                : null,
            icon: const Icon(Icons.analytics),
            label: const Text('Анализ'),
          ),
        ),
      ],
    );
  }

  void _navigateToUnderstandingScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const LyubomirUnderstandingScreen(),
      ),
    );
  }

  void _startQuickAnalysis(LyubomirUnderstandingService service) {
    final idleUnderstandings = service.understandings
        .where((u) => u.status == UnderstandingStatus.idle)
        .toList();

    if (idleUnderstandings.isNotEmpty) {
      // Запускаем анализ первого доступного понимания
      service.analyzeContent(idleUnderstandings.first.id);
    }
  }
}

/// Индикатор статуса
class _StatusIndicator extends StatelessWidget {
  final LyubomirUnderstandingService service;

  const _StatusIndicator({required this.service});

  @override
  Widget build(BuildContext context) {
    final hasActiveAnalysis = service.understandings
        .any((u) => u.status == UnderstandingStatus.analyzing);

    if (hasActiveAnalysis) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'Анализ',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: service.isEnabled ? Colors.green : Colors.grey,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          service.isEnabled ? 'Активно' : 'Отключено',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: service.isEnabled ? Colors.green : Colors.grey,
          ),
        ),
      ],
    );
  }
}

/// Карточка статистики
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 16,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Мини-панель для отображения последних результатов
class LyubomirRecentResults extends StatelessWidget {
  const LyubomirRecentResults({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LyubomirUnderstandingService>(
      builder: (context, service, child) {
        final recentResults = _getRecentResults(service.understandings);

        if (recentResults.isEmpty) {
          return const SizedBox.shrink();
        }

        return Card(
          margin: const EdgeInsets.all(8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.insights, color: Colors.purple),
                    const SizedBox(width: 8),
                    Text(
                      'Последние результаты',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => _navigateToUnderstandingScreen(context),
                      child: const Text('Все'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...recentResults.take(3).map((result) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: _getConfidenceColor(result.confidence),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            result.type.name,
                            style: Theme.of(context).textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${(result.confidence * 100).toInt()}%',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: _getConfidenceColor(result.confidence),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  List<UnderstandingResult> _getRecentResults(List<LyubomirUnderstanding> understandings) {
    final allResults = <UnderstandingResult>[];
    
    for (final understanding in understandings) {
      allResults.addAll(understanding.results);
    }
    
    allResults.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return allResults;
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return Colors.green;
    if (confidence >= 0.6) return Colors.orange;
    return Colors.red;
  }

  void _navigateToUnderstandingScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const LyubomirUnderstandingScreen(),
      ),
    );
  }
}
