import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  String _statusMessage = 'Ready';
  String _statusType = 'ready';

  @override
  void initState() {
    super.initState();
    _loadCurrentProject();
  }

  Future<void> _loadCurrentProject() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Loading project...';
      _statusType = 'working';
    });

    try {
      final projectService = Provider.of<ProjectService>(context, listen: false);
      final project = await projectService.getCurrentProject();
      
      setState(() {
        _currentProject = project;
        _statusMessage = project != null ? 'Project loaded' : 'No project';
        _statusType = 'ready';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error loading project: $e';
        _statusType = 'error';
        _isLoading = false;
      });
    }
  }

  Future<void> _createNewProject() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const NewProjectDialog(),
    );

    if (result != null) {
      setState(() {
        _isLoading = true;
        _statusMessage = 'Creating new project...';
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
          _statusMessage = 'New project created';
          _statusType = 'ready';
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _statusMessage = 'Error creating project: $e';
          _statusType = 'error';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _openProject() async {
    // TODO: Implement file picker for opening projects
    setState(() {
      _statusMessage = 'Opening project...';
      _statusType = 'working';
    });
  }

  Future<void> _saveProject() async {
    if (_currentProject == null) return;

    setState(() {
      _statusMessage = 'Saving project...';
      _statusType = 'working';
    });

    try {
      final projectService = Provider.of<ProjectService>(context, listen: false);
      final success = await projectService.saveProject(_currentProject!);

      setState(() {
        _statusMessage = success ? 'Project saved' : 'Save failed';
        _statusType = success ? 'ready' : 'error';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error saving project: $e';
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
            onPlayPreview: () => _setStatus('Playing preview...', 'working'),
            onStopPreview: () => _setStatus('Preview stopped', 'ready'),
            onResetView: () => _setStatus('View reset', 'ready'),
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
    return AlertDialog(
      title: const Text('New Project'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Project Name',
                hintText: 'Enter project name',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a project name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Enter project description',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _tagsController,
              decoration: const InputDecoration(
                labelText: 'Tags (Optional)',
                hintText: 'Enter tags separated by commas',
              ),
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
          child: const Text('Create'),
        ),
      ],
    );
  }
}
