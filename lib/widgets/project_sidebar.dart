import 'package:flutter/material.dart';
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

  void _importComics(BuildContext context, AppLocalizations l10n) {
    onStatusUpdate(l10n.importingBarankoComics, 'working');
    // TODO: Implement comics import
  }

  void _importUnreal(BuildContext context, AppLocalizations l10n) {
    onStatusUpdate(l10n.importingUnrealEngineScene, 'working');
    // TODO: Implement Unreal import
  }

  void _importBlender(BuildContext context, AppLocalizations l10n) {
    onStatusUpdate(l10n.importingBlenderModel, 'working');
    // TODO: Implement Blender import
  }

  void _setupAnantaSound(BuildContext context) {
    onStatusUpdate('Setting up anAntaSound...', 'working');
    // TODO: Implement anAntaSound setup
  }

  void _audio3D(BuildContext context) {
    onStatusUpdate('Opening 3D Audio editor...', 'working');
    // TODO: Implement 3D audio positioning
  }

  void _loadDagaFile(BuildContext context) {
    onStatusUpdate('Loading .daga file...', 'working');
    // TODO: Implement .daga file loading
  }

  void _loadZelimFile(BuildContext context) {
    onStatusUpdate('Loading .zelim file...', 'working');
    // TODO: Implement .zelim file loading
  }

  void _exportMbharata(BuildContext context) {
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
    // TODO: Implement mbharata export
  }

  void _exportDome(BuildContext context) {
    onStatusUpdate('Exporting dome projection...', 'working');
    // TODO: Implement dome export
  }
}
