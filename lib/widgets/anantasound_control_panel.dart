import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/anantasound_service.dart';
import '../models/anantasound_device.dart';

/// Панель управления anAntaSound Quantum Resonance Device
class AnantaSoundControlPanel extends StatefulWidget {
  const AnantaSoundControlPanel({super.key});

  @override
  State<AnantaSoundControlPanel> createState() => _AnantaSoundControlPanelState();
}

class _AnantaSoundControlPanelState extends State<AnantaSoundControlPanel>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _rotationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AnantaSoundService>(
      builder: (context, service, child) {
        if (!service.isInitialized || service.device == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final device = service.device!;
        final status = service.status!;

        // Анимация в зависимости от статуса
        if (status.isActive) {
          _pulseController.repeat(reverse: true);
          _rotationController.repeat();
        } else {
          _pulseController.stop();
          _rotationController.stop();
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.deepPurple.withOpacity(0.1),
                Colors.indigo.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: status.isActive 
                  ? Colors.deepPurple.withOpacity(0.5)
                  : Colors.grey.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(device, status),
              const SizedBox(height: 16),
              _buildStatusIndicators(status),
              const SizedBox(height: 16),
              _buildControlButtons(service, status),
              const SizedBox(height: 16),
              _buildResonanceField(device.resonanceField),
              const SizedBox(height: 16),
              _buildConsciousnessField(device.consciousnessField),
              const SizedBox(height: 16),
              _buildConnectionStatus(service, status),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(AnantaSoundDevice device, DeviceStatus status) {
    return Row(
      children: [
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: status.isActive ? _pulseAnimation.value : 1.0,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: status.isActive
                        ? [
                            Colors.deepPurple.withOpacity(0.8),
                            Colors.indigo.withOpacity(0.4),
                          ]
                        : [
                            Colors.grey.withOpacity(0.3),
                            Colors.grey.withOpacity(0.1),
                          ],
                  ),
                  boxShadow: status.isActive
                      ? [
                          BoxShadow(
                            color: Colors.deepPurple.withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  Icons.radio_button_checked,
                  color: status.isActive ? Colors.white : Colors.grey,
                  size: 30,
                ),
              ),
            );
          },
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                device.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'ID: ${device.id}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                status.isActive ? 'Активно' : 'Неактивно',
                style: TextStyle(
                  fontSize: 14,
                  color: status.isActive ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusIndicators(DeviceStatus status) {
    return Row(
      children: [
        Expanded(
          child: _buildStatusCard(
            'Частота',
            '${status.currentFrequency.toStringAsFixed(1)} Гц',
            Icons.graphic_eq,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatusCard(
            'Интенсивность',
            '${(status.currentIntensity * 100).toStringAsFixed(0)}%',
            Icons.signal_cellular_alt,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatusCard(
            'Участники',
            '${status.connectedParticipants}',
            Icons.people,
            Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons(AnantaSoundService service, DeviceStatus status) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: status.isActive
                ? () => service.deactivateQuantumResonance()
                : () => service.activateQuantumResonance(),
            icon: Icon(status.isActive ? Icons.stop : Icons.play_arrow),
            label: Text(status.isActive ? 'Остановить' : 'Активировать'),
            style: ElevatedButton.styleFrom(
              backgroundColor: status.isActive ? Colors.red : Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _showSettingsDialog(service),
            icon: const Icon(Icons.settings),
            label: const Text('Настройки'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResonanceField(QuantumResonanceField field) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.purple.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Квантовое резонансное поле',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildFieldParameter('Частота', '${field.frequency.toStringAsFixed(1)} Гц'),
              ),
              Expanded(
                child: _buildFieldParameter('Интенсивность', '${(field.intensity * 100).toStringAsFixed(0)}%'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: _buildFieldParameter('Радиус', '${field.radius.toStringAsFixed(1)} м'),
              ),
              Expanded(
                child: _buildFieldParameter('Когерентность', '${field.coherenceTime.toStringAsFixed(0)} мс'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConsciousnessField(ConsciousnessField field) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.indigo.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.indigo.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Поле сознания',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildFieldParameter('Участники', '${field.participantWeights.length}'),
              ),
              Expanded(
                child: _buildFieldParameter('Когерентность', '${(field.coherenceRatio * 100).toStringAsFixed(1)}%'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: _buildFieldParameter('Радиус', '${field.radius.toStringAsFixed(1)} м'),
              ),
              Expanded(
                child: _buildFieldParameter('Частота', '${field.frequency.toStringAsFixed(2)} Гц'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFieldParameter(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildConnectionStatus(AnantaSoundService service, DeviceStatus status) {
    return Row(
      children: [
        Expanded(
          child: _buildConnectionButton(
            'MIDI',
            status.midiConnected,
            status.midiConnected
                ? () => service.disconnectMIDI()
                : () => service.connectMIDI(),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildConnectionButton(
            'OSC',
            status.oscConnected,
            status.oscConnected
                ? () => service.disconnectOSC()
                : () => service.connectOSC(),
          ),
        ),
      ],
    );
  }

  Widget _buildConnectionButton(String label, bool connected, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: connected ? Colors.green : Colors.grey,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            connected ? Icons.link : Icons.link_off,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
    );
  }

  void _showSettingsDialog(AnantaSoundService service) {
    showDialog(
      context: context,
      builder: (context) => AnantaSoundSettingsDialog(service: service),
    );
  }
}

/// Диалог настроек anAntaSound
class AnantaSoundSettingsDialog extends StatefulWidget {
  final AnantaSoundService service;

  const AnantaSoundSettingsDialog({
    super.key,
    required this.service,
  });

  @override
  State<AnantaSoundSettingsDialog> createState() => _AnantaSoundSettingsDialogState();
}

class _AnantaSoundSettingsDialogState extends State<AnantaSoundSettingsDialog> {
  late TextEditingController _frequencyController;
  late TextEditingController _intensityController;
  late TextEditingController _radiusController;

  @override
  void initState() {
    super.initState();
    final field = widget.service.device?.resonanceField;
    _frequencyController = TextEditingController(text: field?.frequency.toString() ?? '432.0');
    _intensityController = TextEditingController(text: field?.intensity.toString() ?? '0.5');
    _radiusController = TextEditingController(text: field?.radius.toString() ?? '5.0');
  }

  @override
  void dispose() {
    _frequencyController.dispose();
    _intensityController.dispose();
    _radiusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Настройки Quantum Resonance Device'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _frequencyController,
              decoration: const InputDecoration(
                labelText: 'Резонансная частота (Гц)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _intensityController,
              decoration: const InputDecoration(
                labelText: 'Интенсивность (0.0 - 1.0)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _radiusController,
              decoration: const InputDecoration(
                labelText: 'Радиус поля (м)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: _saveSettings,
          child: const Text('Сохранить'),
        ),
      ],
    );
  }

  void _saveSettings() {
    final frequency = double.tryParse(_frequencyController.text) ?? 432.0;
    final intensity = double.tryParse(_intensityController.text) ?? 0.5;
    final radius = double.tryParse(_radiusController.text) ?? 5.0;

    final currentField = widget.service.device?.resonanceField;
    if (currentField != null) {
      final updatedField = QuantumResonanceField(
        frequency: frequency,
        intensity: intensity,
        radius: radius,
        center: currentField.center,
        quantumPhase: currentField.quantumPhase,
        coherenceTime: currentField.coherenceTime,
      );

      widget.service.updateResonanceField(updatedField);
    }

    Navigator.of(context).pop();
  }
}

