import 'package:flutter/material.dart';
import 'package:freedome_editor_comics/freedome_editor_comics.dart';
import 'package:file_picker/file_picker.dart';

class ComicsEditorPage extends StatefulWidget {
  const ComicsEditorPage({super.key});

  @override
  State<ComicsEditorPage> createState() => _ComicsEditorPageState();
}

class _ComicsEditorPageState extends State<ComicsEditorPage> {
  late ComicsViewModel _viewModel;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _viewModel = ComicsViewModel();
    _initializeComics();
  }

  Future<void> _initializeComics() async {
    try {
      await _viewModel.initializeComics(null);
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error initializing comics: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _addLayer() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        await _viewModel.addLayer(result.files.single.path!);
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error adding layer: $e')));
      }
    }
  }

  Future<void> _addSound() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        await _viewModel.addSound(result.files.single.path!);
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error adding sound: $e')));
      }
    }
  }

  Future<void> _saveComics() async {
    try {
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Comics',
        fileName: 'comics.comics',
        type: FileType.custom,
        allowedExtensions: ['comics'],
      );

      if (result != null) {
        await _viewModel.save(result);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Comics saved successfully!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving comics: $e')));
      }
    }
  }

  Future<void> _loadComics() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['comics', 'puzzle'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        await _viewModel.initializeComics(result.files.single.path!);
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading comics: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comics Editor'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_open),
            onPressed: _loadComics,
            tooltip: 'Load Comics',
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveComics,
            tooltip: 'Save Comics',
          ),
        ],
      ),
      body: Column(
        children: [
          // Информация о комиксе
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Comics Information',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Width: ${_viewModel.width}px'),
                      Text('Height: ${_viewModel.height}px'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Layers: ${_viewModel.layers.length}'),
                      Text('Sounds: ${_viewModel.sounds.length}'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Контролы
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Кнопки добавления
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _addLayer,
                        icon: const Icon(Icons.image),
                        label: const Text('Add Layer'),
                      ),
                      ElevatedButton.icon(
                        onPressed: _addSound,
                        icon: const Icon(Icons.audiotrack),
                        label: const Text('Add Sound'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Скролл контрол
                  Row(
                    children: [
                      const Text('Scroll: '),
                      Expanded(
                        child: Slider(
                          value: _viewModel.scroll,
                          min: 0,
                          max: 1000,
                          divisions: 100,
                          onChanged: (value) {
                            setState(() {
                              _viewModel.scroll = value;
                            });
                          },
                        ),
                      ),
                      Text('${_viewModel.scroll.round()}'),
                    ],
                  ),

                  // Язык контрол
                  Row(
                    children: [
                      const Text('Language: '),
                      DropdownButton<Cultures>(
                        value: _viewModel.culture,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _viewModel.culture = value;
                            });
                          }
                        },
                        items: CulturesHelper.all.map((culture) {
                          return DropdownMenuItem(
                            value: culture,
                            child: Text(
                              culture.toString().split('.').last.toUpperCase(),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),

                  // Звук контрол
                  Row(
                    children: [
                      const Text('Disable Sound: '),
                      Switch(
                        value: _viewModel.disableSound,
                        onChanged: (value) {
                          setState(() {
                            _viewModel.disableSound = value;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Список слоев и звуков
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  const TabBar(
                    tabs: [
                      Tab(icon: Icon(Icons.layers), text: 'Layers'),
                      Tab(icon: Icon(Icons.audiotrack), text: 'Sounds'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // Слои
                        ListView.builder(
                          itemCount: _viewModel.layers.length,
                          itemBuilder: (context, index) {
                            final layer = _viewModel.layers[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              child: ListTile(
                                leading: const Icon(Icons.layers),
                                title: Text('Layer ${index + 1}'),
                                subtitle: Text(
                                  'Animations: ${layer.layer.animations.length}',
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () async {
                                    await _viewModel.removeLayer(layer);
                                    setState(() {});
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                        // Звуки
                        ListView.builder(
                          itemCount: _viewModel.sounds.length,
                          itemBuilder: (context, index) {
                            final sound = _viewModel.sounds[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              child: ListTile(
                                leading: Icon(
                                  sound.isPlaying
                                      ? Icons.volume_up
                                      : Icons.volume_off,
                                ),
                                title: Text('Sound ${index + 1}'),
                                subtitle: Text('File: ${sound.sound.file}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        sound.isPlaying
                                            ? Icons.pause
                                            : Icons.play_arrow,
                                      ),
                                      onPressed: () {
                                        if (sound.isPlaying) {
                                          sound.pause();
                                        } else {
                                          sound.play();
                                        }
                                        setState(() {});
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () async {
                                        await _viewModel.removeSound(sound);
                                        setState(() {});
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

