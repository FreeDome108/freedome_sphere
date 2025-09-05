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
                      _buildImportButton(
                        icon: Icons.book,
                        label: l10n.barankoComics,
                        onTap: () => _importComics(context, l10n),
                      ),
                      _buildImportButton(
                        icon: Icons.videogame_asset,
                        label: l10n.unrealEngine,
                        onTap: () => _importUnreal(context, l10n),
                      ),
                      _buildImportButton(
                        icon: Icons.architecture,
                        label: l10n.blenderModel,
                        onTap: () => _importBlender(context, l10n),
                      ),
                    ],
                  ),
                  
                  // Audio
                  _buildSection(
                    title: 'Audio',
                    children: [
                      _buildImportButton(
                        icon: Icons.volume_up,
                        label: 'anAntaSound Setup',
                        onTap: () => _setupAnantaSound(context),
                      ),
                      _buildImportButton(
                        icon: Icons.surround_sound,
                        label: '3D Positioning',
                        onTap: () => _audio3D(context),
                      ),
                      _buildImportButton(
                        icon: Icons.audio_file,
                        label: 'Load .daga File',
                        onTap: () => _loadDagaFile(context),
                      ),
                    ],
                  ),
                  
                  // 3D Content
                  _buildSection(
                    title: '3D Content',
                    children: [
                      _buildImportButton(
                        icon: Icons.view_in_ar,
                        label: 'Load .zelim File',
                        onTap: () => _loadZelimFile(context),
                      ),
                    ],
                  ),
                  
                  // Dome Settings
                  _buildSection(
                    title: 'Dome Settings',
                    children: [
                      _buildDomeSettings(),
                    ],
                  ),
                  
                  // Export
                  _buildSection(
                    title: 'Export',
                    children: [
                      _buildExportButton(
                        icon: Icons.phone_android,
                        label: 'mbharata_client',
                        onTap: () => _exportMbharata(context),
                        isPrimary: true,
                      ),
                      _buildExportButton(
                        icon: Icons.public,
                        label: 'Dome Projection',
                        onTap: () => _exportDome(context),
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

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4A9EFF),
          ),
        ),
        const SizedBox(height: 12),
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
        
        // TODO: Process comics file
        _showImportSuccess(context, 'Baranko Comics', file.name);
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
        allowedExtensions: ['uasset', 'umap', 'fbx', 'obj'],
        allowMultiple: true,
      );
      
      if (result != null && result.files.isNotEmpty) {
        final files = result.files;
        onStatusUpdate('Imported ${files.length} Unreal files', 'ready');
        
        // TODO: Process Unreal files
        _showImportSuccess(context, 'Unreal Engine', '${files.length} files');
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
        allowedExtensions: ['blend', 'fbx', 'obj', 'dae', '3ds'],
        allowMultiple: true,
      );
      
      if (result != null && result.files.isNotEmpty) {
        final files = result.files;
        onStatusUpdate('Imported ${files.length} Blender models', 'ready');
        
        // TODO: Process Blender models
        _showImportSuccess(context, 'Blender Model', '${files.length} files');
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
            value: _format,
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
            value: _quality,
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
