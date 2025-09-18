import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/unreal_plugin_integration_service.dart';
import '../services/aibasic_ide_service.dart';
import '../services/anantasound_service.dart';

/// Panel for displaying plugin status and quick actions
class PluginStatusPanel extends StatelessWidget {
  final VoidCallback? onManagePlugins;

  const PluginStatusPanel({super.key, this.onManagePlugins});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF333333),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.extension, color: Color(0xFF4A9EFF)),
              const SizedBox(width: 8),
              const Text(
                'Статус плагинов',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A9EFF),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: onManagePlugins,
                child: const Text(
                  'Управление',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildPluginsList(),
        ],
      ),
    );
  }

  Widget _buildPluginsList() {
    return Column(
      children: [
        // AIBASIC IDE
        Consumer<AIBasicIDEService>(
          builder: (context, service, child) {
            return _buildPluginTile(
              name: 'AIBASIC IDE',
              icon: Icons.code,
              isActive: true, // service.isActive
              status: 'Готов к работе',
              onToggle: (value) {
                // service.setActive(value);
              },
            );
          },
        ),
        const SizedBox(height: 8),

        // AnantaSound
        Consumer<AnantaSoundService>(
          builder: (context, service, child) {
            return _buildPluginTile(
              name: 'AnantaSound',
              icon: Icons.music_note,
              isActive: true, // service.isActive
              status: 'Аудио система активна',
              onToggle: (value) {
                // service.setActive(value);
              },
            );
          },
        ),
        const SizedBox(height: 8),

        // Unreal Plugin Integration
        Consumer<UnrealPluginIntegrationService>(
          builder: (context, service, child) {
            return _buildPluginTile(
              name: 'Unreal Integration',
              icon: Icons.videogame_asset,
              isActive: false,
              status: 'Неактивен',
              onToggle: (value) {
                // Toggle service
              },
            );
          },
        ),
        const SizedBox(height: 12),

        // Quick actions row
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _enableAllPlugins(),
                icon: const Icon(Icons.power_settings_new, size: 16),
                label: const Text('Включить все'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF28A745),
                  side: const BorderSide(color: Color(0xFF28A745)),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _optimizePlugins(),
                icon: const Icon(Icons.tune, size: 16),
                label: const Text('Оптимизировать'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFF555555)),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPluginTile({
    required String name,
    required IconData icon,
    required bool isActive,
    required String status,
    required Function(bool) onToggle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isActive ? const Color(0xFF28A745) : const Color(0xFF555555),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: isActive ? const Color(0xFF28A745) : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                Text(
                  status,
                  style: TextStyle(
                    color: isActive ? const Color(0xFF28A745) : Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isActive,
            onChanged: onToggle,
            activeColor: const Color(0xFF28A745),
          ),
        ],
      ),
    );
  }

  void _enableAllPlugins() {
    // Enable all plugins
    print('Enabling all plugins...');
  }

  void _optimizePlugins() {
    // Optimize plugin performance
    print('Optimizing plugins...');
  }
}
