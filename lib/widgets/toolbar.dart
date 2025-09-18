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
  final VoidCallback onImportBoranko;
  final VoidCallback onImportComics;
  final VoidCallback? onPreviousProject;
  final VoidCallback? onNextProject;
  final VoidCallback? onOpenLearningSystem;
  final VoidCallback? onOpenPluginManager;
  final VoidCallback? onOpenAIBasicIDE;
  final VoidCallback? onOpenAnantaSound;
  final String statusMessage;
  final String statusType;
  final bool? canNavigateBack;
  final bool? canNavigateForward;
  final bool? learningSystemActive;
  final int? activePluginsCount;

  const Toolbar({
    super.key,
    required this.onNewProject,
    required this.onOpenProject,
    required this.onSaveProject,
    required this.onPlayPreview,
    required this.onStopPreview,
    required this.onResetView,
    required this.onImportBoranko,
    required this.onImportComics,
    required this.statusMessage,
    required this.statusType,
    this.onPreviousProject,
    this.onNextProject,
    this.onOpenLearningSystem,
    this.onOpenPluginManager,
    this.onOpenAIBasicIDE,
    this.onOpenAnantaSound,
    this.canNavigateBack,
    this.canNavigateForward,
    this.learningSystemActive,
    this.activePluginsCount,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: Color(0xFF2A2A2A),
        border: Border(bottom: BorderSide(color: Color(0xFF3A3A3A), width: 1)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Navigation arrows
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: (canNavigateBack ?? false)
                        ? onPreviousProject
                        : null,
                    icon: const Icon(Icons.arrow_back_ios, size: 18),
                    tooltip: 'Предыдущий проект',
                    style: IconButton.styleFrom(
                      foregroundColor: (canNavigateBack ?? false)
                          ? Colors.white
                          : Colors.grey,
                    ),
                  ),
                  IconButton(
                    onPressed: (canNavigateForward ?? false)
                        ? onNextProject
                        : null,
                    icon: const Icon(Icons.arrow_forward_ios, size: 18),
                    tooltip: 'Следующий проект',
                    style: IconButton.styleFrom(
                      foregroundColor: (canNavigateForward ?? false)
                          ? Colors.white
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            const VerticalDivider(color: Color(0xFF3A3A3A)),

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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const VerticalDivider(color: Color(0xFF3A3A3A)),

            // Import menu
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'boranko') {
                    onImportBoranko();
                  } else if (value == 'comics') {
                    onImportComics();
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'boranko',
                    child: Text('Import .boranko'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'comics',
                    child: Text('Import .comics (deprecated)'),
                  ),
                ],
                child: Row(
                  children: [
                    const Icon(Icons.import_export, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      l10n.import,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const VerticalDivider(color: Color(0xFF3A3A3A)),

            // Learning System and Plugins
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // Learning System Button
                  Stack(
                    children: [
                      OutlinedButton.icon(
                        onPressed: onOpenLearningSystem,
                        icon: const Icon(Icons.psychology, size: 18),
                        label: const Text('Обучение'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: (learningSystemActive ?? false)
                              ? const Color(0xFF28A745)
                              : Colors.white,
                          side: BorderSide(
                            color: (learningSystemActive ?? false)
                                ? const Color(0xFF28A745)
                                : const Color(0xFF555555),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                      if (learningSystemActive ?? false)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF28A745),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  // Plugin Manager Button
                  Stack(
                    children: [
                      OutlinedButton.icon(
                        onPressed: onOpenPluginManager,
                        icon: const Icon(Icons.extension, size: 18),
                        label: const Text('Плагины'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Color(0xFF555555)),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                      if ((activePluginsCount ?? 0) > 0)
                        Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Color(0xFF4A9EFF),
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '${activePluginsCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            const VerticalDivider(color: Color(0xFF3A3A3A)),

            // Quick Tools
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: onOpenAIBasicIDE,
                    icon: const Icon(Icons.code, size: 20),
                    tooltip: 'AIBASIC IDE',
                    style: IconButton.styleFrom(foregroundColor: Colors.white),
                  ),
                  IconButton(
                    onPressed: onOpenAnantaSound,
                    icon: const Icon(Icons.music_note, size: 20),
                    tooltip: 'AnantaSound',
                    style: IconButton.styleFrom(foregroundColor: Colors.white),
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
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
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
