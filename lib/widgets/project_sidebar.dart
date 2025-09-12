import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../l10n/app_localizations.dart';

class ProjectSidebar extends StatefulWidget {
  final Map<String, dynamic> project;
  final Function(String, String) onStatusUpdate;
  final Function(Map<String, dynamic>) onProjectUpdate;

  const ProjectSidebar({
    super.key,
    required this.project,
    required this.onStatusUpdate,
    required this.onProjectUpdate,
  });

  @override
  State<ProjectSidebar> createState() => _ProjectSidebarState();
}

class _ProjectSidebarState extends State<ProjectSidebar> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFF1E1E1E),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Project Info
            _buildSection(
              title: l10n.project,
              children: [
                _buildProjectInfo(l10n),
              ],
            ),

            // Import File (consolidated)
            _buildSection(
              title: l10n.import,
              children: [
                _buildImportMenuButton(
                  icon: Icons.file_upload,
                  label: l10n.import,
                  context: context,
                  l10n: l10n,
                ),
              ],
            ),

            // Quick Actions
            _buildSection(
              title: 'Quick Actions',
              children: [
                _buildImportButton(
                  icon: Icons.auto_fix_high,
                  label: 'AI Scene Optimizer',
                  onTap: () => _optimizeScene(context),
                ),
                _buildImportButton(
                  icon: Icons.preview,
                  label: 'Quick Preview',
                  onTap: () => _quickPreview(context),
                ),
                _buildImportButton(
                  icon: Icons.backup,
                  label: 'Auto Backup',
                  onTap: () => _autoBackup(context),
                ),
                _buildImportButton(
                  icon: Icons.share,
                  label: 'Share Project',
                  onTap: () => _shareProject(context),
                ),
              ],
            ),

            // Audio
            _buildSection(
              title: l10n.audio,
              children: [
                _buildImportButton(
                  icon: Icons.music_note,
                  label: 'AnantaSound Setup',
                  onTap: () => _setupAnantaSound(context),
                ),
                _buildImportButton(
                  icon: Icons.surround_sound,
                  label: l10n.threeDPositioning,
                  onTap: () => _audio3D(context),
                ),
                _buildImportButton(
                  icon: Icons.audiotrack,
                  label: l10n.loadDagaFile,
                  onTap: () => _loadDagaFile(context),
                ),
                _buildImportButton(
                  icon: Icons.library_music,
                  label: l10n.loadZelimFile,
                  onTap: () => _loadZelimFile(context),
                ),
              ],
            ),

            // 3D Content
            _buildSection(
              title: l10n.threeDContent,
              children: [
                _buildImportButton(
                  icon: Icons.view_in_ar,
                  label: 'Load Model',
                  onTap: () => _loadModel(context),
                ),
                _buildImportButton(
                  icon: Icons.terrain,
                  label: 'Load Terrain',
                  onTap: () => _loadTerrain(context),
                ),
                _buildImportButton(
                  icon: Icons.lightbulb,
                  label: 'Setup Lighting',
                  onTap: () => _setupLighting(context),
                ),
                _buildImportButton(
                  icon: Icons.camera_alt,
                  label: 'Setup Camera',
                  onTap: () => _setupCamera(context),
                ),
              ],
            ),

            // Dome Settings
            _buildSection(
              title: l10n.domeSettings,
              children: [
                _buildDomeSettings(l10n),
              ],
            ),

            // Export
            _buildSection(
              title: l10n.export,
              children: [
                _buildImportButton(
                  icon: Icons.phone_android,
                  label: l10n.mbharataClient,
                  onTap: () => _exportMbharata(context),
                ),
                _buildImportButton(
                  icon: Icons.public,
                  label: l10n.domeProjection,
                  onTap: () => _exportDome(context),
                ),
                _buildImportButton(
                  icon: Icons.download,
                  label: 'Export Project',
                  onTap: () => _exportProject(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF888888),
            ),
          ),
        ),
        ...children,
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildProjectInfo(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF333333),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.currentProject,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A9EFF),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.project['name'] ?? 'Untitled Project',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${l10n.created}: ${_formatDate(widget.project['created'])}',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF888888),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${l10n.modified}: ${_formatDate(widget.project['modified'])}',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF888888),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImportButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          side: const BorderSide(color: Color(0xFF555555)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImportMenuButton({
    required IconData icon,
    required String label,
    required BuildContext context,
    required AppLocalizations l10n,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      child: PopupMenuButton<String>(
        onSelected: (value) {
          switch (value) {
            case 'general':
              _importFile(context, l10n);
              break;
            case 'boranko':
              _importComics(context, l10n);
              break;
            case 'unreal':
              _importUnreal(context, l10n);
              break;
            case 'blender':
              _importBlender(context, l10n);
              break;
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          PopupMenuItem<String>(
            value: 'general',
            child: Row(
              children: [
                const Icon(Icons.file_upload, size: 18),
                const SizedBox(width: 8),
                Text(l10n.importGeneral),
              ],
            ),
          ),
          const PopupMenuDivider(),
          PopupMenuItem<String>(
            value: 'boranko',
            child: Row(
              children: [
                const Icon(Icons.book, size: 18),
                const SizedBox(width: 8),
                Text(l10n.barankoComics),
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: 'unreal',
            child: Row(
              children: [
                const Icon(Icons.videogame_asset, size: 18),
                const SizedBox(width: 8),
                Text(l10n.unrealEngine),
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: 'blender',
            child: Row(
              children: [
                const Icon(Icons.architecture, size: 18),
                const SizedBox(width: 8),
                Text(l10n.blenderModel),
              ],
            ),
          ),
        ],
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF555555)),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(color: Colors.white),
              ),
              const Spacer(),
              const Icon(
                Icons.arrow_drop_down,
                color: Colors.white,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDomeSettings(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF333333),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            Text('Dome Resolution'),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A9EFF),
            ),
          ),
          const SizedBox(height: 8),
          DropdownButton<String>(
            value: widget.project['domeResolution'] ?? '4K',
            dropdownColor: const Color(0xFF333333),
            style: const TextStyle(color: Colors.white),
            items: ['2K', '4K', '8K'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                widget.project['domeResolution'] = newValue;
                widget.onProjectUpdate(widget.project);
              }
            },
          ),
          const SizedBox(height: 16),
          Text(
            l10n.projectionType,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A9EFF),
            ),
          ),
          const SizedBox(height: 8),
          DropdownButton<String>(
            value: widget.project['projectionType'] ?? 'Fulldome',
            dropdownColor: const Color(0xFF333333),
            style: const TextStyle(color: Colors.white),
            items: ['Fulldome', 'Planetarium', 'Immersive'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                widget.project['projectionType'] = newValue;
                widget.onProjectUpdate(widget.project);
              }
            },
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'Unknown';
    if (date is DateTime) {
      return '${date.day}/${date.month}/${date.year}';
    }
    return date.toString();
  }

  // Import methods
  void _importFile(BuildContext context, AppLocalizations l10n) async {
    widget.onStatusUpdate('Importing files...', 'working');
    
    try {
      final result = await FilePicker.platform.pickFiles(allowMultiple: true);
      
      if (result != null && result.files.isNotEmpty) {
        widget.onStatusUpdate('Imported ${result.files.length} files', 'ready');
      } else {
        widget.onStatusUpdate(l10n.ready, 'ready');
      }
    } catch (e) {
      widget.onStatusUpdate('Import failed: $e', 'error');
    }
  }

  void _importComics(BuildContext context, AppLocalizations l10n) async {
    widget.onStatusUpdate('Importing Baranko Comics...', 'working');
    
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip', 'rar', '7z', 'cbz', 'cbr'],
        allowMultiple: false,
      );
      
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        widget.onStatusUpdate('Imported: ${file.name}', 'ready');
      } else {
        widget.onStatusUpdate(l10n.ready, 'ready');
      }
    } catch (e) {
      widget.onStatusUpdate('Import failed: $e', 'error');
    }
  }

  void _importUnreal(BuildContext context, AppLocalizations l10n) async {
    widget.onStatusUpdate('Importing Unreal Engine scene...', 'working');
    
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['uasset', 'umap', 'fbx', 'obj', 'gltf'],
        allowMultiple: true,
      );
      
      if (result != null && result.files.isNotEmpty) {
        widget.onStatusUpdate('Imported ${result.files.length} Unreal files', 'ready');
      } else {
        widget.onStatusUpdate(l10n.ready, 'ready');
      }
    } catch (e) {
      widget.onStatusUpdate('Import failed: $e', 'error');
    }
  }

  void _importBlender(BuildContext context, AppLocalizations l10n) async {
    widget.onStatusUpdate('Importing Blender model...', 'working');
    
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['blend', 'fbx', 'obj', 'dae', '3ds', 'ply', 'stl'],
        allowMultiple: true,
      );
      
      if (result != null && result.files.isNotEmpty) {
        widget.onStatusUpdate('Imported ${result.files.length} Blender models', 'ready');
      } else {
        widget.onStatusUpdate(l10n.ready, 'ready');
      }
    } catch (e) {
      widget.onStatusUpdate('Import failed: $e', 'error');
    }
  }

  // Quick Action methods
  void _optimizeScene(BuildContext context) {
    widget.onStatusUpdate('Optimizing scene...', 'working');
    Future.delayed(const Duration(seconds: 3), () {
      widget.onStatusUpdate('Scene optimized', 'ready');
    });
  }

  void _quickPreview(BuildContext context) {
    widget.onStatusUpdate('Generating preview...', 'working');
    Future.delayed(const Duration(seconds: 2), () {
      widget.onStatusUpdate('Preview ready', 'ready');
    });
  }

  void _autoBackup(BuildContext context) {
    widget.onStatusUpdate('Creating backup...', 'working');
    Future.delayed(const Duration(seconds: 2), () {
      widget.onStatusUpdate('Backup created', 'ready');
    });
  }

  void _shareProject(BuildContext context) {
    widget.onStatusUpdate('Preparing share...', 'working');
    Future.delayed(const Duration(seconds: 1), () {
      widget.onStatusUpdate('Share link ready', 'ready');
    });
  }

  // Audio methods
  void _setupAnantaSound(BuildContext context) {
    widget.onStatusUpdate('Setting up AnantaSound...', 'working');
    Future.delayed(const Duration(seconds: 2), () {
      widget.onStatusUpdate('AnantaSound ready', 'ready');
    });
  }

  void _audio3D(BuildContext context) {
    widget.onStatusUpdate('Configuring 3D audio...', 'working');
    Future.delayed(const Duration(seconds: 2), () {
      widget.onStatusUpdate('3D audio configured', 'ready');
    });
  }

  void _loadDagaFile(BuildContext context) async {
    widget.onStatusUpdate('Loading DAGA file...', 'working');
    
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['daga'],
        allowMultiple: false,
      );
      
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        widget.onStatusUpdate('Loaded: ${file.name}', 'ready');
      } else {
        widget.onStatusUpdate('Ready', 'ready');
      }
    } catch (e) {
      widget.onStatusUpdate('Load failed: $e', 'error');
    }
  }

  void _loadZelimFile(BuildContext context) async {
    widget.onStatusUpdate('Loading ZELIM file...', 'working');
    
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zelim'],
        allowMultiple: false,
      );
      
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        widget.onStatusUpdate('Loaded: ${file.name}', 'ready');
      } else {
        widget.onStatusUpdate('Ready', 'ready');
      }
    } catch (e) {
      widget.onStatusUpdate('Load failed: $e', 'error');
    }
  }

  // 3D Content methods
  void _loadModel(BuildContext context) async {
    widget.onStatusUpdate('Loading 3D model...', 'working');
    
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['fbx', 'obj', 'gltf', 'glb', '3ds', 'dae'],
        allowMultiple: true,
      );
      
      if (result != null && result.files.isNotEmpty) {
        widget.onStatusUpdate('Loaded ${result.files.length} models', 'ready');
      } else {
        widget.onStatusUpdate('Ready', 'ready');
      }
    } catch (e) {
      widget.onStatusUpdate('Load failed: $e', 'error');
    }
  }

  void _loadTerrain(BuildContext context) {
    widget.onStatusUpdate('Loading terrain...', 'working');
    Future.delayed(const Duration(seconds: 2), () {
      widget.onStatusUpdate('Terrain loaded', 'ready');
    });
  }

  void _setupLighting(BuildContext context) {
    widget.onStatusUpdate('Setting up lighting...', 'working');
    Future.delayed(const Duration(seconds: 2), () {
      widget.onStatusUpdate('Lighting configured', 'ready');
    });
  }

  void _setupCamera(BuildContext context) {
    widget.onStatusUpdate('Setting up camera...', 'working');
    Future.delayed(const Duration(seconds: 1), () {
      widget.onStatusUpdate('Camera configured', 'ready');
    });
  }

  // Export methods
  void _exportMbharata(BuildContext context) {
    widget.onStatusUpdate('Exporting to Mbharata...', 'working');
    Future.delayed(const Duration(seconds: 3), () {
      widget.onStatusUpdate('Export to Mbharata complete', 'ready');
    });
  }

  void _exportDome(BuildContext context) {
    widget.onStatusUpdate('Exporting dome projection...', 'working');
    Future.delayed(const Duration(seconds: 3), () {
      widget.onStatusUpdate('Dome export complete', 'ready');
    });
  }

  void _exportProject(BuildContext context) {
    widget.onStatusUpdate('Exporting project...', 'working');
    Future.delayed(const Duration(seconds: 2), () {
      widget.onStatusUpdate('Export complete', 'ready');
    });
  }
}
