import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/anantasound_device.dart';

/// Сервис для управления anAntaSound Quantum Resonance Device
class AnantaSoundService extends ChangeNotifier {
  static const String _deviceKey = 'anantasound_device';
  
  AnantaSoundDevice? _device;
  DeviceStatus? _status;
  Timer? _statusTimer;
  bool _isInitialized = false;
  
  // Потоки для реального времени
  final StreamController<DeviceStatus> _statusController = 
      StreamController<DeviceStatus>.broadcast();
  final StreamController<QuantumResonanceField> _resonanceController = 
      StreamController<QuantumResonanceField>.broadcast();
  final StreamController<ConsciousnessField> _consciousnessController = 
      StreamController<ConsciousnessField>.broadcast();

  AnantaSoundDevice? get device => _device;
  DeviceStatus? get status => _status;
  bool get isInitialized => _isInitialized;
  
  Stream<DeviceStatus> get statusStream => _statusController.stream;
  Stream<QuantumResonanceField> get resonanceStream => _resonanceController.stream;
  Stream<ConsciousnessField> get consciousnessStream => _consciousnessController.stream;

  /// Инициализация сервиса
  Future<bool> initialize() async {
    try {
      await _loadDeviceFromStorage();
      if (_device == null) {
        await _createDefaultDevice();
      }
      _isInitialized = true;
      _startStatusMonitoring();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Ошибка инициализации AnantaSound: $e');
      return false;
    }
  }

  /// Создание устройства по умолчанию
  Future<void> _createDefaultDevice() async {
    final defaultResonanceField = QuantumResonanceField(
      frequency: 432.0, // Гц
      intensity: 0.5,
      radius: 5.0, // метры
      center: const SphericalCoord(
        r: 0.0,
        theta: pi / 2,
        phi: 0.0,
        height: 1.5,
      ),
      quantumPhase: 0.0,
      coherenceTime: 1000.0, // мс
    );

    final defaultConsciousnessField = ConsciousnessField(
      radius: 10.0,
      intensity: 0.3,
      frequency: 7.83, // Шумановская резонансная частота
      participantWeights: [],
      participantPositions: [],
      coherenceRatio: 0.0,
    );

    final defaultResonatorSettings = MechanicalResonatorSettings(
      resonantFrequency: 440.0,
      amplitude: 0.7,
      dampingCoefficient: 0.1,
      material: 'Кварц',
      temperature: 20.0,
    );

    _device = AnantaSoundDevice(
      id: 'anantasound_001',
      name: 'Quantum Resonance Device',
      status: DeviceStatus(
        isActive: false,
        consciousnessConnected: false,
        connectedParticipants: 0,
        currentFrequency: 432.0,
        currentIntensity: 0.0,
        midiConnected: false,
        oscConnected: false,
      ),
      resonanceField: defaultResonanceField,
      consciousnessField: defaultConsciousnessField,
      resonatorSettings: defaultResonatorSettings,
      midiConfig: const MIDIConfig(),
      oscConfig: const OSCConfig(),
    );

    _status = _device!.status;
    await _saveDeviceToStorage();
  }

  /// Загрузка устройства из хранилища
  Future<void> _loadDeviceFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final deviceJson = prefs.getString(_deviceKey);
      if (deviceJson != null) {
        final deviceMap = jsonDecode(deviceJson) as Map<String, dynamic>;
        _device = AnantaSoundDevice.fromJson(deviceMap);
        _status = _device!.status;
      }
    } catch (e) {
      debugPrint('Ошибка загрузки устройства: $e');
    }
  }

  /// Сохранение устройства в хранилище
  Future<void> _saveDeviceToStorage() async {
    if (_device == null) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final deviceJson = jsonEncode(_device!.toJson());
      await prefs.setString(_deviceKey, deviceJson);
    } catch (e) {
      debugPrint('Ошибка сохранения устройства: $e');
    }
  }

  /// Активация квантового резонанса
  Future<bool> activateQuantumResonance() async {
    if (_device == null) return false;

    try {
      _device = _device!.copyWith(
        status: _device!.status.copyWith(
          isActive: true,
          currentIntensity: _device!.resonanceField.intensity,
        ),
      );
      _status = _device!.status;
      await _saveDeviceToStorage();
      _statusController.add(_status!);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Ошибка активации резонанса: $e');
      return false;
    }
  }

  /// Деактивация квантового резонанса
  Future<void> deactivateQuantumResonance() async {
    if (_device == null) return;

    try {
      _device = _device!.copyWith(
        status: _device!.status.copyWith(
          isActive: false,
          currentIntensity: 0.0,
        ),
      );
      _status = _device!.status;
      await _saveDeviceToStorage();
      _statusController.add(_status!);
      notifyListeners();
    } catch (e) {
      debugPrint('Ошибка деактивации резонанса: $e');
    }
  }

  /// Создание поля сознания
  Future<bool> createConsciousnessField(ConsciousnessField field) async {
    if (_device == null) return false;

    try {
      _device = _device!.copyWith(consciousnessField: field);
      await _saveDeviceToStorage();
      _consciousnessController.add(field);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Ошибка создания поля сознания: $e');
      return false;
    }
  }

  /// Настройка MIDI интерфейса
  Future<bool> configureMIDI(MIDIConfig config) async {
    if (_device == null) return false;

    try {
      _device = _device!.copyWith(midiConfig: config);
      await _saveDeviceToStorage();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Ошибка настройки MIDI: $e');
      return false;
    }
  }

  /// Настройка OSC интерфейса
  Future<bool> configureOSC(OSCConfig config) async {
    if (_device == null) return false;

    try {
      _device = _device!.copyWith(oscConfig: config);
      await _saveDeviceToStorage();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Ошибка настройки OSC: $e');
      return false;
    }
  }

  /// Отправка MIDI сообщения
  Future<bool> sendMIDI(MIDIMessage message) async {
    if (_device == null || !_device!.status.midiConnected) return false;

    try {
      // Симуляция отправки MIDI сообщения
      debugPrint('Отправка MIDI: ${message.toJson()}');
      return true;
    } catch (e) {
      debugPrint('Ошибка отправки MIDI: $e');
      return false;
    }
  }

  /// Отправка OSC сообщения
  Future<bool> sendOSC(OSCMessage message) async {
    if (_device == null || !_device!.status.oscConnected) return false;

    try {
      // Симуляция отправки OSC сообщения
      debugPrint('Отправка OSC: ${message.toJson()}');
      return true;
    } catch (e) {
      debugPrint('Ошибка отправки OSC: $e');
      return false;
    }
  }

  /// Обновление резонансного поля
  Future<void> updateResonanceField(QuantumResonanceField field) async {
    if (_device == null) return;

    try {
      _device = _device!.copyWith(resonanceField: field);
      await _saveDeviceToStorage();
      _resonanceController.add(field);
      notifyListeners();
    } catch (e) {
      debugPrint('Ошибка обновления резонансного поля: $e');
    }
  }

  /// Добавление участника в поле сознания
  Future<void> addParticipant(SphericalCoord position, double weight) async {
    if (_device == null) return;

    try {
      final currentField = _device!.consciousnessField;
      final newWeights = List<double>.from(currentField.participantWeights)..add(weight);
      final newPositions = List<SphericalCoord>.from(currentField.participantPositions)..add(position);

      final updatedField = ConsciousnessField(
        radius: currentField.radius,
        intensity: currentField.intensity,
        frequency: currentField.frequency,
        participantWeights: newWeights,
        participantPositions: newPositions,
        coherenceRatio: _calculateCoherenceRatio(newWeights),
      );

      _device = _device!.copyWith(
        consciousnessField: updatedField,
        status: _device!.status.copyWith(
          connectedParticipants: newWeights.length,
          consciousnessConnected: newWeights.isNotEmpty,
        ),
      );
      _status = _device!.status;
      await _saveDeviceToStorage();
      _consciousnessController.add(updatedField);
      _statusController.add(_status!);
      notifyListeners();
    } catch (e) {
      debugPrint('Ошибка добавления участника: $e');
    }
  }

  /// Удаление участника из поля сознания
  Future<void> removeParticipant(int index) async {
    if (_device == null || index < 0 || index >= _device!.consciousnessField.participantWeights.length) return;

    try {
      final currentField = _device!.consciousnessField;
      final newWeights = List<double>.from(currentField.participantWeights)..removeAt(index);
      final newPositions = List<SphericalCoord>.from(currentField.participantPositions)..removeAt(index);

      final updatedField = ConsciousnessField(
        radius: currentField.radius,
        intensity: currentField.intensity,
        frequency: currentField.frequency,
        participantWeights: newWeights,
        participantPositions: newPositions,
        coherenceRatio: _calculateCoherenceRatio(newWeights),
      );

      _device = _device!.copyWith(
        consciousnessField: updatedField,
        status: _device!.status.copyWith(
          connectedParticipants: newWeights.length,
          consciousnessConnected: newWeights.isNotEmpty,
        ),
      );
      _status = _device!.status;
      await _saveDeviceToStorage();
      _consciousnessController.add(updatedField);
      _statusController.add(_status!);
      notifyListeners();
    } catch (e) {
      debugPrint('Ошибка удаления участника: $e');
    }
  }

  /// Расчет коэффициента когерентности
  double _calculateCoherenceRatio(List<double> weights) {
    if (weights.isEmpty) return 0.0;
    
    final mean = weights.reduce((a, b) => a + b) / weights.length;
    final variance = weights.map((w) => pow(w - mean, 2)).reduce((a, b) => a + b) / weights.length;
    final standardDeviation = sqrt(variance);
    
    // Коэффициент когерентности как обратная величина стандартного отклонения
    return standardDeviation > 0 ? 1.0 / (1.0 + standardDeviation) : 1.0;
  }

  /// Запуск мониторинга статуса
  void _startStatusMonitoring() {
    _statusTimer?.cancel();
    _statusTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateStatus();
    });
  }

  /// Обновление статуса устройства
  void _updateStatus() {
    if (_device == null) return;

    // Симуляция изменений статуса
    final random = Random();
    final currentStatus = _device!.status;
    
    final updatedStatus = currentStatus.copyWith(
      currentFrequency: currentStatus.currentFrequency + (random.nextDouble() - 0.5) * 10,
      currentIntensity: currentStatus.isActive 
          ? (currentStatus.currentIntensity + (random.nextDouble() - 0.5) * 0.1).clamp(0.0, 1.0)
          : 0.0,
    );

    _device = _device!.copyWith(status: updatedStatus);
    _status = updatedStatus;
    _statusController.add(_status!);
    notifyListeners();
  }

  /// Подключение MIDI
  Future<bool> connectMIDI() async {
    if (_device == null) return false;

    try {
      _device = _device!.copyWith(
        status: _device!.status.copyWith(midiConnected: true),
      );
      _status = _device!.status;
      await _saveDeviceToStorage();
      _statusController.add(_status!);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Ошибка подключения MIDI: $e');
      return false;
    }
  }

  /// Отключение MIDI
  Future<void> disconnectMIDI() async {
    if (_device == null) return;

    try {
      _device = _device!.copyWith(
        status: _device!.status.copyWith(midiConnected: false),
      );
      _status = _device!.status;
      await _saveDeviceToStorage();
      _statusController.add(_status!);
      notifyListeners();
    } catch (e) {
      debugPrint('Ошибка отключения MIDI: $e');
    }
  }

  /// Подключение OSC
  Future<bool> connectOSC() async {
    if (_device == null) return false;

    try {
      _device = _device!.copyWith(
        status: _device!.status.copyWith(oscConnected: true),
      );
      _status = _device!.status;
      await _saveDeviceToStorage();
      _statusController.add(_status!);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Ошибка подключения OSC: $e');
      return false;
    }
  }

  /// Отключение OSC
  Future<void> disconnectOSC() async {
    if (_device == null) return;

    try {
      _device = _device!.copyWith(
        status: _device!.status.copyWith(oscConnected: false),
      );
      _status = _device!.status;
      await _saveDeviceToStorage();
      _statusController.add(_status!);
      notifyListeners();
    } catch (e) {
      debugPrint('Ошибка отключения OSC: $e');
    }
  }

  /// Получение текущего статуса
  DeviceStatus? getCurrentStatus() => _status;

  /// Проверка активности устройства
  bool isActive() => _status?.isActive ?? false;

  @override
  void dispose() {
    _statusTimer?.cancel();
    _statusController.close();
    _resonanceController.close();
    _consciousnessController.close();
    super.dispose();
  }
}

/// Расширение для DeviceStatus
extension DeviceStatusExtension on DeviceStatus {
  DeviceStatus copyWith({
    bool? isActive,
    bool? consciousnessConnected,
    int? connectedParticipants,
    double? currentFrequency,
    double? currentIntensity,
    bool? midiConnected,
    bool? oscConnected,
  }) {
    return DeviceStatus(
      isActive: isActive ?? this.isActive,
      consciousnessConnected: consciousnessConnected ?? this.consciousnessConnected,
      connectedParticipants: connectedParticipants ?? this.connectedParticipants,
      currentFrequency: currentFrequency ?? this.currentFrequency,
      currentIntensity: currentIntensity ?? this.currentIntensity,
      midiConnected: midiConnected ?? this.midiConnected,
      oscConnected: oscConnected ?? this.oscConnected,
    );
  }
}

