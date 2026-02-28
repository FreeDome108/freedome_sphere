/// Исключения для FreeDome Integration Service
/// Exceptions for FreeDome Integration Service
///
/// Provides type-safe error handling with bilingual messages and error codes.

/// Base exception for all FreeDome-related errors
/// Базовое исключение для всех ошибок FreeDome
class FreedomeException implements Exception {
  final String code;
  final String messageRu;
  final String messageEn;
  final String? details;
  final List<String> recoveryStepsRu;
  final List<String> recoveryStepsEn;

  const FreedomeException({
    required this.code,
    required this.messageRu,
    required this.messageEn,
    this.details,
    this.recoveryStepsRu = const [],
    this.recoveryStepsEn = const [],
  });

  /// Get message in Russian
  String get messageRu => messageRu;

  /// Get message in English
  String get messageEn => messageEn;

  /// Get recovery steps in Russian
  List<String> get recoveryStepsRu => recoveryStepsRu;

  /// Get recovery steps in English
  List<String> get recoveryStepsEn => recoveryStepsEn;

  @override
  String toString() {
    return 'FreedomeException($code): $messageEn';
  }
}

/// Thrown when FreeDome is not initialized
/// Выбрасывается когда FreeDome не инициализирован
class FreedomeNotInitializedException extends FreedomeException {
  FreedomeNotInitializedException()
      : super(
          code: 'NOT_INITIALIZED',
          messageRu: 'FreeDome не инициализирован. Вызовите initialize() сначала.',
          messageEn: 'FreeDome is not initialized. Call initialize() first.',
          recoveryStepsRu: [
            'Вызовите initialize() перед другими методами',
            'Проверьте, что сервис создан корректно',
            'Убедитесь, что нет ошибок инициализации',
          ],
          recoveryStepsEn: [
            'Call initialize() before other methods',
            'Check that the service is created correctly',
            'Ensure there are no initialization errors',
          ],
        );
}

/// Thrown when FreeDome is not connected
/// Выбрасывается когда FreeDome не подключен
class FreedomeNotConnectedException extends FreedomeException {
  FreedomeNotConnectedException()
      : super(
          code: 'NOT_CONNECTED',
          messageRu: 'FreeDome не подключен. Вызовите connect() сначала.',
          messageEn: 'FreeDome is not connected. Call connect() first.',
          recoveryStepsRu: [
            'Вызовите connect() с параметрами сервера',
            'Проверьте, что сервер доступен',
            'Убедитесь, что инициализация прошла успешно',
          ],
          recoveryStepsEn: [
            'Call connect() with server parameters',
            'Check that the server is available',
            'Ensure initialization was successful',
          ],
        );
}

/// Thrown when calibration is not initialized
/// Выбрасывается когда калибровка не инициализирована
class FreedomeCalibrationNotInitializedException extends FreedomeException {
  FreedomeCalibrationNotInitializedException()
      : super(
          code: 'CALIBRATION_NOT_INITIALIZED',
          messageRu: 'FreeDome калибровка не инициализирована',
          messageEn: 'FreeDome calibration is not initialized',
          recoveryStepsRu: [
            'Вызовите initialize() перед калибровкой',
            'Проверьте, что сервис инициализирован корректно',
          ],
          recoveryStepsEn: [
            'Call initialize() before calibration',
            'Check that the service is initialized correctly',
          ],
        );
}

/// Thrown when connection fails
/// Выбрасывается при ошибке подключения
class FreedomeConnectionFailedException extends FreedomeException {
  FreedomeConnectionFailedException({
    String? serverUrl,
    int? port,
    String? reason,
  }) : super(
          code: 'CONNECTION_FAILED',
          messageRu: 'Не удалось подключиться к FreeDome системе${serverUrl != null ? ' ($serverUrl:$port)' : ''}${reason != null ? ': $reason' : ''}',
          messageEn: 'Failed to connect to FreeDome system${serverUrl != null ? ' ($serverUrl:$port)' : ''}${reason != null ? ': $reason' : ''}',
          recoveryStepsRu: [
            'Проверьте, что сервер запущен',
            'Убедитесь, что URL и порт указаны верно',
            'Проверьте сетевое подключение',
            'Убедитесь, что брандмауэр не блокирует соединение',
          ],
          recoveryStepsEn: [
            'Check that the server is running',
            'Ensure URL and port are correct',
            'Check network connection',
            'Ensure firewall is not blocking the connection',
          ],
        );
}

/// Thrown when calibration fails
/// Выбрасывается при ошибке калибровки
class FreedomeCalibrationFailedException extends FreedomeException {
  FreedomeCalibrationFailedException({
    String? type, // 'audio' or 'video'
    String? reason,
  }) : super(
          code: 'CALIBRATION_FAILED',
          messageRu: 'Калибровка ${type != null ? (type == 'audio' ? 'аудио' : 'видео') : ''} не удалась${reason != null ? ': $reason' : ''}',
          messageEn: 'Calibration ${type != null ? (type == 'audio' ? 'audio' : 'video') : ''} failed${reason != null ? ': $reason' : ''}',
          recoveryStepsRu: [
            'Проверьте, что устройства подключены',
            'Убедитесь, что устройства доступны',
            'Попробуйте калибровку еще раз',
            'Проверьте настройки устройств',
          ],
          recoveryStepsEn: [
            'Check that devices are connected',
            'Ensure devices are available',
            'Try calibration again',
            'Check device settings',
          ],
        );
}

/// Thrown when no devices are found
/// Выбрасывается когда устройства не найдены
class FreedomeNoDevicesFoundException extends FreedomeException {
  FreedomeNoDevicesFoundException({
    String? deviceType, // 'audio' or 'video'
  }) : super(
          code: 'NO_DEVICES_FOUND',
          messageRu: 'Устройства${deviceType != null ? (deviceType == 'audio' ? ' аудио' : ' видео') : ''} не найдены',
          messageEn: 'No${deviceType != null ? ' $deviceType' : ''} devices found',
          recoveryStepsRu: [
            'Проверьте подключения устройств',
            'Убедитесь, что драйверы установлены',
            'Перезапустите приложение',
            'Проверьте настройки системы',
          ],
          recoveryStepsEn: [
            'Check device connections',
            'Ensure drivers are installed',
            'Restart the application',
            'Check system settings',
          ],
        );
}

/// Thrown when system status cannot be retrieved
/// Выбрасывается когда не удалось получить статус системы
class FreedomeStatusRetrievalFailedException extends FreedomeException {
  FreedomeStatusRetrievalFailedException({String? reason})
      : super(
          code: 'STATUS_RETRIEVAL_FAILED',
          messageRu: 'Не удалось получить статус системы${reason != null ? ': $reason' : ''}',
          messageEn: 'Failed to retrieve system status${reason != null ? ': $reason' : ''}',
          recoveryStepsRu: [
            'Проверьте, что сервис инициализирован',
            'Убедитесь, что соединение активно',
            'Попробуйте еще раз',
          ],
          recoveryStepsEn: [
            'Check that the service is initialized',
            'Ensure connection is active',
            'Try again',
          ],
        );
}

/// Thrown when data sending fails
/// Выбрасывается при ошибке отправки данных
class FreedomeDataSendFailedException extends FreedomeException {
  FreedomeDataSendFailedException({String? reason})
      : super(
          code: 'DATA_SEND_FAILED',
          messageRu: 'Не удалось отправить данные${reason != null ? ': $reason' : ''}',
          messageEn: 'Failed to send data${reason != null ? ': $reason' : ''}',
          recoveryStepsRu: [
            'Проверьте, что подключены к серверу',
            'Убедитесь, что данные корректны',
            'Проверьте размер данных',
            'Попробуйте еще раз',
          ],
          recoveryStepsEn: [
            'Check that you are connected to the server',
            'Ensure data is valid',
            'Check data size',
            'Try again',
          ],
        );
}

/// Thrown when initialization fails
/// Выбрасывается при ошибке инициализации
class FreedomeInitializationFailedException extends FreedomeException {
  FreedomeInitializationFailedException({String? component, String? reason})
      : super(
          code: 'INITIALIZATION_FAILED',
          messageRu: 'Инициализация ${component != null ? component : 'FreeDome'} не удалась${reason != null ? ': $reason' : ''}',
          messageEn: 'Initialization ${component != null ? 'of $component' : 'failed'}${reason != null ? ': $reason' : ''}',
          recoveryStepsRu: [
            'Перезапустите приложение',
            'Проверьте логи ошибок',
            'Убедитесь, что зависимости доступны',
            'Попробуйте еще раз',
          ],
          recoveryStepsEn: [
            'Restart the application',
            'Check error logs',
            'Ensure dependencies are available',
            'Try again',
          ],
        );
}

/// Thrown when device is unavailable
/// Выбрасывается когда устройство недоступно
class FreedomeDeviceUnavailableException extends FreedomeException {
  FreedomeDeviceUnavailableException({String? deviceId, String? deviceName})
      : super(
          code: 'DEVICE_UNAVAILABLE',
          messageRu: 'Устройство${deviceName != null ? ' "$deviceName"' : ''}${deviceId != null ? ' ($deviceId)' : ''} недоступно',
          messageEn: 'Device${deviceName != null ? ' "$deviceName"' : ''}${deviceId != null ? ' ($deviceId)' : ''} is unavailable',
          recoveryStepsRu: [
            'Проверьте подключение устройства',
            'Убедитесь, что устройство не используется другим приложением',
            'Выберите другое устройство',
          ],
          recoveryStepsEn: [
            'Check device connection',
            'Ensure device is not used by another application',
            'Select another device',
          ],
        );
}

/// Thrown when operation times out
/// Выбрасывается при превышении времени операции
class FreedomeTimeoutException extends FreedomeException {
  FreedomeTimeoutException({String? operation, Duration? timeout})
      : super(
          code: 'TIMEOUT',
          messageRu: 'Превышено время ожидания${operation != null ? ' для $operation' : ''}${timeout != null ? ' (${timeout.inSeconds}с)' : ''}',
          messageEn: 'Operation timed out${operation != null ? ' for $operation' : ''}${timeout != null ? ' (${timeout.inSeconds}s)' : ''}',
          recoveryStepsRu: [
            'Попробуйте еще раз',
            'Проверьте производительность системы',
            'Убедитесь, что система не перегружена',
          ],
          recoveryStepsEn: [
            'Try again',
            'Check system performance',
            'Ensure system is not overloaded',
          ],
        );
