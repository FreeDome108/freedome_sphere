import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../services/project_service.dart';
import '../models/project.dart';
import '../widgets/project_sidebar.dart';
import '../widgets/viewport_3d.dart';
import '../widgets/toolbar.dart';
import '../widgets/status_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FreedomeProject? _currentProject;
  bool _isLoading = false;
  String _statusMessage = '';
  String _statusType = 'ready';

  @override
  void initState() {
    super.initState();
    _loadCurrentProject();
  }

  Future<void> _loadCurrentProject() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _isLoading = true;
      _statusMessage = l10n.loadingProject;
      _statusType = 'working';
    });

    try {
      final projectService = Provider.of<ProjectService>(context, listen: false);
      final project = await projectService.getCurrentProject();
      
      setState(() {
        _currentProject = project;
        _statusMessage = project != null ? l10n.projectLoaded : l10n.noProject;
        _statusType = 'ready';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _statusMessage = l10n.errorLoadingProject(e.toString());
        _statusType = 'error';
        _isLoading = false;
      });
    }
  }

  Future<void> _createNewProject() async {
    final l10n = AppLocalizations.of(context)!;
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const NewProjectDialog(),
    );

    if (result != null) {
      setState(() {
        _isLoading = true;
        _statusMessage = l10n.creatingNewProject;
        _statusType = 'working';
      });

      try {
        final projectService = Provider.of<ProjectService>(context, listen: false);
        final project = await projectService.createNewProject(
          name: result['name'],
          description: result['description'] ?? '',
          tags: result['tags'] ?? [],
        );

        await projectService.setCurrentProject(project.id);

        setState(() {
          _currentProject = project;
          _statusMessage = l10n.newProjectCreated;
          _statusType = 'ready';
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _statusMessage = l10n.errorCreatingProject(e.toString());
          _statusType = 'error';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _openProject() async {
    final l10n = AppLocalizations.of(context)!;
    // TODO: Implement file picker for opening projects
    setState(() {
      _statusMessage = l10n.openingProject;
      _statusType = 'working';
    });
  }

  Future<void> _saveProject() async {
    if (_currentProject == null) return;
    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _statusMessage = l10n.savingProject;
      _statusType = 'working';
    });

    try {
      final projectService = Provider.of<ProjectService>(context, listen: false);
      final success = await projectService.saveProject(_currentProject!);

      setState(() {
        _statusMessage = success ? l10n.projectSaved : l10n.saveFailed;
        _statusType = success ? 'ready' : 'error';
      });
    } catch (e) {
      setState(() {
        _statusMessage = l10n.errorSavingProject(e.toString());
        _statusType = 'error';
      });
    }
  }

  void _updateProject(FreedomeProject project) {
    setState(() {
      _currentProject = project;
    });
  }

  void _setStatus(String message, String type) {
    setState(() {
      _statusMessage = message;
      _statusType = type;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Toolbar
          Toolbar(
            onNewProject: _createNewProject,
            onOpenProject: _openProject,
            onSaveProject: _saveProject,
            onPlayPreview: () => _setStatus(AppLocalizations.of(context)!.playingPreview, 'working'),
            onStopPreview: () => _setStatus(AppLocalizations.of(context)!.previewStopped, 'ready'),
            onResetView: () => _setStatus(AppLocalizations.of(context)!.viewReset, 'ready'),
            statusMessage: _statusMessage,
            statusType: _statusType,
          ),
          
          // Main content
          Expanded(
            child: Row(
              children: [
                // Sidebar
                ProjectSidebar(
                  project: _currentProject,
                  onProjectUpdate: _updateProject,
                  onStatusUpdate: _setStatus,
                ),
                
                // Main viewport
                Expanded(
                  child: Viewport3D(
                    project: _currentProject,
                    isLoading: _isLoading,
                  ),
                ),
              ],
            ),
          ),
          
          // Status bar
          StatusBar(
            message: _statusMessage,
            type: _statusType,
          ),
        ],
      ),
    );
  }
}

class NewProjectDialog extends StatefulWidget {
  const NewProjectDialog({super.key});

  @override
  State<NewProjectDialog> createState() => _NewProjectDialogState();
}

class _NewProjectDialogState extends State<NewProjectDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.newProject),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.projectName,
                hintText: l10n.enterProjectName,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.pleaseEnterProjectName;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: l10n.descriptionOptional,
                hintText: l10n.enterProjectDescription,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _tagsController,
              decoration: InputDecoration(
                labelText: l10n.tagsOptional,
                hintText: l10n.enterTagsSeparatedByCommas,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final tags = _tagsController.text
                  .split(',')
                  .map((tag) => tag.trim())
                  .where((tag) => tag.isNotEmpty)
                  .toList();

              Navigator.of(context).pop({
                'name': _nameController.text,
                'description': _descriptionController.text,
                'tags': tags,
              });
            }
          },
          child: Text(l10n.create),
        ),
      ],
    );
  }
}
