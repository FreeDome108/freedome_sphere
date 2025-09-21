import 'package:flutter_test/flutter_test.dart';
import 'package:freedome_sphere_flutter/services/freedome_integration_service.dart';
import 'package:freedome_sphere_flutter/services/freedome_api_stubs.dart';

void main() {
  group('FreeDome Integration Service Tests', () {
    late FreedomeIntegrationService service;

    setUp(() {
      service = FreedomeIntegrationService();
    });

    tearDown(() {
      service.dispose();
    });

    test('should initialize successfully', () async {
      // Act
      await service.initialize();

      // Assert
      expect(service.isInitialized, isTrue);
    });

    test('should connect to FreeDome system', () async {
      // Arrange
      await service.initialize();

      // Act
      final result = await service.connect();

      // Assert
      expect(result, isTrue);
      expect(service.isConnected, isTrue);
      expect(service.connectionStatus, equals(ConnectionStatus.connected));
    });

    test('should disconnect from FreeDome system', () async {
      // Arrange
      await service.initialize();
      await service.connect();

      // Act
      await service.disconnect();

      // Assert
      expect(service.isConnected, isFalse);
      expect(service.connectionStatus, equals(ConnectionStatus.disconnected));
    });

    test('should calibrate audio system', () async {
      // Arrange
      await service.initialize();

      // Act
      final result = await service.calibrateAudio();

      // Assert
      expect(result.success, isTrue);
      expect(result.status, contains('Audio calibration completed'));
    });

    test('should calibrate video system', () async {
      // Arrange
      await service.initialize();

      // Act
      final result = await service.calibrateVideo();

      // Assert
      expect(result.success, isTrue);
      expect(result.status, contains('Video calibration completed'));
    });

    test('should get system status', () async {
      // Arrange
      await service.initialize();

      // Act
      final status = await service.getSystemStatus();

      // Assert
      expect(status.isRunning, isTrue);
      expect(status.activeServices, isNotEmpty);
      expect(status.info, isNotEmpty);
    });

    test('should get available devices', () async {
      // Arrange
      await service.initialize();

      // Act
      final devices = await service.getAvailableDevices();

      // Assert
      expect(devices, isNotEmpty);
      expect(devices.any((device) => device.type == 'audio'), isTrue);
      expect(devices.any((device) => device.type == 'video'), isTrue);
    });

    test('should send data to FreeDome system', () async {
      // Arrange
      await service.initialize();
      await service.connect();

      // Act & Assert
      expect(
        () => service.sendData({'test': 'data'}),
        returnsNormally,
      );
    });

    test('should throw exception when not initialized', () async {
      // Act & Assert
      expect(
        () => service.connect(),
        throwsException,
      );
    });

    test('should throw exception when trying to send data without connection', () async {
      // Arrange
      await service.initialize();

      // Act & Assert
      expect(
        () => service.sendData({'test': 'data'}),
        throwsException,
      );
    });
  });

  group('FreeDome API Stubs Tests', () {
    test('FreedomeCore should initialize', () async {
      // Arrange
      final core = FreedomeCore();

      // Act
      await core.initialize();

      // Assert
      expect(core, isNotNull);
    });

    test('FreedomeCalibration should initialize', () async {
      // Arrange
      final calibration = FreedomeCalibration();

      // Act
      await calibration.initialize();

      // Assert
      expect(calibration, isNotNull);
    });

    test('FreedomeConnectivity should initialize', () async {
      // Arrange
      final connectivity = FreedomeConnectivity();

      // Act
      await connectivity.initialize();

      // Assert
      expect(connectivity, isNotNull);
    });

    test('FreedomeConnectivity should connect successfully', () async {
      // Arrange
      final connectivity = FreedomeConnectivity();
      await connectivity.initialize();

      // Act
      final result = await connectivity.connect(
        serverUrl: 'localhost',
        port: 8080,
        options: {},
      );

      // Assert
      expect(result, isTrue);
    });

    test('FreedomeCalibration should return calibration result', () async {
      // Arrange
      final calibration = FreedomeCalibration();
      await calibration.initialize();

      // Act
      final result = await calibration.calibrateAudio();

      // Assert
      expect(result, isA<CalibrationResult>());
      expect(result.success, isTrue);
    });
  });
}
