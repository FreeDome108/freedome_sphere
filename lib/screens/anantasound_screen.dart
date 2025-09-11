import 'dart:async';
import 'dart:math';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../services/anantasound_service.dart';
import '../widgets/anantasound_control_panel.dart';
import '../models/anantasound_device.dart';

class AnantaSoundScreen extends StatefulWidget {
  const AnantaSoundScreen({super.key});

  @override
  State<AnantaSoundScreen> createState() => _AnantaSoundScreenState();
}

class _AnantaSoundScreenState extends State<AnantaSoundScreen>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late Animation<Color?> _backgroundAnimation;
  late StreamSubscription<DeviceStatus>? _statusSubscription;
  late StreamSubscription<QuantumResonanceField>? _resonanceSubscription;
  late StreamSubscription<ConsciousnessField>? _consciousnessSubscription;

  @override
  void initState() {
    super.initState();
    
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _backgroundAnimation = ColorTween(
      begin: Colors.deepPurple.withOpacity(0.1),
      end: Colors.indigo.withOpacity(0.2),
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOut,
    ));

    _backgroundController.repeat(reverse: true);
    
    _initializeService();
  }

  Future<void> _initializeService() async {
    final service = Provider.of<AnantaSoundService>(context, listen: false);
    await service.initialize();
    
    _statusSubscription = service.statusStream.listen((status) {
      if (mounted) {
        setState(() {});
      }
    });
    
    _resonanceSubscription = service.resonanceStream.listen((field) {
      if (mounted) {
        setState(() {});
      }
    });
    
    _consciousnessSubscription = service.consciousnessStream.listen((field) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _statusSubscription?.cancel();
    _resonanceSubscription?.cancel();
    _consciousnessSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.anantaSoundScreenTitle),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Consumer<AnantaSoundService>(
            builder: (context, service, child) {
              final status = service.status;
              return Container(
                margin: const EdgeInsets.only(right: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      status?.isActive == true ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                      color: status?.isActive == true ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      status?.isActive == true ? l10n.active : l10n.inactive,
                      style: TextStyle(
                        color: status?.isActive == true ? Colors.green : Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _backgroundAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _backgroundAnimation.value ?? Colors.deepPurple.withOpacity(0.1),
                  Colors.black.withOpacity(0.05),
                ],
              ),
            ),
            child: Consumer<AnantaSoundService>(
              builder: (context, service, child) {
                if (!service.isInitialized) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(l10n.initializingQuantumResonanceDevice),
                      ],
                    ),
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildQuantumVisualization(service),
                      const SizedBox(height: 24),
                      _buildMp3Loader(service, l10n),
                      const SizedBox(height: 24),
                      const AnantaSoundControlPanel(),
                      const SizedBox(height: 24),
                      _buildParticipantManagement(service, l10n),
                      const SizedBox(height: 24),
                      _buildRealTimeData(service, l10n),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildMp3Loader(AnantaSoundService service, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.indigo.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.mp3Management,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    FilePickerResult? result = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['mp3'],
                    );

                    if (result != null) {
                      service.loadMp3(result.files.single.path!);
                    }
                  },
                  icon: const Icon(Icons.music_note),
                  label: Text(l10n.loadMp3),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (service.device?.mp3FilePath != null)
            Text(
              l10n.loadedFile(service.device!.mp3FilePath!.split('/').last),
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
        ],
      ),
    );
  }

  Widget _buildQuantumVisualization(AnantaSoundService service) {
    final status = service.status;
    final device = service.device;
    
    if (device == null) return const SizedBox.shrink();

    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: status?.isActive == true 
              ? Colors.deepPurple.withOpacity(0.5)
              : Colors.grey.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: CustomPaint(
          painter: QuantumVisualizationPainter(
            status: status,
            resonanceField: device.resonanceField,
            consciousnessField: device.consciousnessField,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }

  Widget _buildParticipantManagement(AnantaSoundService service, AppLocalizations l10n) {
    final consciousnessField = service.device?.consciousnessField;
    if (consciousnessField == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.indigo.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.participantManagement,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _addRandomParticipant(service),
                  icon: const Icon(Icons.person_add),
                  label: Text(l10n.addParticipant),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: consciousnessField.participantWeights.isNotEmpty
                      ? () => _removeLastParticipant(service)
                      : null,
                  icon: const Icon(Icons.person_remove),
                  label: Text(l10n.removeParticipant),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (consciousnessField.participantWeights.isNotEmpty)
            _buildParticipantsList(consciousnessField, l10n),
        ],
      ),
    );
  }

  Widget _buildParticipantsList(ConsciousnessField field, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.activeParticipants,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 200),
          child: SingleChildScrollView(
            child: Column(
              children: List.generate(field.participantWeights.length, (index) {
                final weight = field.participantWeights[index];
                final position = field.participantPositions[index];
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.indigo.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.indigo.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.indigo,
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.participant(index + 1),
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              l10n.participantDetails(
                                weight.toStringAsFixed(2),
                                position.r.toStringAsFixed(1),
                                position.theta.toStringAsFixed(1),
                                position.phi.toStringAsFixed(1),
                              ),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRealTimeData(AnantaSoundService service, AppLocalizations l10n) {
    final status = service.status;
    if (status == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.realTimeData,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDataCard(
                  l10n.frequency,
                  l10n.hzUnit(status.currentFrequency.toStringAsFixed(1)),
                  Icons.graphic_eq,
                  Colors.blue,
                  l10n
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDataCard(
                  l10n.intensity,
                  l10n.percentageUnit((status.currentIntensity * 100).toStringAsFixed(0)),
                  Icons.signal_cellular_alt,
                  Colors.orange,
                  l10n
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildDataCard(
                  l10n.participants,
                  '${status.connectedParticipants}',
                  Icons.people,
                  Colors.green,
                  l10n
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDataCard(
                  l10n.midi,
                  status.midiConnected ? l10n.connected : l10n.disconnected,
                  Icons.music_note,
                  status.midiConnected ? Colors.green : Colors.red,
                  l10n
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildDataCard(
                  l10n.osc,
                  status.oscConnected ? l10n.connected : l10n.disconnected,
                  Icons.network_check,
                  status.oscConnected ? Colors.green : Colors.red,
                  l10n
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDataCard(
                  l10n.consciousness,
                  status.consciousnessConnected ? l10n.linked : l10n.notLinked,
                  Icons.psychology,
                  status.consciousnessConnected ? Colors.purple : Colors.grey,
                  l10n
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDataCard(String title, String value, IconData icon, Color color, AppLocalizations l10n) {
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
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _addRandomParticipant(AnantaSoundService service) {
    final random = Random();
    final position = SphericalCoord(
      r: random.nextDouble() * 5.0,
      theta: random.nextDouble() * pi,
      phi: random.nextDouble() * 2 * pi,
      height: random.nextDouble() * 3.0,
    );
    final weight = random.nextDouble();
    
    service.addParticipant(position, weight);
  }

  void _removeLastParticipant(AnantaSoundService service) {
    final field = service.device?.consciousnessField;
    if (field != null && field.participantWeights.isNotEmpty) {
      service.removeParticipant(field.participantWeights.length - 1);
    }
  }

}

class QuantumVisualizationPainter extends CustomPainter {
  final DeviceStatus? status;
  final QuantumResonanceField resonanceField;
  final ConsciousnessField consciousnessField;

  QuantumVisualizationPainter({
    required this.status,
    required this.resonanceField,
    required this.consciousnessField,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.3;

    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..style = PaintingStyle.fill;
    
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);

    if (status?.isActive == true) {
      final resonancePaint = Paint()
        ..color = Colors.deepPurple.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      
      canvas.drawCircle(center, radius, resonancePaint);
      
      for (int i = 1; i <= 3; i++) {
        final wavePaint = Paint()
          ..color = Colors.deepPurple.withOpacity(0.1 / i)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;
        
        canvas.drawCircle(center, radius * i, wavePaint);
      }
    }

    for (int i = 0; i < consciousnessField.participantPositions.length; i++) {
      final position = consciousnessField.participantPositions[i];
      final weight = consciousnessField.participantWeights[i];
      
      final x = center.dx + position.r * cos(position.phi) * sin(position.theta) * radius / 5.0;
      final y = center.dy + position.r * sin(position.phi) * sin(position.theta) * radius / 5.0;
      
      final participantPaint = Paint()
        ..color = Colors.indigo.withOpacity(0.7)
        ..style = PaintingStyle.fill;
      
      final participantRadius = 8.0 + weight * 8.0;
      canvas.drawCircle(Offset(x, y), participantRadius, participantPaint);
      
      if (i > 0) {
        final prevPosition = consciousnessField.participantPositions[i - 1];
        final prevX = center.dx + prevPosition.r * cos(prevPosition.phi) * sin(prevPosition.theta) * radius / 5.0;
        final prevY = center.dy + prevPosition.r * sin(prevPosition.phi) * sin(prevPosition.theta) * radius / 5.0;
        
        final connectionPaint = Paint()
          ..color = Colors.indigo.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;
        
        canvas.drawLine(Offset(prevX, prevY), Offset(x, y), connectionPaint);
      }
    }

    final centerPaint = Paint()
      ..color = status?.isActive == true ? Colors.deepPurple : Colors.grey
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, 6, centerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
