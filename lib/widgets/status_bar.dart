import 'package:flutter/material.dart';

class StatusBar extends StatelessWidget {
  final String message;
  final String type;
  final double? progress;
  final Map<String, dynamic>? systemInfo;

  const StatusBar({
    super.key,
    required this.message,
    required this.type,
    this.progress,
    this.systemInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: const BoxDecoration(
        color: Color(0xFF2A2A2A),
        border: Border(top: BorderSide(color: Color(0xFF3A3A3A), width: 1)),
      ),
      child: Row(
        children: [
          // Status indicator with progress
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getStatusColor().withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                    ),
                    if (type == 'working' && progress != null)
                      SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getStatusColor(),
                          ),
                          backgroundColor: Colors.transparent,
                        ),
                      )
                    else if (type == 'working')
                      SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getStatusColor(),
                          ),
                          backgroundColor: Colors.transparent,
                        ),
                      )
                    else
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _getStatusColor(),
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 8),
                Text(
                  message,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                if (progress != null && type == 'working') ...[
                  const SizedBox(width: 8),
                  Text(
                    '${(progress! * 100).toInt()}%',
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                ],
              ],
            ),
          ),

          // System info
          if (systemInfo != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  if (systemInfo!['memoryUsage'] != null) ...[
                    const Icon(Icons.memory, size: 14, color: Colors.white54),
                    const SizedBox(width: 4),
                    Text(
                      '${systemInfo!['memoryUsage']}MB',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  if (systemInfo!['activePlugins'] != null) ...[
                    const Icon(
                      Icons.extension,
                      size: 14,
                      color: Colors.white54,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${systemInfo!['activePlugins']} плагинов',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  if (systemInfo!['learningActive'] == true) ...[
                    const Icon(
                      Icons.psychology,
                      size: 14,
                      color: Color(0xFF28A745),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Обучение',
                      style: TextStyle(color: Color(0xFF28A745), fontSize: 11),
                    ),
                    const SizedBox(width: 12),
                  ],
                ],
              ),
            ),

          const Spacer(),

          // App info with timestamp
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  _getCurrentTime(),
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Freedome Sphere v1.0.0',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (type) {
      case 'ready':
        return const Color(0xFF28A745);
      case 'working':
        return const Color(0xFFFFC107);
      case 'error':
        return const Color(0xFFDC3545);
      case 'warning':
        return const Color(0xFFFF9800);
      default:
        return const Color(0xFF6C757D);
    }
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }
}
