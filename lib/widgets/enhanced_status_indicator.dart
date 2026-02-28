/// Enhanced Status Indicator Widget
/// 
/// Provides color-coded status indicators with detailed information

import 'package:flutter/material.dart';

enum StatusType {
  success,
  warning,
  error,
  info,
  loading,
}

class EnhancedStatusIndicator extends StatelessWidget {
  final String label;
  final StatusType status;
  final String? details;
  final VoidCallback? onRetry;
  final bool expanded;

  const EnhancedStatusIndicator({
    super.key,
    required this.label,
    required this.status,
    this.details,
    this.onRetry,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor();
    final icon = _getStatusIcon();

    if (expanded) {
      return Card(
        color: color.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                  if (status == StatusType.loading)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  if (onRetry != null && status == StatusType.error)
                    ElevatedButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Повтор'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                      ),
                    ),
                ],
              ),
              if (details != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    details!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    // Compact version
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (status == StatusType.loading)
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          else
            Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (status) {
      case StatusType.success:
        return Colors.green;
      case StatusType.warning:
        return Colors.orange;
      case StatusType.error:
        return Colors.red;
      case StatusType.info:
        return Colors.blue;
      case StatusType.loading:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon() {
    switch (status) {
      case StatusType.success:
        return Icons.check_circle;
      case StatusType.warning:
        return Icons.warning;
      case StatusType.error:
        return Icons.error;
      case StatusType.info:
        return Icons.info;
      case StatusType.loading:
        return Icons.hourglass_empty;
    }
  }
}

/// Status Row Widget for displaying multiple status indicators
class StatusRow extends StatelessWidget {
  final List<Map<String, dynamic>> statuses;

  const StatusRow({
    super.key,
    required this.statuses,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: statuses.map((status) {
        return EnhancedStatusIndicator(
          label: status['label'] as String,
          status: status['status'] as StatusType,
          details: status['details'] as String?,
          expanded: status['expanded'] as bool? ?? false,
          onRetry: status['onRetry'] as VoidCallback?,
        );
      }).toList(),
    );
  }
}
