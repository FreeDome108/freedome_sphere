import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/freedome_integration_service.dart';

class FreedomeIntegrationScreen extends StatefulWidget {
  const FreedomeIntegrationScreen({super.key});

  @override
  State<FreedomeIntegrationScreen> createState() =>
      _FreedomeIntegrationScreenState();
}

class _FreedomeIntegrationScreenState extends State<FreedomeIntegrationScreen> {
  final TextEditingController _serverUrlController = TextEditingController(
    text: 'localhost',
  );
  final TextEditingController _portController = TextEditingController(
    text: '8080',
  );
  bool _isInitializing = false;
  bool _isConnecting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeFreedome();
    });
  }

  @override
  void dispose() {
    _serverUrlController.dispose();
    _portController.dispose();
    super.dispose();
  }

  Future<void> _initializeFreedome() async {
    final service = context.read<FreedomeIntegrationService>();
    if (!service.isInitialized) {
      setState(() {
        _isInitializing = true;
      });

      try {
        await service.initialize();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ошибка инициализации FreeDome: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isInitializing = false;
          });
        }
      }
    }
  }

  Future<void> _connectToFreedome() async {
    final service = context.read<FreedomeIntegrationService>();

    setState(() {
      _isConnecting = true;
    });

    try {
      final port = int.tryParse(_portController.text) ?? 8080;
      final success = await service.connect(
        serverUrl: _serverUrlController.text,
        port: port,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Успешное подключение к FreeDome системе'
                  : 'Не удалось подключиться к FreeDome системе',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка подключения: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isConnecting = false;
        });
      }
    }
  }

  Future<void> _disconnectFromFreedome() async {
    final service = context.read<FreedomeIntegrationService>();
    await service.disconnect();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Отключение от FreeDome системы'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _calibrateAudio() async {
    final service = context.read<FreedomeIntegrationService>();

    try {
      final result = await service.calibrateAudio();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Калибровка аудио: ${result.status}'),
            backgroundColor: result.success ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка калибровки аудио: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _calibrateVideo() async {
    final service = context.read<FreedomeIntegrationService>();

    try {
      final result = await service.calibrateVideo();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Калибровка видео: ${result.status}'),
            backgroundColor: result.success ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка калибровки видео: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FreeDome Интеграция'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<FreedomeIntegrationService>(
        builder: (context, service, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Статус системы
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Статус системы',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        _buildStatusRow('Инициализация', service.isInitialized),
                        _buildStatusRow('Подключение', service.isConnected),
                        _buildStatusRow(
                          'Статус подключения',
                          _getConnectionStatusText(service.connectionStatus),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Настройки подключения
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Настройки подключения',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _serverUrlController,
                          decoration: const InputDecoration(
                            labelText: 'URL сервера',
                            border: OutlineInputBorder(),
                          ),
                          enabled: !service.isConnected,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _portController,
                          decoration: const InputDecoration(
                            labelText: 'Порт',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          enabled: !service.isConnected,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed:
                                    (!service.isConnected &&
                                        !_isConnecting &&
                                        service.isInitialized)
                                    ? _connectToFreedome
                                    : null,
                                child: _isConnecting
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text('Подключиться'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: service.isConnected
                                    ? _disconnectFromFreedome
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Отключиться'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Калибровка
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Калибровка системы',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: service.isInitialized
                                    ? _calibrateAudio
                                    : null,
                                icon: const Icon(Icons.audiotrack),
                                label: const Text('Калибровать аудио'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: service.isInitialized
                                    ? _calibrateVideo
                                    : null,
                                icon: const Icon(Icons.videocam),
                                label: const Text('Калибровать видео'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Информация о системе
                if (service.isConnected)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Информация о системе',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          FutureBuilder<SystemStatus>(
                            future: service.getSystemStatus(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              if (snapshot.hasError) {
                                return Text(
                                  'Ошибка получения информации: ${snapshot.error}',
                                  style: TextStyle(color: Colors.red),
                                );
                              }

                              if (snapshot.hasData) {
                                final status = snapshot.data!;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Статус: ${status.isRunning ? "Активна" : "Неактивна"}',
                                    ),
                                    Text(
                                      'Активные сервисы: ${status.activeServices.join(", ")}',
                                    ),
                                    if (status.info.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Text('Дополнительная информация:'),
                                      ...status.info.entries.map(
                                        (entry) => Text(
                                          '  ${entry.key}: ${entry.value}',
                                        ),
                                      ),
                                    ],
                                  ],
                                );
                              }

                              return const Text('Нет данных');
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                // Инициализация
                if (_isInitializing)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(
                        child: Column(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Инициализация FreeDome...'),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor(value),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _getStatusText(value),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(dynamic value) {
    if (value is bool) {
      return value ? Colors.green : Colors.red;
    }
    if (value is String) {
      if (value.toLowerCase().contains('connected')) return Colors.green;
      if (value.toLowerCase().contains('error')) return Colors.red;
      return Colors.orange;
    }
    return Colors.grey;
  }

  String _getStatusText(dynamic value) {
    if (value is bool) {
      return value ? 'Да' : 'Нет';
    }
    if (value is String) {
      return value;
    }
    return value.toString();
  }

  String _getConnectionStatusText(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.connected:
        return 'Подключено';
      case ConnectionStatus.connecting:
        return 'Подключение...';
      case ConnectionStatus.disconnected:
        return 'Отключено';
      case ConnectionStatus.error:
        return 'Ошибка';
    }
  }
}
