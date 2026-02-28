import 'dart:async';
import 'package:flutter/foundation.dart';
import 'freedome_api_stubs.dart';
import 'exceptions/freedome_exceptions.dart';

/// Сервис для интеграции с экосистемой FreeDome
/// 
/// Provides comprehensive FreeDome integration with:
/// - Initialization management
/// - Connection handling
/// - Audio/Video calibration
/// - Device management
/// - System status monitoring
/// 
/// Error handling uses typed exceptions with bilingual messages
/// and recovery suggestions.
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
  /// 
  /// Initializes all FreeDome components: Core, Calibration, and Connectivity.
  /// Must be called before any other methods.
  /// 
  /// Throws:
  /// - [FreedomeInitializationFailedException] if initialization fails
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('⚠️ FreeDome уже инициализирован');
      return;
    }

    try {
      debugPrint('🔄 Инициализация FreeDome интеграции...');

      // Инициализация основного ядра
      debugPrint('🔧 Инициализация FreedomeCore...');
      _freedomeCore = FreedomeCore();
      await _freedomeCore!.initialize();

      // Инициализация калибровки
      debugPrint('🎯 Инициализация FreedomeCalibration...');
      _freedomeCalibration = FreedomeCalibration();
      await _freedomeCalibration!.initialize();

      // Инициализация подключения
      debugPrint('🔗 Инициализация FreedomeConnectivity...');
      _freedomeConnectivity = FreedomeConnectivity();
      await _freedomeConnectivity!.initialize();

      // Подписка на события подключения
      _freedomeConnectivity!.onConnectionStatusChanged.listen(
        _onConnectionStatusChanged,
      );

      _isInitialized = true;
      debugPrint('✅ FreeDome интеграция инициализирована успешно');
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('❌ Ошибка инициализации FreeDome: $e');
      debugPrint('Stack trace: $stackTrace');
      
      // Clean up partially initialized state
      _freedomeCore = null;
      _freedomeCalibration = null;
      _freedomeConnectivity = null;
      _isInitialized = false;
      
      throw FreedomeInitializationFailedException(
        component: 'FreeDome Integration',
        reason: e.toString(),
      );
    }
  }

  /// Подключение к системе FreeDome
  /// 
  /// Connects to the FreeDome system with specified server URL and port.
  /// 
  /// Params:
  /// - [serverUrl]: Server URL (default: 'localhost')
  /// - [port]: Server port (default: 8080)
  /// - [connectionOptions]: Additional connection options
  /// 
  /// Returns: true if connection successful, false otherwise
  /// 
  /// Throws:
  /// - [FreedomeNotInitializedException] if service not initialized
  /// - [FreedomeConnectionFailedException] if connection fails
  Future<bool> connect({
    String? serverUrl,
    int? port,
    Map<String, dynamic>? connectionOptions,
  }) async {
    if (!_isInitialized) {
      debugPrint('❌ Попытка подключения без инициализации');
      throw FreedomeNotInitializedException();
    }

    try {
      final url = serverUrl ?? 'localhost';
      final p = port ?? 8080;
      
      debugPrint('🔗 Подключение к FreeDome системе ($url:$p)...');

      final result = await _freedomeConnectivity!.connect(
        serverUrl: url,
        port: p,
        options: connectionOptions ?? {},
      );

      _isConnected = result;
      notifyListeners();

      if (_isConnected) {
        debugPrint('✅ Успешное подключение к FreeDome системе');
      } else {
        debugPrint('❌ Не удалось подключиться к FreeDome системе');
        throw FreedomeConnectionFailedException(
          serverUrl: url,
          port: p,
          reason: 'Connection returned false',
        );
      }

      return _isConnected;
    } on FreedomeException {
      // Re-throw our custom exceptions
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('❌ Ошибка подключения: $e');
      debugPrint('Stack trace: $stackTrace');
      
      throw FreedomeConnectionFailedException(
        serverUrl: serverUrl ?? 'localhost',
        port: port ?? 8080,
        reason: e.toString(),
      );
    }
  }

  /// Отключение от системы FreeDome
  /// 
  /// Disconnects from the FreeDome system and resets connection state.
  /// Safe to call even if not connected.
  Future<void> disconnect() async {
    if (_freedomeConnectivity != null) {
      debugPrint('🔌 Отключение от FreeDome системы...');
      await _freedomeConnectivity!.disconnect();
      _isConnected = false;
      _connectionStatus = ConnectionStatus.disconnected;
      debugPrint('✅ Отключение завершено');
      notifyListeners();
    }
  }

  /// Калибровка аудио системы
  /// 
  /// Performs audio calibration for optimal dome acoustics.
  /// 
  /// Params:
  /// - [audioDevices]: Specific devices to calibrate (null for all)
  /// - [calibrationOptions]: Additional calibration options
  /// 
  /// Returns: [CalibrationResult] with calibration metrics
  /// 
  /// Throws:
  /// - [FreedomeCalibrationNotInitializedException] if not initialized
  /// - [FreedomeCalibrationFailedException] if calibration fails
  Future<CalibrationResult> calibrateAudio({
    List<String>? audioDevices,
    Map<String, dynamic>? calibrationOptions,
  }) async {
    if (!_isInitialized || _freedomeCalibration == null) {
      debugPrint('❌ Попытка аудио калибровки без инициализации');
      throw FreedomeCalibrationNotInitializedException();
    }

    try {
      debugPrint('🎵 Начало калибровки аудио системы...');

      final result = await _freedomeCalibration!.calibrateAudio(
        devices: audioDevices,
        options: calibrationOptions ?? {},
      );

      if (!result.success) {
        debugPrint('❌ Калибровка аудио не удалась: ${result.error}');
        throw FreedomeCalibrationFailedException(
          type: 'audio',
          reason: result.error ?? 'Unknown error',
        );
      }

      debugPrint('✅ Калибровка аудио завершена: ${result.status}');
      return result;
    } on FreedomeException {
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('❌ Ошибка калибровки аудио: $e');
      debugPrint('Stack trace: $stackTrace');
      throw FreedomeCalibrationFailedException(
        type: 'audio',
        reason: e.toString(),
      );
    }
  }

  /// Калибровка видео системы
  /// 
  /// Performs video calibration for optimal dome projection.
  /// 
  /// Params:
  /// - [videoSettings]: Video settings to apply
  /// - [calibrationOptions]: Additional calibration options
  /// 
  /// Returns: [CalibrationResult] with calibration metrics
  /// 
  /// Throws:
  /// - [FreedomeCalibrationNotInitializedException] if not initialized
  /// - [FreedomeCalibrationFailedException] if calibration fails
  Future<CalibrationResult> calibrateVideo({
    Map<String, dynamic>? videoSettings,
    Map<String, dynamic>? calibrationOptions,
  }) async {
    if (!_isInitialized || _freedomeCalibration == null) {
      debugPrint('❌ Попытка видео калибровки без инициализации');
      throw FreedomeCalibrationNotInitializedException();
    }

    try {
      debugPrint('📹 Начало калибровки видео системы...');

      final result = await _freedomeCalibration!.calibrateVideo(
        settings: videoSettings ?? {},
        options: calibrationOptions ?? {},
      );

      if (!result.success) {
        debugPrint('❌ Калибровка видео не удалась: ${result.error}');
        throw FreedomeCalibrationFailedException(
          type: 'video',
          reason: result.error ?? 'Unknown error',
        );
      }

      debugPrint('✅ Калибровка видео завершена: ${result.status}');
      return result;
    } on FreedomeException {
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('❌ Ошибка калибровки видео: $e');
      debugPrint('Stack trace: $stackTrace');
      throw FreedomeCalibrationFailedException(
        type: 'video',
        reason: e.toString(),
      );
    }
  }

  /// Отправка данных в FreeDome систему
  /// 
  /// Sends data to the connected FreeDome system.
  /// 
  /// Params:
  /// - [data]: Map of data to send
  /// 
  /// Throws:
  /// - [FreedomeNotConnectedException] if not connected
  /// - [FreedomeDataSendFailedException] if sending fails
  Future<void> sendData(Map<String, dynamic> data) async {
    if (!_isConnected || _freedomeCore == null) {
      debugPrint('❌ Попытка отправки данных без подключения');
      throw FreedomeNotConnectedException();
    }

    try {
      await _freedomeCore!.sendData(data);
      debugPrint('📤 Данные отправлены в FreeDome систему');
    } on FreedomeException {
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('❌ Ошибка отправки данных: $e');
      debugPrint('Stack trace: $stackTrace');
      throw FreedomeDataSendFailedException(reason: e.toString());
    }
  }

  /// Получение статуса системы
  /// 
  /// Retrieves current system status from FreeDome.
  /// 
  /// Returns: [SystemStatus] with system information
  /// 
  /// Throws:
  /// - [FreedomeNotInitializedException] if not initialized
  /// - [FreedomeStatusRetrievalFailedException] if retrieval fails
  Future<SystemStatus> getSystemStatus() async {
    if (!_isInitialized || _freedomeCore == null) {
      debugPrint('❌ Попытка получения статуса без инициализации');
      throw FreedomeNotInitializedException();
    }

    try {
      return await _freedomeCore!.getSystemStatus();
    } on FreedomeException {
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('❌ Ошибка получения статуса системы: $e');
      debugPrint('Stack trace: $stackTrace');
      throw FreedomeStatusRetrievalFailedException(reason: e.toString());
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
  /// 
  /// Retrieves list of available audio/video devices.
  /// 
  /// Returns: List of [DeviceInfo] objects
  /// 
  /// Throws:
  /// - [FreedomeCalibrationNotInitializedException] if not initialized
  /// - [FreedomeNoDevicesFoundException] if no devices found
  Future<List<DeviceInfo>> getAvailableDevices() async {
    if (!_isInitialized || _freedomeCalibration == null) {
      debugPrint('❌ Попытка получения устройств без инициализации');
      throw FreedomeCalibrationNotInitializedException();
    }

    try {
      final devices = await _freedomeCalibration!.getAvailableDevices();
      
      if (devices.isEmpty) {
        debugPrint('⚠️ Устройства не найдены');
        throw FreedomeNoDevicesFoundException();
      }
      
      debugPrint('✅ Найдено устройств: ${devices.length}');
      return devices;
    } on FreedomeNoDevicesFoundException {
      rethrow;
    } on FreedomeException {
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('❌ Ошибка получения списка устройств: $e');
      debugPrint('Stack trace: $stackTrace');
      throw FreedomeNoDevicesFoundException();
    }
  }

  /// Освобождение ресурсов
  /// 
  /// Properly disposes all resources and closes connections.
  /// Should be called when service is no longer needed.
  /// 
  /// This method:
  /// 1. Disconnects from FreeDome system
  /// 2. Disposes connectivity stream controller
  /// 3. Nullifies all component references
  /// 4. Resets all state flags
  @override
  void dispose() {
    debugPrint('🧹 Освобождение ресурсов FreeDome...');
    
    // Отключение от системы
    disconnect();
    
    // Освобождение ресурсов подключения
    _freedomeConnectivity?.dispose();
    
    // Очистка ссылок
    _freedomeCore = null;
    _freedomeCalibration = null;
    _freedomeConnectivity = null;
    
    // Сброс флагов
    _isInitialized = false;
    _isConnected = false;
    _connectionStatus = ConnectionStatus.disconnected;
    
    debugPrint('✅ Ресурсы FreeDome освобождены');
    super.dispose();
  }

  /// Переподключение к системе
  /// 
  /// Attempts to reconnect to the FreeDome system.
  /// Useful for handling connection drops.
  /// 
  /// Params:
  /// - [maxRetries]: Maximum number of retry attempts (default: 3)
  /// - [retryDelayMs]: Delay between retries in milliseconds (default: 1000)
  /// 
  /// Returns: true if reconnection successful
  /// 
  /// Throws:
  /// - [FreedomeNotInitializedException] if not initialized
  Future<bool> reconnect({
    int maxRetries = 3,
    int retryDelayMs = 1000,
  }) async {
    if (!_isInitialized) {
      debugPrint('❌ Попытка переподключения без инициализации');
      throw FreedomeNotInitializedException();
    }

    debugPrint('🔄 Попытка переподключения (макс. $maxRetries попыток)...');

    // Отключение если подключено
    if (_isConnected) {
      await disconnect();
    }

    // Попытки подключения
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      debugPrint('🔄 Попытка ${attempt}/$maxRetries...');
      
      try {
        final result = await connect();
        if (result) {
          debugPrint('✅ Переподключение успешно с попытки $attempt');
          return true;
        }
      } catch (e) {
        debugPrint('⚠️ Попытка $attempt не удалась: $e');
      }

      if (attempt < maxRetries) {
        debugPrint('⏳ Пауза ${retryDelayMs}мс перед следующей попыткой...');
        await Future.delayed(Duration(milliseconds: retryDelayMs));
      }
    }

    debugPrint('❌ Все попытки переподключения исчерпаны');
    throw FreedomeConnectionFailedException(
      reason: 'Failed to reconnect after $maxRetries attempts',
    );
  }

  /// Проверка состояния сервиса
  /// 
  /// Returns current service state as a map for debugging.
  Map<String, dynamic> getServiceState() {
    return {
      'isInitialized': _isInitialized,
      'isConnected': _isConnected,
      'connectionStatus': _connectionStatus.name,
      'hasCore': _freedomeCore != null,
      'hasCalibration': _freedomeCalibration != null,
      'hasConnectivity': _freedomeConnectivity != null,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Валидация состояния сервиса
  /// 
  /// Validates that service is in correct state for operations.
  /// 
  /// Throws appropriate exception if validation fails.
  void _validateInitialized() {
    if (!_isInitialized) {
      debugPrint('❌ Сервис не инициализирован');
      throw FreedomeNotInitializedException();
    }
  }

  void _validateConnected() {
    if (!_isConnected) {
      debugPrint('❌ Сервис не подключен');
      throw FreedomeNotConnectedException();
    }
  }

