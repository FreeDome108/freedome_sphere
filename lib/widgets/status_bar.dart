import 'package:flutter/material.dart';

class StatusBar extends StatelessWidget {
  final String message;
  final String type;

  const StatusBar({
    super.key,
    required this.message,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      decoration: const BoxDecoration(
        color: Color(0xFF2A2A2A),
        border: Border(
          top: BorderSide(color: Color(0xFF3A3A3A), width: 1),
        ),
      ),
      child: Row(
        children: [
          // Status indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _getStatusColor(),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          const Spacer(),
          
          // App info
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Freedome Sphere v1.0.0',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
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
      default:
        return const Color(0xFF6C757D);
    }
  }
}
