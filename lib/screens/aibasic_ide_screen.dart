import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../services/aibasic_ide_service.dart';
import '../services/locale_service.dart';
import '../l10n/app_localizations.dart';
import '../widgets/aibasic_editor.dart';
import '../widgets/aibasic_terminal.dart';
import '../widgets/aibasic_file_explorer.dart';

class AIBasicIDEScreen extends StatefulWidget {
  const AIBasicIDEScreen({super.key});

  @override
  State<AIBasicIDEScreen> createState() => _AIBasicIDEScreenState();
}

class _AIBasicIDEScreenState extends State<AIBasicIDEScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showSearch = false;
  bool _showFileExplorer = true;
  bool _showTerminal = false;
  double _fileExplorerWidth = 250.0;
  double _terminalHeight = 200.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AIBasicIDEService>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final ideService = context.watch<AIBasicIDEService>();

    return Scaffold(
      appBar: _buildAppBar(l10n, ideService),
      body: Row(
        children: [
          if (_showFileExplorer) _buildFileExplorer(ideService),
          _buildMainContent(ideService),
        ],
      ),
      bottomNavigationBar: _showTerminal ? _buildTerminal(ideService) : null,
    );
  }

  PreferredSizeWidget _buildAppBar(AppLocalizations l10n, AIBasicIDEService ideService) {
    return AppBar(
      title: Text('AIBASIC IDE - ${ideService.getLanguageName(ideService.currentLanguage)}'),
      actions: [
        // Поиск
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            setState(() {
              _showSearch = !_showSearch;
            });
            if (_showSearch) {
              _searchController.clear();
            }
          },
        ),
        // Язык
        PopupMenuButton<String>(
          icon: const Icon(Icons.language),
          onSelected: (language) {
            ideService.setLanguage(language);
          },
          itemBuilder: (context) {
            return ideService.getAvailableLanguages().map((language) {
              return PopupMenuItem<String>(
                value: language,
                child: Row(
                  children: [
                    if (language == ideService.currentLanguage)
                      const Icon(Icons.check, size: 16),
                    const SizedBox(width: 8),
                    Text(ideService.getLanguageName(language)),
                  ],
                ),
              );
            }).toList();
          },
        ),
        // Настройки
        PopupMenuButton<String>(
          icon: const Icon(Icons.settings),
          onSelected: (setting) => _handleSettingChange(setting, ideService),
          itemBuilder: (context) {
            return [
              PopupMenuItem(
                value: 'theme',
                child: Row(
                  children: [
                    const Icon(Icons.palette),
                    const SizedBox(width: 8),
                    Text('Theme: ${ideService.theme}'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'fontSize',
                child: Row(
                  children: [
                    const Icon(Icons.text_fields),
                    const SizedBox(width: 8),
                    Text('Font Size: ${ideService.fontSize}'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'autoSave',
                child: Row(
                  children: [
                    Icon(ideService.autoSave ? Icons.save : Icons.save_alt),
                    const SizedBox(width: 8),
                    Text('Auto Save: ${ideService.autoSave ? 'On' : 'Off'}'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'syntaxHighlighting',
                child: Row(
                  children: [
                    Icon(ideService.syntaxHighlighting ? Icons.color_lens : Icons.color_lens_outlined),
                    const SizedBox(width: 8),
                    Text('Syntax Highlighting: ${ideService.syntaxHighlighting ? 'On' : 'Off'}'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'autoComplete',
                child: Row(
                  children: [
                    Icon(ideService.autoComplete ? Icons.auto_awesome : Icons.auto_awesome_outlined),
                    const SizedBox(width: 8),
                    Text('Auto Complete: ${ideService.autoComplete ? 'On' : 'Off'}'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'lineNumbers',
                child: Row(
                  children: [
                    Icon(ideService.lineNumbers ? Icons.format_list_numbered : Icons.format_list_numbered_outlined),
                    const SizedBox(width: 8),
                    Text('Line Numbers: ${ideService.lineNumbers ? 'On' : 'Off'}'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'wordWrap',
                child: Row(
                  children: [
                    Icon(ideService.wordWrap ? Icons.wrap_text : Icons.wrap_text_outlined),
                    const SizedBox(width: 8),
                    Text('Word Wrap: ${ideService.wordWrap ? 'On' : 'Off'}'),
                  ],
                ),
              ),
            ];
          },
        ),
        // Файловый проводник
        IconButton(
          icon: Icon(_showFileExplorer ? Icons.folder_open : Icons.folder),
          onPressed: () {
            setState(() {
              _showFileExplorer = !_showFileExplorer;
            });
          },
        ),
        // Терминал
        IconButton(
          icon: Icon(_showTerminal ? Icons.terminal : Icons.terminal_outlined),
          onPressed: () {
            setState(() {
              _showTerminal = !_showTerminal;
            });
          },
        ),
      ],
    );
  }

  Widget _buildFileExplorer(AIBasicIDEService ideService) {
    return SizedBox(
      width: _fileExplorerWidth,
      child: Column(
        children: [
          // Заголовок файлового проводника
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              border: Border(
                bottom: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.folder, size: 16),
                const SizedBox(width: 8),
                const Text('Files'),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add, size: 16),
                  onPressed: () => _showNewFileDialog(),
                ),
                IconButton(
                  icon: const Icon(Icons.folder_open, size: 16),
                  onPressed: () => _openFolder(),
                ),
              ],
            ),
          ),
          // Список файлов
          Expanded(
            child: AIBasicFileExplorer(
              onFileSelected: (filePath) => ideService.openFile(filePath),
              onFileCreated: (filePath) => _createNewFile(filePath),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(AIBasicIDEService ideService) {
    return Expanded(
      child: Column(
        children: [
          // Вкладки открытых файлов
          if (ideService.openFiles.isNotEmpty) _buildFileTabs(ideService),
          // Редактор
          Expanded(
            child: AIBasicEditor(
              content: ideService.currentContent,
              onContentChanged: (content) => ideService.updateContent(content),
              language: ideService.currentLanguage,
              theme: ideService.theme,
              fontSize: ideService.fontSize,
              fontFamily: ideService.fontFamily,
              syntaxHighlighting: ideService.syntaxHighlighting,
              autoComplete: ideService.autoComplete,
              lineNumbers: ideService.lineNumbers,
              wordWrap: ideService.wordWrap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileTabs(AIBasicIDEService ideService) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: ideService.openFiles.length,
        itemBuilder: (context, index) {
          final filePath = ideService.openFiles[index];
          final fileName = filePath.split('/').last;
          final isActive = filePath == ideService.currentFile;
          
          return Container(
            margin: const EdgeInsets.only(right: 2),
            child: Material(
              color: isActive 
                ? Theme.of(context).colorScheme.primaryContainer
                : Theme.of(context).colorScheme.surface,
              child: InkWell(
                onTap: () => ideService.openFile(filePath),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getFileIcon(fileName),
                        size: 16,
                        color: isActive 
                          ? Theme.of(context).colorScheme.onPrimaryContainer
                          : Theme.of(context).colorScheme.onSurface,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        fileName,
                        style: TextStyle(
                          color: isActive 
                            ? Theme.of(context).colorScheme.onPrimaryContainer
                            : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => ideService.closeFile(filePath),
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: isActive 
                            ? Theme.of(context).colorScheme.onPrimaryContainer
                            : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTerminal(AIBasicIDEService ideService) {
    return SizedBox(
      height: _terminalHeight,
      child: AIBasicTerminal(
        onCommand: (command) {
          ideService.addToHistory(command);
          // Здесь будет обработка команд AIBASIC
        },
        history: ideService.commandHistory,
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search in file...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              setState(() {
                _showSearch = false;
              });
            },
          ),
        ),
        onSubmitted: (query) {
          // Здесь будет реализация поиска
        },
      ),
    );
  }

  IconData _getFileIcon(String fileName) {
    if (fileName.endsWith('.aibasic')) {
      return Icons.code;
    } else if (fileName.endsWith('.json')) {
      return Icons.data_object;
    } else if (fileName.endsWith('.md')) {
      return Icons.description;
    } else {
      return Icons.insert_drive_file;
    }
  }

  void _handleSettingChange(String setting, AIBasicIDEService ideService) {
    switch (setting) {
      case 'theme':
        _showThemeDialog(ideService);
        break;
      case 'fontSize':
        _showFontSizeDialog(ideService);
        break;
      case 'autoSave':
        ideService.toggleAutoSave();
        break;
      case 'syntaxHighlighting':
        ideService.toggleSyntaxHighlighting();
        break;
      case 'autoComplete':
        ideService.toggleAutoComplete();
        break;
      case 'lineNumbers':
        ideService.toggleLineNumbers();
        break;
      case 'wordWrap':
        ideService.toggleWordWrap();
        break;
    }
  }

  void _showThemeDialog(AIBasicIDEService ideService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Dark'),
              leading: Radio<String>(
                value: 'dark',
                groupValue: ideService.theme,
                onChanged: (value) {
                  if (value != null) {
                    ideService.setTheme(value);
                    Navigator.pop(context);
                  }
                },
              ),
            ),
            ListTile(
              title: const Text('Light'),
              leading: Radio<String>(
                value: 'light',
                groupValue: ideService.theme,
                onChanged: (value) {
                  if (value != null) {
                    ideService.setTheme(value);
                    Navigator.pop(context);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFontSizeDialog(AIBasicIDEService ideService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Font Size'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Slider(
              value: ideService.fontSize.toDouble(),
              min: 8,
              max: 24,
              divisions: 16,
              label: ideService.fontSize.toString(),
              onChanged: (value) {
                ideService.setFontSize(value.round());
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showNewFileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New File'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'File name',
                hintText: 'example.aibasic',
              ),
              onSubmitted: (fileName) {
                if (fileName.isNotEmpty) {
                  _createNewFile(fileName);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Создание нового файла
              Navigator.pop(context);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _openFolder() async {
    try {
      final result = await FilePicker.platform.getDirectoryPath();
      if (result != null) {
        // Открытие папки
        debugPrint('Selected folder: $result');
      }
    } catch (e) {
      debugPrint('Error opening folder: $e');
    }
  }

  Future<void> _createNewFile(String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsString('');
      context.read<AIBasicIDEService>().openFile(filePath);
    } catch (e) {
      debugPrint('Error creating file: $e');
    }
  }
}
