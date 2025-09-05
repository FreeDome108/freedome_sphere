import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'language_selector.dart';
import 'edition_selector.dart';

class Toolbar extends StatelessWidget {
  final VoidCallback onNewProject;
  final VoidCallback onOpenProject;
  final VoidCallback onSaveProject;
  final VoidCallback onPlayPreview;
  final VoidCallback onStopPreview;
  final VoidCallback onResetView;
  final String statusMessage;
  final String statusType;

  const Toolbar({
    super.key,
    required this.onNewProject,
    required this.onOpenProject,
    required this.onSaveProject,
    required this.onPlayPreview,
    required this.onStopPreview,
    required this.onResetView,
    required this.statusMessage,
    required this.statusType,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: Color(0xFF2A2A2A),
        border: Border(
          bottom: BorderSide(color: Color(0xFF3A3A3A), width: 1),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Project controls
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: onNewProject,
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(l10n.newButton),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A9EFF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: onOpenProject,
                    icon: const Icon(Icons.folder_open, size: 18),
                    label: Text(l10n.open),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFF555555)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: onSaveProject,
                    icon: const Icon(Icons.save, size: 18),
                    label: Text(l10n.save),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFF555555)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ],
              ),
            ),
            
            const VerticalDivider(color: Color(0xFF3A3A3A)),
            
            // Viewport controls
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: onPlayPreview,
                    icon: const Icon(Icons.play_arrow, size: 18),
                    label: Text(l10n.play),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF28A745),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: onStopPreview,
                    icon: const Icon(Icons.stop, size: 18),
                    label: Text(l10n.stop),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFF555555)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: onResetView,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: Text(l10n.reset),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFF555555)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ],
              ),
            ),
            
            const VerticalDivider(color: Color(0xFF3A3A3A)),
            
            // Edition selector
            const EditionSelector(),
            
            const SizedBox(width: 8),
            
            // Language selector
            const LanguageSelector(),
            
            const SizedBox(width: 16),
            
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
                    statusMessage,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (statusType) {
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
