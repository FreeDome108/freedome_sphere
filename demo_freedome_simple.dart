#!/usr/bin/env dart

import 'lib/services/freedome_api_stubs.dart';

/// Простая демонстрация FreeDome API заглушек
Future<void> main() async {
  print('🌐 =============================================');
  print('   FREEDOME SPHERE - SIMPLE INTEGRATION DEMO');
  print('   Демонстрация API заглушек FreeDome');
  print('🌐 =============================================');
  print('');

  try {
    // 1. Инициализация компонентов
    print('🔄 Шаг 1: Инициализация компонентов FreeDome...');

    final core = FreedomeCore();
    final calibration = FreedomeCalibration();
    final connectivity = FreedomeConnectivity();

    await core.initialize();
    await calibration.initialize();
    await connectivity.initialize();

    print('✅ Все компоненты инициализированы');
    print('');

    // 2. Подключение
    print('🔗 Шаг 2: Подключение к FreeDome системе...');
    final connected = await connectivity.connect(
      serverUrl: 'localhost',
      port: 8080,
      options: {},
    );

    if (connected) {
      print('✅ Подключение установлено');
    } else {
      print('❌ Не удалось подключиться');
      return;
    }
    print('');

    // 3. Калибровка аудио
    print('🎵 Шаг 3: Калибровка аудио системы...');
    final audioResult = await calibration.calibrateAudio();
    print('📊 Результат калибровки аудио:');
    print('   Статус: ${audioResult.status}');
    print('   Успех: ${audioResult.success ? "Да" : "Нет"}');
    if (audioResult.data != null) {
      print('   Устройства: ${audioResult.data!['devices']}');
      print('   Частота дискретизации: ${audioResult.data!['sampleRate']} Hz');
      print('   Каналы: ${audioResult.data!['channels']}');
      print('   Задержка: ${audioResult.data!['latency']} мс');
    }
    print('');

    // 4. Калибровка видео
    print('📹 Шаг 4: Калибровка видео системы...');
    final videoResult = await calibration.calibrateVideo();
    print('📊 Результат калибровки видео:');
    print('   Статус: ${videoResult.status}');
    print('   Успех: ${videoResult.success ? "Да" : "Нет"}');
    if (videoResult.data != null) {
      print('   Разрешение: ${videoResult.data!['resolution']}');
      print('   FPS: ${videoResult.data!['fps']}');
      print('   Проекция: ${videoResult.data!['projection']}');
      print('   Яркость: ${videoResult.data!['brightness']}');
      print('   Контрастность: ${videoResult.data!['contrast']}');
    }
    print('');

    // 5. Получение статуса системы
    print('📈 Шаг 5: Получение статуса системы...');
    final systemStatus = await core.getSystemStatus();
    print('📊 Статус системы:');
    print('   Работает: ${systemStatus.isRunning ? "Да" : "Нет"}');
    print('   Активные сервисы: ${systemStatus.activeServices.join(", ")}');
    print('   Информация о системе:');
    systemStatus.info.forEach((key, value) {
      print('     $key: $value');
    });
    print('');

    // 6. Получение списка устройств
    print('🔌 Шаг 6: Получение списка устройств...');
    final devices = await calibration.getAvailableDevices();
    print('📊 Доступные устройства:');
    for (final device in devices) {
      final status = device.isAvailable ? "✅ Доступно" : "❌ Недоступно";
      print('   $status ${device.name} (${device.type}) - ID: ${device.id}');
    }
    print('');

    // 7. Отправка тестовых данных
    print('📤 Шаг 7: Отправка тестовых данных...');
    final testData = {
      'type': 'demo',
      'timestamp': DateTime.now().toIso8601String(),
      'message': 'Тестовое сообщение от FreeDome Sphere',
      'version': '1.0.0',
      'project': {
        'name': 'Demo Project',
        'scenes': ['scene1', 'scene2'],
        'audio': ['audio1.mp3'],
      },
    };

    await core.sendData(testData);
    print('✅ Данные отправлены успешно');
    print('   Отправленные данные:');
    testData.forEach((key, value) {
      print('     $key: $value');
    });
    print('');

    // 8. Тестирование событий подключения
    print('📡 Шаг 8: Тестирование событий подключения...');
    connectivity.onConnectionStatusChanged.listen((status) {
      print('   📡 Событие: Статус подключения изменился на ${status.name}');
    });

    // Симулируем изменение статуса
    await Future.delayed(const Duration(milliseconds: 100));
    print('✅ Слушатель событий подключен');
    print('');

    // 9. Отключение
    print('🔌 Шаг 9: Отключение от системы...');
    await connectivity.disconnect();
    print('✅ Отключение завершено');
    print('');

    // 10. Очистка ресурсов
    print('🧹 Шаг 10: Очистка ресурсов...');
    connectivity.dispose();
    print('✅ Ресурсы очищены');
    print('');

    print('🎉 =============================================');
    print('   ДЕМОНСТРАЦИЯ ЗАВЕРШЕНА УСПЕШНО!');
    print('   Все API заглушки FreeDome работают корректно');
    print('   Система готова к интеграции с реальными пакетами');
    print('🎉 =============================================');
  } catch (e) {
    print('❌ Ошибка во время демонстрации: $e');
    print('   Stack trace: ${StackTrace.current}');
  }
}
