import 'dart:async';
import 'package:flutter/foundation.dart';
import 'freedome_api_stubs.dart';

/// Сервис для интеграции с экосистемой FreeDome
class FreedomeIntegrationService extends ChangeNotifier {
  FreedomeCore? _freedomeCore;
  FreedomeCalibration? _freedomeCalibration;
  FreedomeConnectivity? _freedomeConnectivity;

  bool _isInitialized = false;
  bool _isConnected = false;
  ConnectionStatus _connectionStatus = ConnectionStatus.disconnected;

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isConnected => _isConnected;
  ConnectionStatus get connectionStatus => _connectionStatus;
  FreedomeCore? get freedomeCore => _freedomeCore;
  FreedomeCalibration? get freedomeCalibration => _freedomeCalibration;
  FreedomeConnectivity? get freedomeConnectivity => _freedomeConnectivity;

  /// Инициализация всех компонентов FreeDome
  Future<void> initialize() async {
    try {
      print('🔄 Инициализация FreeDome интеграции...');

      // Инициализация основного ядра
      _freedomeCore = FreedomeCore();
      await _freedomeCore!.initialize();

      // Инициализация калибровки
      _freedomeCalibration = FreedomeCalibration();
      await _freedomeCalibration!.initialize();

      // Инициализация подключения
      _freedomeConnectivity = FreedomeConnectivity();
      await _freedomeConnectivity!.initialize();

        // Подписка на события подключения
        _freedomeConnectivity!.onConnectionStatusChanged.listen(
          (status) => _onConnectionStatusChanged(status),
        );

      _isInitialized = true;
      notifyListeners();

      print('✅ FreeDome интеграция инициализирована успешно');
    } catch (e) {
      print('❌ Ошибка инициализации FreeDome: $e');
      rethrow;
    }
  }

  /// Подключение к системе FreeDome
  Future<bool> connect({
    String? serverUrl,
    int? port,
    Map<String, dynamic>? connectionOptions,
  }) async {
    if (!_isInitialized) {
      throw Exception(
        'FreeDome не инициализирован. Вызовите initialize() сначала.',
      );
    }

    try {
      print('🔗 Подключение к FreeDome системе...');

      final result = await _freedomeConnectivity!.connect(
        serverUrl: serverUrl ?? 'localhost',
        port: port ?? 8080,
        options: connectionOptions ?? {},
      );

      _isConnected = result;
      notifyListeners();

      if (_isConnected) {
        print('✅ Успешное подключение к FreeDome системе');
      } else {
        print('❌ Не удалось подключиться к FreeDome системе');
      }

      return _isConnected;
    } catch (e) {
      print('❌ Ошибка подключения: $e');
      return false;
    }
  }

  /// Отключение от системы FreeDome
  Future<void> disconnect() async {
    if (_freedomeConnectivity != null) {
      await _freedomeConnectivity!.disconnect();
      _isConnected = false;
      _connectionStatus = ConnectionStatus.disconnected;
      notifyListeners();
      print('🔌 Отключение от FreeDome системы');
    }
  }

  /// Калибровка аудио системы
  Future<CalibrationResult> calibrateAudio({
    List<String>? audioDevices,
    Map<String, dynamic>? calibrationOptions,
  }) async {
    if (!_isInitialized || _freedomeCalibration == null) {
      throw Exception('FreeDome калибровка не инициализирована');
    }

    try {
      print('🎵 Начало калибровки аудио системы...');

      final result = await _freedomeCalibration!.calibrateAudio(
        devices: audioDevices,
        options: calibrationOptions ?? {},
      );

      print('✅ Калибровка аудио завершена: ${result.status}');
      return result;
    } catch (e) {
      print('❌ Ошибка калибровки аудио: $e');
      rethrow;
    }
  }

  /// Калибровка видео системы
  Future<CalibrationResult> calibrateVideo({
    Map<String, dynamic>? videoSettings,
    Map<String, dynamic>? calibrationOptions,
  }) async {
    if (!_isInitialized || _freedomeCalibration == null) {
      throw Exception('FreeDome калибровка не инициализирована');
    }

    try {
      print('📹 Начало калибровки видео системы...');

      final result = await _freedomeCalibration!.calibrateVideo(
        settings: videoSettings ?? {},
        options: calibrationOptions ?? {},
      );

      print('✅ Калибровка видео завершена: ${result.status}');
      return result;
    } catch (e) {
      print('❌ Ошибка калибровки видео: $e');
      rethrow;
    }
  }

  /// Отправка данных в FreeDome систему
  Future<void> sendData(Map<String, dynamic> data) async {
    if (!_isConnected || _freedomeCore == null) {
      throw Exception('FreeDome не подключен или не инициализирован');
    }

    try {
      await _freedomeCore!.sendData(data);
      print('📤 Данные отправлены в FreeDome систему');
    } catch (e) {
      print('❌ Ошибка отправки данных: $e');
      rethrow;
    }
  }

  /// Получение статуса системы
  Future<SystemStatus> getSystemStatus() async {
    if (!_isInitialized || _freedomeCore == null) {
      throw Exception('FreeDome не инициализирован');
    }

    try {
      return await _freedomeCore!.getSystemStatus();
    } catch (e) {
      print('❌ Ошибка получения статуса системы: $e');
      rethrow;
    }
  }

  /// Обработчик изменения статуса подключения
  void _onConnectionStatusChanged(ConnectionStatus status) {
    _connectionStatus = status;
    _isConnected = status == ConnectionStatus.connected;
    notifyListeners();

    switch (status) {
      case ConnectionStatus.connected:
        print('✅ Подключено к FreeDome системе');
        break;
      case ConnectionStatus.connecting:
        print('🔄 Подключение к FreeDome системе...');
        break;
      case ConnectionStatus.disconnected:
        print('🔌 Отключено от FreeDome системы');
        break;
      case ConnectionStatus.error:
        print('❌ Ошибка подключения к FreeDome системе');
        break;
    }
  }

  /// Получение информации о доступных устройствах
  Future<List<DeviceInfo>> getAvailableDevices() async {
    if (!_isInitialized || _freedomeCalibration == null) {
      throw Exception('FreeDome калибровка не инициализирована');
    }

    try {
      return await _freedomeCalibration!.getAvailableDevices();
    } catch (e) {
      print('❌ Ошибка получения списка устройств: $e');
      rethrow;
    }
  }

  /// Освобождение ресурсов
  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}

