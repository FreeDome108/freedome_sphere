import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:freedome_editor_comics/freedome_editor_comics.dart' as comics;
import '../models/project.dart';
import '../services/project_service.dart';
import '../services/boranko_service.dart';
import '../widgets/toolbar.dart';
import '../widgets/project_sidebar.dart';
import '../widgets/viewport_3d.dart';
import '../widgets/status_bar.dart';
import 'aibasic_ide_screen.dart';
import 'anantasound_screen.dart';
import 'unreal_optimizer_screen.dart';
import 'unreal_plugin_integration_screen.dart';
import 'lyubomir_learning_system_screen.dart';
import 'tutorials_screen.dart';
import 'jpg_screen.dart';
import 'gif_screen.dart';
import 'video_screen.dart';
import 'freedome_integration_screen.dart';
import '../pages/comics_editor_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  FreedomeProject? _currentProject;
  bool _isLoading = false;
  String _statusMessage = 'Готов к работе';
  String _statusType = 'ready';
  bool _showSidebar = true;
  double _sidebarWidth = 300.0;
  bool _showStatusBar = true;
  double _statusBarHeight = 45.0;

  // Navigation state
  List<String> _projectHistory = [];
  int _currentProjectIndex = -1;

  // Learning system state
  bool _learningSystemActive = false;

  // Plugin state
  int _activePluginsCount = 0;

  // Comics editor integration
  late comics.ComicsViewModel _comicsViewModel;
  bool _comicsEditorActive = false;
  bool _isComicsInitialized = false;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeComicsEditor();
    _loadCurrentProject();
    _initializeServices();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _fadeController.forward();
    _slideController.forward();
  }

  Future<void> _initializeComicsEditor() async {
    try {
      _comicsViewModel = comics.ComicsViewModel();
      await _comicsViewModel.initializeComics(null);
      setState(() {
        _isComicsInitialized = true;
      });
    } catch (e) {
      print('Ошибка инициализации редактора комиксов: $e');
    }
  }

  Future<void> _initializeServices() async {
    // Initialize learning system service
    try {
      // Check if learning system is active (placeholder logic)
      _learningSystemActive = false;

      // Count active plugins
      _activePluginsCount = 2; // Placeholder: AIBASIC IDE + AnantaSound

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Ошибка инициализации сервисов: $e');
    }
  }

  Future<void> _loadCurrentProject() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Загрузка проекта...';
      _statusType = 'working';
    });

    try {
      final projectService = context.read<ProjectService>();
      final currentProject = await projectService.getCurrentProject();

      if (currentProject == null) {
        // Создаем новый проект по умолчанию
        final newProject = await projectService.createNewProject(
          name: 'Новый проект',
          description: 'Проект FreeDome Sphere',
          tags: ['default', 'new'],
        );
        await projectService.setCurrentProject(newProject.id);
        setState(() {
          _currentProject = newProject;
        });
      } else {
        setState(() {
          _currentProject = currentProject;
        });
      }

      setState(() {
        _isLoading = false;
        _statusMessage = 'Проект загружен: ${_currentProject!.name}';
        _statusType = 'ready';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Ошибка загрузки проекта: $e';
        _statusType = 'error';
      });
    }
  }

  Future<void> _createNewProject() async {
    final result = await _showNewProjectDialog();
    if (result != null) {
      setState(() {
        _isLoading = true;
        _statusMessage = 'Создание нового проекта...';
        _statusType = 'working';
      });

      try {
        final projectService = context.read<ProjectService>();
        final newProject = await projectService.createNewProject(
          name: result['name'],
          description: result['description'] ?? '',
          tags: result['tags'] ?? [],
        );

        await projectService.setCurrentProject(newProject.id);

        setState(() {
          _currentProject = newProject;
          _isLoading = false;
          _statusMessage = 'Новый проект создан: ${newProject.name}';
          _statusType = 'ready';
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
          _statusMessage = 'Ошибка создания проекта: $e';
          _statusType = 'error';
        });
      }
    }
  }

  Future<void> _openProject() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['fsp', 'json'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _isLoading = true;
          _statusMessage = 'Открытие проекта...';
          _statusType = 'working';
        });

        try {
          final projectService = context.read<ProjectService>();
          final filePath = result.files.first.path!;
          final importedProject = await projectService.importProject(filePath);

          if (importedProject != null) {
            await projectService.setCurrentProject(importedProject.id);

            setState(() {
              _currentProject = importedProject;
              _isLoading = false;
              _statusMessage = 'Проект открыт: ${importedProject.name}';
              _statusType = 'ready';
            });
          } else {
            setState(() {
              _isLoading = false;
              _statusMessage = 'Ошибка импорта проекта';
              _statusType = 'error';
            });
          }
        } catch (e) {
          setState(() {
            _isLoading = false;
            _statusMessage = 'Ошибка открытия проекта: $e';
            _statusType = 'error';
          });
        }
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Ошибка выбора файла: $e';
        _statusType = 'error';
      });
    }
  }

  Future<void> _saveProject() async {
    if (_currentProject == null) return;

    setState(() {
      _isLoading = true;
      _statusMessage = 'Сохранение проекта...';
      _statusType = 'working';
    });

    try {
      final projectService = context.read<ProjectService>();
      final success = await projectService.saveProject(_currentProject!);

      setState(() {
        _isLoading = false;
        _statusMessage = success
            ? 'Проект сохранен: ${_currentProject!.name}'
            : 'Ошибка сохранения проекта';
        _statusType = success ? 'ready' : 'error';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Ошибка сохранения: $e';
        _statusType = 'error';
      });
    }
  }

  void _updateProject(Map<String, dynamic> projectData) {
    if (_currentProject == null) return;

    // Обновляем проект с новыми данными
    setState(() {
      _currentProject = _currentProject!.copyWith(
        name: projectData['name'] ?? _currentProject!.name,
        description: projectData['description'] ?? _currentProject!.description,
        tags: projectData['tags'] ?? _currentProject!.tags,
        dome: projectData['dome'] != null
            ? _currentProject!.dome.copyWith(
                resolution: projectData['domeResolution'] != null
                    ? _parseResolution(projectData['domeResolution'])
                    : _currentProject!.dome.resolution,
                projectionType:
                    projectData['projectionType'] ??
                    _currentProject!.dome.projectionType,
              )
            : _currentProject!.dome,
      );
    });
  }

  Resolution _parseResolution(String resolution) {
    switch (resolution) {
      case '2K':
        return Resolution(width: 2048, height: 1024);
      case '4K':
        return Resolution(width: 4096, height: 2048);
      case '8K':
        return Resolution(width: 8192, height: 4096);
      default:
        return Resolution(width: 4096, height: 2048);
    }
  }

  void _updateStatus(String message, String type) {
    setState(() {
      _statusMessage = message;
      _statusType = type;
    });
  }

  void _toggleSidebar() {
    setState(() {
      _showSidebar = !_showSidebar;
    });
  }

  void _toggleStatusBar() {
    setState(() {
      _showStatusBar = !_showStatusBar;
    });
  }

  void _toggleComicsEditor() {
    setState(() {
      _comicsEditorActive = !_comicsEditorActive;
    });
  }

  void _playPreview() {
    setState(() {
      _statusMessage = 'Воспроизведение превью...';
      _statusType = 'working';
    });

    // Симуляция воспроизведения
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _statusMessage = 'Превью воспроизведено';
          _statusType = 'ready';
        });
      }
    });
  }

  void _stopPreview() {
    setState(() {
      _statusMessage = 'Превью остановлено';
      _statusType = 'ready';
    });
  }

  void _resetView() {
    setState(() {
      _statusMessage = 'Вид сброшен';
      _statusType = 'ready';
    });
  }

  void _importBoranko() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['boranko'],
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _statusMessage = 'Импорт .boranko файлов...';
          _statusType = 'working';
        });

        try {
          final borankoService = context.read<BorankoService>();
          int successCount = 0;

          for (final file in result.files) {
            try {
              await borankoService.importBorankoProject(file.path!);
              successCount++;
              // Здесь можно добавить проект в текущий проект
            } catch (e) {
              print('Ошибка импорта ${file.name}: $e');
            }
          }

          setState(() {
            _statusMessage = 'Импортировано $successCount .boranko файлов';
            _statusType = 'ready';
          });
        } catch (e) {
          setState(() {
            _statusMessage = 'Ошибка импорта .boranko: $e';
            _statusType = 'error';
          });
        }
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Ошибка выбора .boranko файлов: $e';
        _statusType = 'error';
      });
    }
  }

  void _importComics() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['comics', 'zip', 'rar', '7z', 'cbz', 'cbr'],
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _statusMessage = 'Импорт .comics файлов...';
          _statusType = 'working';
        });

        try {
          final borankoService = context.read<BorankoService>();
          int successCount = 0;

          for (final file in result.files) {
            try {
              await borankoService.importComicsAsBoranko(file.path!);
              successCount++;
              // Здесь можно добавить проект в текущий проект
            } catch (e) {
              print('Ошибка импорта ${file.name}: $e');
            }
          }

          setState(() {
            _statusMessage = 'Импортировано $successCount .comics файлов';
            _statusType = 'ready';
          });
        } catch (e) {
          setState(() {
            _statusMessage = 'Ошибка импорта .comics: $e';
            _statusType = 'error';
          });
        }
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Ошибка выбора .comics файлов: $e';
        _statusType = 'error';
      });
    }
  }

  void _openAIBasicIDE() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const AIBasicIDEScreen()));
  }

  void _openAnantaSound() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const AnantaSoundScreen()));
  }

  void _openUnrealOptimizer() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const UnrealOptimizerScreen()),
    );
  }

  void _openUnrealPluginIntegration() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const UnrealPluginIntegrationScreen(),
      ),
    );
  }

  void _openLyubomirLearningSystem() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const LyubomirLearningSystemScreen(),
      ),
    );
  }

  void _openTutorials() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const TutorialsScreen(tutorials: []),
      ),
    );
  }

  void _openJpgScreen() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const JpgScreen()));
  }

  void _openGifScreen() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const GifScreen()));
  }

  void _openVideoScreen() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const VideoScreen()));
  }

  void _openFreedomeIntegration() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const FreedomeIntegrationScreen(),
      ),
    );
  }

  void _openComicsEditor() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const ComicsEditorPage()));
  }

  void _navigateToPreviousProject() {
    if (_canNavigateBack()) {
      setState(() {
        _currentProjectIndex--;
        _statusMessage = 'Переход к предыдущему проекту...';
        _statusType = 'working';
      });

      // Simulate project loading
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _statusMessage = 'Предыдущий проект загружен';
            _statusType = 'ready';
          });
        }
      });
    }
  }

  void _navigateToNextProject() {
    if (_canNavigateForward()) {
      setState(() {
        _currentProjectIndex++;
        _statusMessage = 'Переход к следующему проекту...';
        _statusType = 'working';
      });

      // Simulate project loading
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _statusMessage = 'Следующий проект загружен';
            _statusType = 'ready';
          });
        }
      });
    }
  }

  bool _canNavigateBack() {
    return _currentProjectIndex > 0;
  }

  bool _canNavigateForward() {
    return _currentProjectIndex < _projectHistory.length - 1;
  }

  void _openPluginManager() {
    showDialog(
      context: context,
      builder: (context) => _PluginManagerDialog(
        activePluginsCount: _activePluginsCount,
        onPluginToggle: (pluginName, isActive) {
          setState(() {
            if (isActive) {
              _activePluginsCount++;
            } else {
              _activePluginsCount--;
            }
          });
        },
      ),
    );
  }

  Future<Map<String, dynamic>?> _showNewProjectDialog() async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final tagsController = TextEditingController();

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Новый проект'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Название проекта',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Описание (необязательно)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: tagsController,
              decoration: const InputDecoration(
                labelText: 'Теги (через запятую)',
                border: OutlineInputBorder(),
                hintText: '3d, dome, animation',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                final tags = tagsController.text
                    .split(',')
                    .map((tag) => tag.trim())
                    .where((tag) => tag.isNotEmpty)
                    .toList();

                Navigator.of(context).pop({
                  'name': name,
                  'description': descriptionController.text.trim(),
                  'tags': tags,
                });
              }
            },
            child: const Text('Создать'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    if (_isComicsInitialized) {
      _comicsViewModel.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.threesixty, color: Colors.blue),
            const SizedBox(width: 8),
            Text('FreeDome Sphere'),
            if (_currentProject != null) ...[
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Text(
                  _currentProject!.name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          // Переключение боковой панели
          IconButton(
            icon: Icon(_showSidebar ? Icons.dock : Icons.dock_outlined),
            onPressed: _toggleSidebar,
            tooltip: _showSidebar
                ? 'Скрыть боковую панель'
                : 'Показать боковую панель',
          ),
          // Переключение статусной панели
          IconButton(
            icon: Icon(
              _showStatusBar ? Icons.info_outline : Icons.info_outlined,
            ),
            onPressed: _toggleStatusBar,
            tooltip: _showStatusBar
                ? 'Скрыть статусную панель'
                : 'Показать статусную панель',
          ),
          // Переключение редактора комиксов
          IconButton(
            icon: Icon(
              _comicsEditorActive
                  ? Icons.auto_stories
                  : Icons.auto_stories_outlined,
              color: _comicsEditorActive ? Colors.orange : null,
            ),
            onPressed: _toggleComicsEditor,
            tooltip: _comicsEditorActive
                ? 'Скрыть редактор комиксов'
                : 'Показать редактор комиксов',
          ),
          // Меню быстрого доступа к инструментам
          PopupMenuButton<String>(
            icon: const Icon(Icons.build),
            tooltip: 'Инструменты',
            onSelected: (value) {
              switch (value) {
                case 'aibasic':
                  _openAIBasicIDE();
                  break;
                case 'anantasound':
                  _openAnantaSound();
                  break;
                case 'unreal_optimizer':
                  _openUnrealOptimizer();
                  break;
                case 'unreal_plugin':
                  _openUnrealPluginIntegration();
                  break;
                case 'lyubomir':
                  _openLyubomirLearningSystem();
                  break;
                case 'tutorials':
                  _openTutorials();
                  break;
                case 'jpg':
                  _openJpgScreen();
                  break;
                case 'gif':
                  _openGifScreen();
                  break;
                case 'video':
                  _openVideoScreen();
                  break;
                case 'freedome':
                  _openFreedomeIntegration();
                  break;
                case 'comics':
                  _openComicsEditor();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'aibasic',
                child: ListTile(
                  leading: Icon(Icons.code, size: 20),
                  title: Text('AIBASIC IDE'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'anantasound',
                child: ListTile(
                  leading: Icon(Icons.music_note, size: 20),
                  title: Text('AnantaSound'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'unreal_optimizer',
                child: ListTile(
                  leading: Icon(Icons.analytics, size: 20),
                  title: Text('Unreal Optimizer'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'unreal_plugin',
                child: ListTile(
                  leading: Icon(Icons.extension, size: 20),
                  title: Text('Unreal Plugin'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'lyubomir',
                child: ListTile(
                  leading: Icon(Icons.psychology, size: 20),
                  title: Text('Система Любомира'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'tutorials',
                child: ListTile(
                  leading: Icon(Icons.school, size: 20),
                  title: Text('Туториалы'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'jpg',
                child: ListTile(
                  leading: Icon(Icons.image, size: 20),
                  title: Text('JPG Editor'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'gif',
                child: ListTile(
                  leading: Icon(Icons.gif, size: 20),
                  title: Text('GIF Editor'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'video',
                child: ListTile(
                  leading: Icon(Icons.video_library, size: 20),
                  title: Text('Video Editor'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'freedome',
                child: ListTile(
                  leading: Icon(Icons.cable, size: 20, color: Colors.blue),
                  title: Text('FreeDome Integration'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'comics',
                child: ListTile(
                  leading: Icon(
                    Icons.auto_stories,
                    size: 20,
                    color: Colors.orange,
                  ),
                  title: Text('Comics Editor'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              // Панель инструментов
              Toolbar(
                onNewProject: _createNewProject,
                onOpenProject: _openProject,
                onSaveProject: _saveProject,
                onPlayPreview: _playPreview,
                onStopPreview: _stopPreview,
                onResetView: _resetView,
                onImportBoranko: _importBoranko,
                onImportComics: _importComics,
                onPreviousProject: _navigateToPreviousProject,
                onNextProject: _navigateToNextProject,
                onOpenLearningSystem: _openLyubomirLearningSystem,
                onOpenPluginManager: _openPluginManager,
                onOpenAIBasicIDE: _openAIBasicIDE,
                onOpenAnantaSound: _openAnantaSound,
                statusMessage: _statusMessage,
                statusType: _statusType,
                canNavigateBack: _canNavigateBack(),
                canNavigateForward: _canNavigateForward(),
                learningSystemActive: _learningSystemActive,
                activePluginsCount: _activePluginsCount,
              ),

              // Основная рабочая область
              Expanded(
                child: Row(
                  children: [
                    // Боковая панель
                    if (_showSidebar)
                      SizedBox(
                        width: _sidebarWidth,
                        child: ProjectSidebar(
                          project: _currentProject?.toJson() ?? {},
                          onStatusUpdate: _updateStatus,
                          onProjectUpdate: _updateProject,
                        ),
                      ),

                    // Главная область с 3D вьюпортом и редактором комиксов
                    Expanded(
                      child: _comicsEditorActive && _isComicsInitialized
                          ? _buildComicsEditorView()
                          : Viewport3D(
                              project: _currentProject,
                              isLoading: _isLoading,
                            ),
                    ),
                  ],
                ),
              ),

              // Статусная панель
              if (_showStatusBar)
                SizedBox(
                  height: _statusBarHeight,
                  child: StatusBar(
                    message: _statusMessage,
                    type: _statusType,
                    progress: _isLoading ? null : 0.0,
                    systemInfo: {
                      'memoryUsage': 512,
                      'activePlugins': _activePluginsCount,
                      'learningActive': _learningSystemActive,
                      'comicsEditorActive': _comicsEditorActive,
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComicsEditorView() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.orange.withOpacity(0.1),
            Colors.blue.withOpacity(0.1),
          ],
        ),
      ),
      child: Column(
        children: [
          // Информационная панель редактора комиксов
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              border: Border(
                bottom: BorderSide(
                  color: Colors.orange.withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_stories, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'Редактор комиксов',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  'Слои: ${_comicsViewModel.layers.length}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(width: 16),
                Text(
                  'Звуки: ${_comicsViewModel.sounds.length}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(width: 16),
                Text(
                  '${_comicsViewModel.width}x${_comicsViewModel.height}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),

          // Основная область редактора
          Expanded(
            child: Row(
              children: [
                // Панель управления
                Container(
                  width: 250,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    border: Border(
                      right: BorderSide(
                        color: Colors.grey.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Кнопки управления
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            ElevatedButton.icon(
                              onPressed: _addComicsLayer,
                              icon: const Icon(Icons.add_photo_alternate),
                              label: const Text('Добавить слой'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: _addComicsSound,
                              icon: const Icon(Icons.audiotrack),
                              label: const Text('Добавить звук'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: _saveComics,
                              icon: const Icon(Icons.save),
                              label: const Text('Сохранить'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Настройки
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            // Скролл
                            Text(
                              'Прокрутка: ${_comicsViewModel.scroll.round()}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Slider(
                              value: _comicsViewModel.scroll,
                              min: 0,
                              max: 1000,
                              divisions: 100,
                              onChanged: (value) {
                                setState(() {
                                  _comicsViewModel.scroll = value;
                                });
                              },
                            ),

                            const SizedBox(height: 16),

                            // Язык
                            Text(
                              'Язык:',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            DropdownButton<comics.Cultures>(
                              value: _comicsViewModel.culture,
                              isExpanded: true,
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _comicsViewModel.culture = value;
                                  });
                                }
                              },
                              items: comics.CulturesHelper.all.map((culture) {
                                return DropdownMenuItem(
                                  value: culture,
                                  child: Text(
                                    culture
                                        .toString()
                                        .split('.')
                                        .last
                                        .toUpperCase(),
                                  ),
                                );
                              }).toList(),
                            ),

                            const SizedBox(height: 16),

                            // Отключить звук
                            Row(
                              children: [
                                Text(
                                  'Отключить звук:',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const Spacer(),
                                Switch(
                                  value: _comicsViewModel.disableSound,
                                  onChanged: (value) {
                                    setState(() {
                                      _comicsViewModel.disableSound = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Область предварительного просмотра
                Expanded(
                  child: Container(
                    color: Colors.white,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.auto_stories,
                            size: 64,
                            color: Colors.orange.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Предварительный просмотр комикса',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(color: Colors.orange),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Размер: ${_comicsViewModel.width}x${_comicsViewModel.height}',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addComicsLayer() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        await _comicsViewModel.addLayer(result.files.single.path!);
        setState(() {});
        _updateStatus('Слой добавлен', 'ready');
      }
    } catch (e) {
      _updateStatus('Ошибка добавления слоя: $e', 'error');
    }
  }

  Future<void> _addComicsSound() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        await _comicsViewModel.addSound(result.files.single.path!);
        setState(() {});
        _updateStatus('Звук добавлен', 'ready');
      }
    } catch (e) {
      _updateStatus('Ошибка добавления звука: $e', 'error');
    }
  }

  Future<void> _saveComics() async {
    try {
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Сохранить комикс',
        fileName: 'comics.comics',
        type: FileType.custom,
        allowedExtensions: ['comics'],
      );

      if (result != null) {
        await _comicsViewModel.save(result);
        _updateStatus('Комикс сохранен', 'ready');
      }
    } catch (e) {
      _updateStatus('Ошибка сохранения комикса: $e', 'error');
    }
  }
}

/// Dialog for managing plugins
class _PluginManagerDialog extends StatefulWidget {
  final int activePluginsCount;
  final Function(String pluginName, bool isActive) onPluginToggle;

  const _PluginManagerDialog({
    required this.activePluginsCount,
    required this.onPluginToggle,
  });

  @override
  State<_PluginManagerDialog> createState() => _PluginManagerDialogState();
}

class _PluginManagerDialogState extends State<_PluginManagerDialog> {
  final Map<String, bool> _plugins = {
    'AIBASIC IDE': true,
    'AnantaSound': true,
    'Unreal Optimizer': false,
    'Unreal Plugin Integration': false,
    'Video Editor': false,
    'GIF Editor': false,
    'JPG Editor': false,
  };

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.extension, color: Colors.blue),
          const SizedBox(width: 8),
          const Text('Менеджер плагинов'),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Активно: ${_plugins.values.where((active) => active).length}',
              style: const TextStyle(fontSize: 12, color: Colors.blue),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 400,
        height: 300,
        child: Column(
          children: [
            const Text(
              'Управляйте активными плагинами для оптимизации производительности',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _plugins.length,
                itemBuilder: (context, index) {
                  final pluginName = _plugins.keys.elementAt(index);
                  final isActive = _plugins[pluginName]!;

                  return Card(
                    child: ListTile(
                      leading: Icon(
                        _getPluginIcon(pluginName),
                        color: isActive ? Colors.green : Colors.grey,
                      ),
                      title: Text(pluginName),
                      subtitle: Text(
                        isActive ? 'Активен' : 'Неактивен',
                        style: TextStyle(
                          color: isActive ? Colors.green : Colors.grey,
                        ),
                      ),
                      trailing: Switch(
                        value: isActive,
                        onChanged: (value) {
                          setState(() {
                            _plugins[pluginName] = value;
                          });
                          widget.onPluginToggle(pluginName, value);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Закрыть'),
        ),
        ElevatedButton(
          onPressed: () {
            // Apply plugin changes
            Navigator.of(context).pop();
          },
          child: const Text('Применить'),
        ),
      ],
    );
  }

  IconData _getPluginIcon(String pluginName) {
    switch (pluginName) {
      case 'AIBASIC IDE':
        return Icons.code;
      case 'AnantaSound':
        return Icons.music_note;
      case 'Unreal Optimizer':
        return Icons.analytics;
      case 'Unreal Plugin Integration':
        return Icons.extension;
      case 'Video Editor':
        return Icons.video_library;
      case 'GIF Editor':
        return Icons.gif;
      case 'JPG Editor':
        return Icons.image;
      default:
        return Icons.extension;
    }
  }
}
