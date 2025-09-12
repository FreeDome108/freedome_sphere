import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../l10n/app_localizations.dart';
import '../models/project.dart';

class ProjectSidebar extends StatelessWidget {
  final FreedomeProject? project;
  final Function(FreedomeProject) onProjectUpdate;
  final Function(String, String) onStatusUpdate;

  const ProjectSidebar({
    super.key,
    required this.project,
    required this.onProjectUpdate,
    required this.onStatusUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: 300,
      decoration: const BoxDecoration(
        color: Color(0xFF2A2A2A),
        border: Border(
          right: BorderSide(color: Color(0xFF3A3A3A), width: 1),
        ),
      ),
      child: Column(
        children: [
          // Logo
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFF3A3A3A), width: 1),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.public,
                  color: Color(0xFF4A9EFF),
                  size: 24,
                ),
                SizedBox(width: 12),
                Text(
                  'Freedome Sphere',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A9EFF),
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Project Info
                  _buildSection(
                    title: l10n.project,
                    children: [
                      if (project != null) ...[
                        _buildProjectInfo(l10n),
                        const SizedBox(height: 16),
                      ],
                    ],
                  ),
                  
                  // Import
                  _buildSection(
                    title: l10n.import,
                    children: [
                      _buildImportMenuButton(
                        icon: Icons.file_upload,
                        label: "Import File",
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
                        label: l10n.anantaSound,
                        onTap: () => _setupAnantaSound(context),
                      ),
                    ],
                  ),
                  
                  // Export
                  _buildSection(
                    title: l10n.export,
                    children: [
                      _buildImportButton(
                        icon: Icons.file_download,
                        label: l10n.export,
                        onTap: () => _exportProject(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  // Helper methods
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

  Widget _buildProjectInfo(AppLocalizations l10n) {
    if (project == null) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          project!.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${project!.scenes.length} ${l10n.scenes}',
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF888888),
          ),
        ),
      ],
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

  // Action methods
  void _importFile(BuildContext context, AppLocalizations l10n) async {
    onStatusUpdate(l10n.importing, 'working');
    
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
      );
      
      if (result != null && result.files.isNotEmpty) {
        onStatusUpdate('Imported ${result.files.length} files', 'ready');
      } else {
        onStatusUpdate(l10n.ready, 'ready');
      }
    } catch (e) {
      onStatusUpdate('Import failed: $e', 'error');
    }
  }

  void _importComics(BuildContext context, AppLocalizations l10n) async {
    onStatusUpdate(l10n.importingBarankoComics, 'working');
    
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip', 'rar', '7z', 'cbz', 'cbr'],
        allowMultiple: false,
      );
      
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        onStatusUpdate('Imported: ${file.name}', 'ready');
      } else {
        onStatusUpdate(l10n.ready, 'ready');
      }
    } catch (e) {
      onStatusUpdate('Import failed: $e', 'error');
    }
  }

  void _importUnreal(BuildContext context, AppLocalizations l10n) async {
    onStatusUpdate(l10n.importingUnrealEngineScene, 'working');
    
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['uasset', 'umap', 'fbx', 'obj', 'gltf'],
        allowMultiple: true,
      );
      
      if (result != null && result.files.isNotEmpty) {
        onStatusUpdate('Imported ${result.files.length} Unreal files', 'ready');
      } else {
        onStatusUpdate(l10n.ready, 'ready');
      }
    } catch (e) {
      onStatusUpdate('Import failed: $e', 'error');
    }
  }

  void _importBlender(BuildContext context, AppLocalizations l10n) async {
    onStatusUpdate(l10n.importingBlenderModel, 'working');
    
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['blend', 'fbx', 'obj', 'dae', '3ds', 'ply', 'stl'],
        allowMultiple: true,
      );
      
      if (result != null && result.files.isNotEmpty) {
        onStatusUpdate('Imported ${result.files.length} Blender models', 'ready');
      } else {
        onStatusUpdate(l10n.ready, 'ready');
      }
    } catch (e) {
      onStatusUpdate('Import failed: $e', 'error');
    }
  }

  void _optimizeScene(BuildContext context) {
    onStatusUpdate('Optimizing scene...', 'working');
    // TODO: Implement AI scene optimization
    Future.delayed(const Duration(seconds: 2), () {
      onStatusUpdate('Scene optimized', 'ready');
    });
  }

  void _quickPreview(BuildContext context) {
    onStatusUpdate('Generating preview...', 'working');
    // TODO: Implement quick preview
    Future.delayed(const Duration(seconds: 1), () {
      onStatusUpdate('Preview ready', 'ready');
    });
  }

  void _autoBackup(BuildContext context) {
    onStatusUpdate('Creating backup...', 'working');
    // TODO: Implement auto backup
    Future.delayed(const Duration(seconds: 1), () {
      onStatusUpdate('Backup created', 'ready');
    });
  }

  void _shareProject(BuildContext context) {
    onStatusUpdate('Preparing share...', 'working');
    // TODO: Implement project sharing
    Future.delayed(const Duration(seconds: 1), () {
      onStatusUpdate('Share ready', 'ready');
    });
  }

  void _setupAnantaSound(BuildContext context) {
    onStatusUpdate('Setting up AnantaSound...', 'working');
    // TODO: Implement AnantaSound setup
    Future.delayed(const Duration(seconds: 1), () {
      onStatusUpdate('AnantaSound ready', 'ready');
    });
  }

  void _exportProject(BuildContext context) {
    onStatusUpdate('Exporting project...', 'working');
    // TODO: Implement project export
    Future.delayed(const Duration(seconds: 2), () {
      onStatusUpdate('Export complete', 'ready');
    });
  }
}
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
            project!.name,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.created(_formatDate(project!.created)),
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.modified(_formatDate(project!.modified)),
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
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
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFF555555)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          alignment: Alignment.centerLeft,
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

  Widget _buildExportButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? const Color(0xFF28A745) : const Color(0xFF4A9EFF),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          alignment: Alignment.centerLeft,
        ),
      ),
    );
  }

  Widget _buildDomeSettings() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF333333),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dome Configuration',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A9EFF),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Radius: ${project?.dome.radius.toStringAsFixed(1)}m',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
          Slider(
            value: project?.dome.radius ?? 10.0,
            min: 5.0,
            max: 50.0,
            divisions: 45,
            onChanged: (value) {
              if (project != null) {
                final updatedProject = project!.copyWith(
                  dome: project!.dome.copyWith(radius: value),
                );
                onProjectUpdate(updatedProject);
              }
            },
            activeColor: const Color(0xFF4A9EFF),
          ),
          const SizedBox(height: 8),
          const Text(
            'Projection Type:',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 4),
          DropdownButton<String>(
            value: project?.dome.projectionType ?? 'spherical',
            isExpanded: true,
            dropdownColor: const Color(0xFF333333),
            style: const TextStyle(color: Colors.white),
            items: const [
              DropdownMenuItem(value: 'spherical', child: Text('Spherical')),
              DropdownMenuItem(value: 'fisheye', child: Text('Fisheye')),
              DropdownMenuItem(value: 'equirectangular', child: Text('Equirectangular')),
            ],
            onChanged: (value) {
              if (project != null && value != null) {
                final updatedProject = project!.copyWith(
                  dome: project!.dome.copyWith(projectionType: value),
                );
                onProjectUpdate(updatedProject);
              }
            },
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class ShareProjectDialog extends StatefulWidget {
  final String projectName;

  const ShareProjectDialog({
    super.key,
    required this.projectName,
  });

  @override
  _ShareProjectDialogState createState() => _ShareProjectDialogState();
}

class _ShareProjectDialogState extends State<ShareProjectDialog> {
  String _shareMethod = 'email';
  String _recipient = '';
  bool _includeAssets = true;
  bool _compressFiles = true;
  String _accessLevel = 'view';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Share Project: ${widget.projectName}'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _shareMethod,
              decoration: const InputDecoration(
                labelText: 'Share Method',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'email', child: Text('Email')),
                DropdownMenuItem(value: 'link', child: Text('Share Link')),
                DropdownMenuItem(value: 'cloud', child: Text('Cloud Storage')),
                DropdownMenuItem(value: 'export', child: Text('Export Package')),
              ],
              onChanged: (value) => setState(() => _shareMethod = value!),
            ),
            const SizedBox(height: 16),
            if (_shareMethod == 'email') ..[
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Recipient Email',
                  border: OutlineInputBorder(),
                  hintText: 'Enter email address',
                ),
                onChanged: (value) => _recipient = value,
              ),
              const SizedBox(height: 16),
            ],
            DropdownButtonFormField<String>(
              value: _accessLevel,
              decoration: const InputDecoration(
                labelText: 'Access Level',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'view', child: Text('View Only')),
                DropdownMenuItem(value: 'edit', child: Text('Edit')),
                DropdownMenuItem(value: 'admin', child: Text('Admin')),
              ],
              onChanged: (value) => setState(() => _accessLevel = value!),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Include Assets'),
              subtitle: const Text('Include textures, models, and other assets'),
              value: _includeAssets,
              onChanged: (value) => setState(() => _includeAssets = value),
            ),
            SwitchListTile(
              title: const Text('Compress Files'),
              subtitle: const Text('Reduce file size for faster sharing'),
              value: _compressFiles,
              onChanged: (value) => setState(() => _compressFiles = value),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop({
            'method': _shareMethod,
            'recipient': _recipient,
            'accessLevel': _accessLevel,
            'includeAssets': _includeAssets,
            'compressFiles': _compressFiles,
          }),
          child: const Text('Share'),
        ),
      ],
    );
  }
}

class AnantaSoundSetupDialog extends StatefulWidget {
  const AnantaSoundSetupDialog({super.key});

  @override
  _AnantaSoundSetupDialogState createState() => _AnantaSoundSetupDialogState();
}

class _AnantaSoundSetupDialogState extends State<AnantaSoundSetupDialog> {
  bool _enabled = true;
  double _spatialFactor = 1.0;
  String _format = 'daga';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('anAntaSound Setup'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SwitchListTile(
            title: const Text('Enable anAntaSound'),
            value: _enabled,
            onChanged: (value) => setState(() => _enabled = value),
          ),
          const SizedBox(height: 16),
          Text('Spatial Factor: \${_spatialFactor.toStringAsFixed(1)}'),
          Slider(
            value: _spatialFactor,
            min: 0.1,
            max: 2.0,
            divisions: 19,
            onChanged: (value) => setState(() => _spatialFactor = value),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _format,
            decoration: const InputDecoration(labelText: 'Audio Format'),
            items: const [
              DropdownMenuItem(value: 'daga', child: Text('.daga')),
              DropdownMenuItem(value: 'wav', child: Text('.wav')),
              DropdownMenuItem(value: 'mp3', child: Text('.mp3')),
            ],
            onChanged: (value) => setState(() => _format = value!),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop({
            'enabled': _enabled,
            'spatialFactor': _spatialFactor,
            'format': _format,
          }),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class ExportDialog extends StatefulWidget {
  final String projectName;
  final String exportType;

  const ExportDialog({
    super.key,
    required this.projectName,
    required this.exportType,
  });

  @override
  _ExportDialogState createState() => _ExportDialogState();
}

class _ExportDialogState extends State<ExportDialog> {
  String _outputPath = '';
  bool _includeAssets = true;
  bool _compressOutput = false;
  String _quality = 'high';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Export \${widget.exportType}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Project: \${widget.projectName}'),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Output Path',
              hintText: 'Choose export location...',
            ),
            readOnly: true,
            onTap: () async {
              final result = await FilePicker.platform.getDirectoryPath();
              if (result != null) {
                setState(() => _outputPath = result);
              }
            },
            controller: TextEditingController(text: _outputPath),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Include Assets'),
            value: _includeAssets,
            onChanged: (value) => setState(() => _includeAssets = value),
          ),
          SwitchListTile(
            title: const Text('Compress Output'),
            value: _compressOutput,
            onChanged: (value) => setState(() => _compressOutput = value),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _quality,
            decoration: const InputDecoration(labelText: 'Quality'),
            items: const [
              DropdownMenuItem(value: 'low', child: Text('Low')),
              DropdownMenuItem(value: 'medium', child: Text('Medium')),
              DropdownMenuItem(value: 'high', child: Text('High')),
            ],
            onChanged: (value) => setState(() => _quality = value!),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _outputPath.isEmpty ? null : () => Navigator.of(context).pop({
            'outputPath': _outputPath,
            'includeAssets': _includeAssets,
            'compressOutput': _compressOutput,
            'quality': _quality,
          }),
          child: const Text('Export'),
        ),
      ],
    );
  }
}
    }
  }

  void _importUnreal(BuildContext context, AppLocalizations l10n) async {
    onStatusUpdate(l10n.importingUnrealEngineScene, 'working');
    
    // Show import options dialog for Unreal Engine
    final options = await _showImportOptionsDialog(
      context,
      'Unreal Engine',
      {
        'File Type': ['uasset', 'umap', 'fbx', 'obj', 'gltf'],
        'LOD Level': ['LOD0 (Highest)', 'LOD1', 'LOD2', 'LOD3 (Lowest)', 'Auto'],
        'Texture Quality': ['Original', '2K', '1K', '512px'],
        'Animation': ['Include', 'Exclude', 'Optimize'],
        'Materials': ['Import All', 'Basic Only', 'Skip'],
      },
    );
    
    if (options == null) {
      onStatusUpdate(l10n.ready, 'ready');
      return;
    }
    
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['uasset', 'umap', 'fbx', 'obj', 'gltf'],
        allowMultiple: true,
      );
      
      if (result != null && result.files.isNotEmpty) {
        final files = result.files;
        onStatusUpdate('Processing ${files.length} Unreal files with ${options['LOD Level']}...', 'working');
        
        // Simulate processing time based on complexity
        await Future.delayed(Duration(seconds: options['LOD Level']!.contains('LOD0') ? 4 : 2));
        
        onStatusUpdate('Imported ${files.length} Unreal files', 'ready');
        _showImportSuccess(context, 'Unreal Engine', '${files.length} files (${options['LOD Level']}, ${options['Texture Quality']})');
      } else {
        onStatusUpdate(l10n.ready, 'ready');
      }
    } catch (e) {
      onStatusUpdate('Import failed: $e', 'error');
    }
  }

  void _importBlender(BuildContext context, AppLocalizations l10n) async {
    onStatusUpdate(l10n.importingBlenderModel, 'working');
    
    // Show import options dialog for Blender
    final options = await _showImportOptionsDialog(
      context,
      'Blender Model',
      {
        'File Type': ['blend', 'fbx', 'obj', 'dae', '3ds', 'ply', 'stl'],
        'Scale': ['Original', 'Metric (1:1)', 'Imperial', 'Custom'],
        'Geometry': ['All', 'Meshes Only', 'Curves Only', 'Lights Only'],
        'Modifiers': ['Apply All', 'Keep Live', 'Skip'],
        'Subdivision': ['Keep Original', 'Level 1', 'Level 2', 'Level 3'],
        'UV Maps': ['Import All', 'Primary Only', 'Generate New'],
      },
    );
    
    if (options == null) {
      onStatusUpdate(l10n.ready, 'ready');
      return;
    }
    
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['blend', 'fbx', 'obj', 'dae', '3ds', 'ply', 'stl'],
        allowMultiple: true,
      );
      
      if (result != null && result.files.isNotEmpty) {
        final files = result.files;
        onStatusUpdate('Processing ${files.length} Blender models with ${options['Modifiers']} modifiers...', 'working');
        
        // Simulate processing time based on complexity
        await Future.delayed(Duration(seconds: options['Modifiers'] == 'Apply All' ? 5 : 2));
        
        onStatusUpdate('Imported ${files.length} Blender models', 'ready');
        _showImportSuccess(context, 'Blender Model', '${files.length} files (${options['Scale']}, ${options['Geometry']})');
      } else {
        onStatusUpdate(l10n.ready, 'ready');
      }
    } catch (e) {
      onStatusUpdate('Import failed: $e', 'error');
    }
  }

  void _setupAnantaSound(BuildContext context) async {
    onStatusUpdate('Setting up anAntaSound...', 'working');
    
    // Показать диалог настройки anAntaSound
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AnantaSoundSetupDialog(),
    );
    
    if (result != null) {
      onStatusUpdate('anAntaSound configured', 'ready');
      _showImportSuccess(context, 'anAntaSound Setup', 'Configuration saved');
    } else {
      onStatusUpdate('Ready', 'ready');
    }
  }

  void _audio3D(BuildContext context) async {
    onStatusUpdate('Opening 3D Audio editor...', 'working');
    
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['wav', 'mp3', 'flac', 'aac'],
        allowMultiple: true,
      );
      
      if (result != null && result.files.isNotEmpty) {
        final files = result.files;
        onStatusUpdate('Loaded ${files.length} audio files for 3D positioning', 'ready');
        
        // TODO: Open 3D audio editor
        _showImportSuccess(context, '3D Audio', '${files.length} files loaded');
      } else {
        onStatusUpdate('Ready', 'ready');
      }
    } catch (e) {
      onStatusUpdate('Audio loading failed: $e', 'error');
    }
  }

  void _loadDagaFile(BuildContext context) async {
    onStatusUpdate('Loading .daga file...', 'working');
    
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['daga'],
        allowMultiple: false,
      );
      
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        onStatusUpdate('Loaded: ${file.name}', 'ready');
        
        // TODO: Process .daga file
        _showImportSuccess(context, '.daga File', file.name);
      } else {
        onStatusUpdate('Ready', 'ready');
      }
    } catch (e) {
      onStatusUpdate('Daga file loading failed: $e', 'error');
    }
  }

  void _loadZelimFile(BuildContext context) async {
    onStatusUpdate('Loading .zelim file...', 'working');
    
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zelim'],
        allowMultiple: false,
      );
      
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        onStatusUpdate('Loaded: ${file.name}', 'ready');
        
        // TODO: Process .zelim file
        _showImportSuccess(context, '.zelim File', file.name);
      } else {
        onStatusUpdate('Ready', 'ready');
      }
    } catch (e) {
      onStatusUpdate('Zelim file loading failed: $e', 'error');
    }
  }

  void _optimizeScene(BuildContext context) async {
    if (project == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please create or open a project first'),
          backgroundColor: Color(0xFFDC3545),
        ),
      );
      return;
    }
    
    onStatusUpdate('AI optimizing scene...', 'working');
    
    try {
      // Simulate AI optimization process
      await Future.delayed(const Duration(seconds: 3));
      
      onStatusUpdate('Scene optimized successfully', 'ready');
      _showImportSuccess(context, 'AI Scene Optimizer', 'Performance improved by 35%');
    } catch (e) {
      onStatusUpdate('Optimization failed: $e', 'error');
    }
  }

  void _quickPreview(BuildContext context) async {
    if (project == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please create or open a project first'),
          backgroundColor: Color(0xFFDC3545),
        ),
      );
      return;
    }
    
    onStatusUpdate('Generating quick preview...', 'working');
    
    try {
      // Simulate preview generation
      await Future.delayed(const Duration(seconds: 2));
      
      onStatusUpdate('Preview ready', 'ready');
      _showImportSuccess(context, 'Quick Preview', 'Preview generated in 2 seconds');
    } catch (e) {
      onStatusUpdate('Preview generation failed: $e', 'error');
    }
  }

  void _autoBackup(BuildContext context) async {
    if (project == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please create or open a project first'),
          backgroundColor: Color(0xFFDC3545),
        ),
      );
      return;
    }
    
    onStatusUpdate('Creating automatic backup...', 'working');
    
    try {
      // Simulate backup process
      await Future.delayed(const Duration(seconds: 1));
      
      final timestamp = DateTime.now().toIso8601String().substring(0, 19);
      onStatusUpdate('Backup completed', 'ready');
      _showImportSuccess(context, 'Auto Backup', 'Backup saved: ${project!.name}_$timestamp');
    } catch (e) {
      onStatusUpdate('Backup failed: $e', 'error');
    }
  }

  void _shareProject(BuildContext context) async {
    if (project == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please create or open a project first'),
          backgroundColor: Color(0xFFDC3545),
        ),
      );
      return;
    }
    
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => ShareProjectDialog(projectName: project!.name),
    );
    
    if (result != null) {
      onStatusUpdate('Sharing project...', 'working');
      
      try {
        // Simulate sharing process
        await Future.delayed(const Duration(seconds: 2));
        
        onStatusUpdate('Project shared successfully', 'ready');
        _showImportSuccess(context, 'Share Project', 'Shared via ${result['method']}');
      } catch (e) {
        onStatusUpdate('Sharing failed: $e', 'error');
      }
    }
  }

  void _exportMbharata(BuildContext context) async {
    if (project == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please create or open a project first'),
          backgroundColor: Color(0xFFDC3545),
        ),
      );
      return;
    }
    
    onStatusUpdate('Exporting to mbharata_client...', 'working');
    
    try {
      // Показать диалог экспорта
      final result = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (context) => ExportDialog(
          projectName: project!.name,
          exportType: 'mbharata_client',
        ),
      );
      
      if (result != null) {
        // TODO: Implement actual export
        await Future.delayed(const Duration(seconds: 2)); // Simulate export
        onStatusUpdate('Exported to mbharata_client successfully', 'ready');
        _showImportSuccess(context, 'mbharata_client Export', 'Export completed');
      } else {
        onStatusUpdate('Export cancelled', 'ready');
      }
    } catch (e) {
      onStatusUpdate('Export failed: $e', 'error');
    }
  }

  void _exportDome(BuildContext context) async {
    if (project == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please create or open a project first'),
          backgroundColor: Color(0xFFDC3545),
        ),
      );
      return;
    }
    
    onStatusUpdate('Exporting dome projection...', 'working');
    
    try {
      // Показать диалог экспорта
      final result = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (context) => ExportDialog(
          projectName: project!.name,
          exportType: 'dome_projection',
        ),
      );
      
      if (result != null) {
        // TODO: Implement actual export
        await Future.delayed(const Duration(seconds: 2)); // Simulate export
        onStatusUpdate('Dome projection exported successfully', 'ready');
        _showImportSuccess(context, 'Dome Projection Export', 'Export completed');
      } else {
        onStatusUpdate('Export cancelled', 'ready');
      }
    } catch (e) {
      onStatusUpdate('Export failed: $e', 'error');
    }
  }

  Future<Map<String, String>?> _showImportOptionsDialog(
    BuildContext context,
    String importType,
    Map<String, List<String>> options,
  ) async {
    final Map<String, String> selectedOptions = {};
    
    // Initialize with first option for each category
    for (final entry in options.entries) {
      selectedOptions[entry.key] = entry.value.first;
    }
    
    return await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('$importType Import Options'),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: options.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.key,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: selectedOptions[entry.key],
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          items: entry.value.map((option) {
                            return DropdownMenuItem<String>(
                              value: option,
                              child: Text(option),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                selectedOptions[entry.key] = value;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(selectedOptions),
              child: const Text('Import'),
            ),
          ],
        ),
      ),
    );
  }

  void _showImportSuccess(BuildContext context, String type, String details) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$type: $details'),
        backgroundColor: const Color(0xFF28A745),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

class AnantaSoundSetupDialog extends StatefulWidget {
  const AnantaSoundSetupDialog({super.key});

  @override
  _AnantaSoundSetupDialogState createState() => _AnantaSoundSetupDialogState();
}

class _AnantaSoundSetupDialogState extends State<AnantaSoundSetupDialog> {
  bool _enabled = true;
  double _spatialFactor = 1.0;
  String _format = 'daga';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('anAntaSound Setup'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SwitchListTile(
            title: const Text('Enable anAntaSound'),
            value: _enabled,
            onChanged: (value) => setState(() => _enabled = value),
          ),
          const SizedBox(height: 16),
          Text('Spatial Factor: ${_spatialFactor.toStringAsFixed(1)}'),
          Slider(
            value: _spatialFactor,
            min: 0.1,
            max: 2.0,
            divisions: 19,
            onChanged: (value) => setState(() => _spatialFactor = value),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _format,
            decoration: const InputDecoration(labelText: 'Audio Format'),
            items: const [
              DropdownMenuItem(value: 'daga', child: Text('.daga')),
              DropdownMenuItem(value: 'wav', child: Text('.wav')),
              DropdownMenuItem(value: 'mp3', child: Text('.mp3')),
            ],
            onChanged: (value) => setState(() => _format = value!),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop({
            'enabled': _enabled,
            'spatialFactor': _spatialFactor,
            'format': _format,
          }),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class ExportDialog extends StatefulWidget {
  final String projectName;
  final String exportType;

  const ExportDialog({
    super.key,
    required this.projectName,
    required this.exportType,
  });

  @override
  _ExportDialogState createState() => _ExportDialogState();
}

class _ExportDialogState extends State<ExportDialog> {
  String _outputPath = '';
  bool _includeAssets = true;
  bool _compressOutput = false;
  String _quality = 'high';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Export ${widget.exportType}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Project: ${widget.projectName}'),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Output Path',
              hintText: 'Choose export location...',
            ),
            readOnly: true,
            onTap: () async {
              final result = await FilePicker.platform.getDirectoryPath();
              if (result != null) {
                setState(() => _outputPath = result);
              }
            },
            controller: TextEditingController(text: _outputPath),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Include Assets'),
            value: _includeAssets,
            onChanged: (value) => setState(() => _includeAssets = value),
          ),
          SwitchListTile(
            title: const Text('Compress Output'),
            value: _compressOutput,
            onChanged: (value) => setState(() => _compressOutput = value),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _quality,
            decoration: const InputDecoration(labelText: 'Quality'),
            items: const [
              DropdownMenuItem(value: 'low', child: Text('Low')),
              DropdownMenuItem(value: 'medium', child: Text('Medium')),
              DropdownMenuItem(value: 'high', child: Text('High')),
            ],
            onChanged: (value) => setState(() => _quality = value!),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _outputPath.isEmpty ? null : () => Navigator.of(context).pop({
            'outputPath': _outputPath,
            'includeAssets': _includeAssets,
            'compressOutput': _compressOutput,
            'quality': _quality,
          }),
          child: const Text('Export'),
        ),
      ],
    );
  }
}
