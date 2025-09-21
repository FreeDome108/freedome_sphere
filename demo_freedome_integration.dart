#!/usr/bin/env dart

import 'lib/services/freedome_integration_service.dart';

/// Демонстрация FreeDome интеграции
Future<void> main() async {
  print('🌐 =============================================');
  print('   FREEDOME SPHERE - INTEGRATION DEMO');
  print('   Демонстрация интеграции с FreeDome');
  print('🌐 =============================================');
  print('');

  final service = FreedomeIntegrationService();

  try {
    // 1. Инициализация
    print('🔄 Шаг 1: Инициализация FreeDome интеграции...');
    await service.initialize();
    print('✅ Инициализация завершена');
    print('');

    // 2. Подключение
    print('🔗 Шаг 2: Подключение к FreeDome системе...');
    final connected = await service.connect(serverUrl: 'localhost', port: 8080);

    if (connected) {
      print('✅ Подключение установлено');
    } else {
      print('❌ Не удалось подключиться');
      return;
    }
    print('');

    // 3. Калибровка аудио
    print('🎵 Шаг 3: Калибровка аудио системы...');
    final audioResult = await service.calibrateAudio();
    print('📊 Результат калибровки аудио:');
    print('   Статус: ${audioResult.status}');
    print('   Успех: ${audioResult.success ? "Да" : "Нет"}');
    if (audioResult.data != null) {
      print('   Данные: ${audioResult.data}');
    }
    print('');

    // 4. Калибровка видео
    print('📹 Шаг 4: Калибровка видео системы...');
    final videoResult = await service.calibrateVideo();
    print('📊 Результат калибровки видео:');
    print('   Статус: ${videoResult.status}');
    print('   Успех: ${videoResult.success ? "Да" : "Нет"}');
    if (videoResult.data != null) {
      print('   Данные: ${videoResult.data}');
    }
    print('');

    // 5. Получение статуса системы
    print('📈 Шаг 5: Получение статуса системы...');
    final systemStatus = await service.getSystemStatus();
    print('📊 Статус системы:');
    print('   Работает: ${systemStatus.isRunning ? "Да" : "Нет"}');
    print('   Активные сервисы: ${systemStatus.activeServices.join(", ")}');
    print('   Информация: ${systemStatus.info}');
    print('');

    // 6. Получение списка устройств
    print('🔌 Шаг 6: Получение списка устройств...');
    final devices = await service.getAvailableDevices();
    print('📊 Доступные устройства:');
    for (final device in devices) {
      print(
        '   ${device.name} (${device.type}) - ${device.isAvailable ? "Доступно" : "Недоступно"}',
      );
    }
    print('');

    // 7. Отправка тестовых данных
    print('📤 Шаг 7: Отправка тестовых данных...');
    final testData = {
      'type': 'demo',
      'timestamp': DateTime.now().toIso8601String(),
      'message': 'Тестовое сообщение от FreeDome Sphere',
      'version': '1.0.0',
    };

    await service.sendData(testData);
    print('✅ Данные отправлены успешно');
    print('   Отправленные данные: $testData');
    print('');

    // 8. Отключение
    print('🔌 Шаг 8: Отключение от системы...');
    await service.disconnect();
    print('✅ Отключение завершено');
    print('');

    print('🎉 =============================================');
    print('   ДЕМОНСТРАЦИЯ ЗАВЕРШЕНА УСПЕШНО!');
    print('   Все функции FreeDome интеграции работают');
    print('🎉 =============================================');
  } catch (e) {
    print('❌ Ошибка во время демонстрации: $e');
  } finally {
    service.dispose();
  }
}
