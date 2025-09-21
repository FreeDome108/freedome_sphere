# FreeDome Integration Guide

## Обзор

Данный документ описывает интеграцию FreeDome Sphere с экосистемой FreeDome через новые версии библиотек:

- `flutter_freedome` - основная библиотека для работы с FreeDome
- `flutter_freedome_calibration` - калибровка аудио и видео систем
- `flutter_freedome_connectivity` - управление подключениями

## Архитектура

### Компоненты системы

1. **FreedomeIntegrationService** - основной сервис для управления интеграцией
2. **FreedomeCore** - ядро системы FreeDome
3. **FreedomeCalibration** - модуль калибровки
4. **FreedomeConnectivity** - модуль подключения

### Поток работы

```
Инициализация → Подключение → Калибровка → Работа с контентом
```

## Использование

### 1. Инициализация

```dart
final freedomeService = FreedomeIntegrationService();
await freedomeService.initialize();
```

### 2. Подключение к системе

```dart
final connected = await freedomeService.connect(
  serverUrl: 'localhost',
  port: 8080,
);
```

### 3. Калибровка системы

```dart
// Калибровка аудио
final audioResult = await freedomeService.calibrateAudio();

// Калибровка видео
final videoResult = await freedomeService.calibrateVideo();
```

### 4. Отправка данных

```dart
await freedomeService.sendData({
  'type': 'project',
  'data': projectData,
});
```

## Интерфейс пользователя

### Экран интеграции

Доступен через меню инструментов: **Инструменты → FreeDome Integration**

Возможности экрана:
- Просмотр статуса системы
- Настройка подключения
- Калибровка аудио и видео
- Мониторинг активных сервисов

### Состояния подключения

- **Disconnected** - отключено
- **Connecting** - подключение
- **Connected** - подключено
- **Error** - ошибка

## API Reference

### FreedomeIntegrationService

#### Методы

- `initialize()` - инициализация всех компонентов
- `connect({String? serverUrl, int? port})` - подключение к системе
- `disconnect()` - отключение от системы
- `calibrateAudio({List<String>? devices})` - калибровка аудио
- `calibrateVideo({Map<String, dynamic>? settings})` - калибровка видео
- `sendData(Map<String, dynamic> data)` - отправка данных
- `getSystemStatus()` - получение статуса системы
- `getAvailableDevices()` - получение списка устройств

#### Свойства

- `isInitialized` - статус инициализации
- `isConnected` - статус подключения
- `connectionStatus` - текущий статус подключения

### Типы данных

#### ConnectionStatus

```dart
enum ConnectionStatus {
  disconnected,
  connecting,
  connected,
  error,
}
```

#### CalibrationResult

```dart
class CalibrationResult {
  final bool success;
  final String status;
  final Map<String, dynamic>? data;
  final String? error;
}
```

#### SystemStatus

```dart
class SystemStatus {
  final bool isRunning;
  final Map<String, dynamic> info;
  final List<String> activeServices;
}
```

#### DeviceInfo

```dart
class DeviceInfo {
  final String id;
  final String name;
  final String type;
  final bool isAvailable;
}
```

## Тестирование

### Запуск тестов

```bash
flutter test test/freedome_integration_test.dart
```

### Тестовые сценарии

1. Инициализация сервиса
2. Подключение к системе
3. Калибровка аудио и видео
4. Отправка данных
5. Получение статуса системы
6. Обработка ошибок

## Заглушки (Stubs)

До получения реальных пакетов используются заглушки в файле `lib/services/freedome_api_stubs.dart`:

- Имитируют работу реальных API
- Возвращают реалистичные данные
- Включают задержки для симуляции реальной работы
- Логируют операции для отладки

## Миграция на реальные пакеты

Когда реальные пакеты станут доступны:

1. Раскомментировать зависимости в `pubspec.yaml`
2. Заменить импорт `freedome_api_stubs.dart` на реальные пакеты
3. Удалить файл заглушек
4. Обновить тесты при необходимости

## Примеры использования

### Базовый сценарий

```dart
// Инициализация
final freedomeService = FreedomeIntegrationService();
await freedomeService.initialize();

// Подключение
final connected = await freedomeService.connect(
  serverUrl: '192.168.1.100',
  port: 8080,
);

if (connected) {
  // Калибровка
  await freedomeService.calibrateAudio();
  await freedomeService.calibrateVideo();
  
  // Отправка проекта
  await freedomeService.sendData({
    'type': 'project',
    'name': 'My Project',
    'scenes': sceneData,
  });
}
```

### Обработка ошибок

```dart
try {
  await freedomeService.initialize();
  await freedomeService.connect();
} catch (e) {
  print('Ошибка интеграции FreeDome: $e');
  // Обработка ошибки
}
```

### Мониторинг статуса

```dart
// Слушаем изменения статуса подключения
freedomeService.addListener(() {
  print('Статус подключения: ${freedomeService.connectionStatus}');
});
```

## Логирование

Все операции логируются с эмодзи для удобства:

- 🔄 Инициализация
- 🔗 Подключение
- 🎵 Калибровка аудио
- 📹 Калибровка видео
- 📤 Отправка данных
- ✅ Успех
- ❌ Ошибка

## Поддержка

При возникновении проблем:

1. Проверьте логи в консоли
2. Убедитесь в правильности настроек подключения
3. Проверьте доступность FreeDome системы
4. Запустите тесты для диагностики

## Версии

- **v1.0.0** - Базовая интеграция с заглушками
- **v1.1.0** - Добавлен UI для управления
- **v1.2.0** - Добавлены тесты
- **v2.0.0** - Планируется интеграция с реальными пакетами
