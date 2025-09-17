import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class AIBasicFileExplorer extends StatefulWidget {
  final Function(String) onFileSelected;
  final Function(String) onFileCreated;

  const AIBasicFileExplorer({
    super.key,
    required this.onFileSelected,
    required this.onFileCreated,
  });

  @override
  State<AIBasicFileExplorer> createState() => _AIBasicFileExplorerState();
}

class _AIBasicFileExplorerState extends State<AIBasicFileExplorer> {
  String _currentPath = '';
  List<FileSystemEntity> _files = [];
  bool _isLoading = false;
  String? _selectedFile;

  @override
  void initState() {
    super.initState();
    _loadCurrentDirectory();
  }

  Future<void> _loadCurrentDirectory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (_currentPath.isEmpty) {
        // Загружаем домашнюю директорию
        final homeDir = Directory('/Users/anton');
        _currentPath = homeDir.path;
      }

      final directory = Directory(_currentPath);
      if (await directory.exists()) {
        final entities = await directory.list().toList();
        entities.sort((a, b) {
          // Сначала папки, потом файлы
          if (a is Directory && b is File) return -1;
          if (a is File && b is Directory) return 1;
          return a.path.toLowerCase().compareTo(b.path.toLowerCase());
        });
        
        setState(() {
          _files = entities;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('Error loading directory: $e');
    }
  }

  Future<void> _navigateToDirectory(String path) async {
    setState(() {
      _currentPath = path;
      _selectedFile = null;
    });
    await _loadCurrentDirectory();
  }

  Future<void> _navigateUp() async {
    if (_currentPath.isNotEmpty) {
      final parent = Directory(_currentPath).parent.path;
      await _navigateToDirectory(parent);
    }
  }

  Future<void> _createNewFile() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => _CreateFileDialog(),
    );

    if (result != null && result.isNotEmpty) {
      try {
        final filePath = '$_currentPath/$result';
        final file = File(filePath);
        await file.writeAsString('');
        widget.onFileCreated(filePath);
        await _loadCurrentDirectory();
      } catch (e) {
        debugPrint('Error creating file: $e');
      }
    }
  }

  Future<void> _createNewFolder() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => _CreateFolderDialog(),
    );

    if (result != null && result.isNotEmpty) {
      try {
        final folderPath = '$_currentPath/$result';
        final directory = Directory(folderPath);
        await directory.create();
        await _loadCurrentDirectory();
      } catch (e) {
        debugPrint('Error creating folder: $e');
      }
    }
  }

  Future<void> _deleteFile(FileSystemEntity entity) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete'),
        content: Text('Are you sure you want to delete "${entity.path.split('/').last}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await entity.delete();
        await _loadCurrentDirectory();
      } catch (e) {
        debugPrint('Error deleting file: $e');
      }
    }
  }

  Future<void> _renameFile(FileSystemEntity entity) async {
    final currentName = entity.path.split('/').last;
    final result = await showDialog<String>(
      context: context,
      builder: (context) => _RenameDialog(currentName: currentName),
    );

    if (result != null && result.isNotEmpty && result != currentName) {
      try {
        final newPath = '${entity.parent.path}/$result';
        await entity.rename(newPath);
        await _loadCurrentDirectory();
      } catch (e) {
        debugPrint('Error renaming file: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Панель навигации
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
              IconButton(
                icon: const Icon(Icons.arrow_back, size: 16),
                onPressed: _currentPath.isNotEmpty ? _navigateUp : null,
                tooltip: 'Go back',
              ),
              IconButton(
                icon: const Icon(Icons.refresh, size: 16),
                onPressed: _loadCurrentDirectory,
                tooltip: 'Refresh',
              ),
              Expanded(
                child: Text(
                  _currentPath.isEmpty ? 'Home' : _currentPath.split('/').last,
                  style: const TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.create_new_folder, size: 16),
                onPressed: _createNewFolder,
                tooltip: 'New folder',
              ),
              IconButton(
                icon: const Icon(Icons.add, size: 16),
                onPressed: _createNewFile,
                tooltip: 'New file',
              ),
            ],
          ),
        ),
        // Список файлов
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _files.isEmpty
                  ? const Center(
                      child: Text(
                        'No files found',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _files.length,
                      itemBuilder: (context, index) {
                        final entity = _files[index];
                        final isSelected = _selectedFile == entity.path;
                        final isDirectory = entity is Directory;
                        final fileName = entity.path.split('/').last;

                        return ListTile(
                          leading: Icon(
                            isDirectory ? Icons.folder : _getFileIcon(fileName),
                            size: 20,
                            color: isDirectory ? Colors.blue : Colors.grey,
                          ),
                          title: Text(
                            fileName,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          selected: isSelected,
                          onTap: () {
                            setState(() {
                              _selectedFile = entity.path;
                            });
                            
                            if (isDirectory) {
                              _navigateToDirectory(entity.path);
                            } else {
                              widget.onFileSelected(entity.path);
                            }
                          },
                          onLongPress: () {
                            _showContextMenu(entity);
                          },
                        );
                      },
                    ),
        ),
      ],
    );
  }

  IconData _getFileIcon(String fileName) {
    if (fileName.endsWith('.aibasic')) {
      return Icons.code;
    } else if (fileName.endsWith('.json')) {
      return Icons.data_object;
    } else if (fileName.endsWith('.md')) {
      return Icons.description;
    } else if (fileName.endsWith('.txt')) {
      return Icons.text_snippet;
    } else if (fileName.endsWith('.dart')) {
      return Icons.code;
    } else if (fileName.endsWith('.py')) {
      return Icons.code;
    } else if (fileName.endsWith('.js')) {
      return Icons.code;
    } else if (fileName.endsWith('.html')) {
      return Icons.code;
    } else if (fileName.endsWith('.css')) {
      return Icons.code;
    } else {
      return Icons.insert_drive_file;
    }
  }

  void _showContextMenu(FileSystemEntity entity) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Rename'),
              onTap: () {
                Navigator.pop(context);
                _renameFile(entity);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete'),
              onTap: () {
                Navigator.pop(context);
                _deleteFile(entity);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateFileDialog extends StatefulWidget {
  @override
  State<_CreateFileDialog> createState() => _CreateFileDialogState();
}

class _CreateFileDialogState extends State<_CreateFileDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create New File'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          labelText: 'File name',
          hintText: 'example.aibasic',
        ),
        autofocus: true,
        onSubmitted: (value) {
          if (value.isNotEmpty) {
            Navigator.pop(context, value);
          }
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_controller.text.isNotEmpty) {
              Navigator.pop(context, _controller.text);
            }
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}

class _CreateFolderDialog extends StatefulWidget {
  @override
  State<_CreateFolderDialog> createState() => _CreateFolderDialogState();
}

class _CreateFolderDialogState extends State<_CreateFolderDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create New Folder'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          labelText: 'Folder name',
          hintText: 'New Folder',
        ),
        autofocus: true,
        onSubmitted: (value) {
          if (value.isNotEmpty) {
            Navigator.pop(context, value);
          }
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_controller.text.isNotEmpty) {
              Navigator.pop(context, _controller.text);
            }
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}

class _RenameDialog extends StatefulWidget {
  final String currentName;

  const _RenameDialog({required this.currentName});

  @override
  State<_RenameDialog> createState() => _RenameDialogState();
}

class _RenameDialogState extends State<_RenameDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rename'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          labelText: 'New name',
        ),
        autofocus: true,
        onSubmitted: (value) {
          if (value.isNotEmpty) {
            Navigator.pop(context, value);
          }
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_controller.text.isNotEmpty) {
              Navigator.pop(context, _controller.text);
            }
          },
          child: const Text('Rename'),
        ),
      ],
    );
  }
}
