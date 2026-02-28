# FreeDome Calibration System

> **Автоматическая калибровка для купольных сред**
> 
> **Automated Calibration for Dome Environments**
>
> **Версия:** 1.0.0 (в разработке)
> **Платформа:** Flutter (iOS, Android, Quest 3)
> **Язык:** Русский / English

---

## 📖 Обзор / Overview

**FreeDome Calibration System** — это система автоматической калибровки аудио и видео оборудования для купольных/иммерсивных сред, не требующая физического измерительного оборудования.

**FreeDome Calibration System** is an automated audio/video calibration system for dome/immersive environments, requiring no physical measurement hardware.

### 🎯 Основные возможности / Key Features

- **Калибровка аудио** - Частота дискретизации, каналы, задержка, пространственное аудио
- **Калибровка видео** - Разрешение, FPS, проекция, яркость, контрастность
- **Определение устройств** - Автоматическое обнаружение аудио/видео устройств
- **История калибровок** - Сохранение, сравнение, откат настроек
- **Без оборудования** - Программная калибровка без физических измерений

---

## 🔧 Типы калибровки / Calibration Types

### 1. Аудио калибровка / Audio Calibration

**Измеряемые параметры / Measured Parameters:**

| Параметр | Значение по умолчанию | Цель |
|----------|----------------------|------|
| Частота дискретизации | 48000 Гц | 48000 Гц |
| Каналы | 8 | 8-16 |
| Задержка | 12.5 мс | < 20 мс |
| Пространственное аудио | Включено | Включено |

**Пример результата / Example Result:**
```json
{
  "success": true,
  "status": "Audio calibration completed successfully",
  "data": {
    "sampleRate": 48000,
    "channels": 8,
    "latency": 12.5,
    "devices": ["Default Audio Device", "HDMI Output"],
    "spatialAudioEnabled": true,
    "calibratedAt": "2026-02-28T12:00:00Z"
  }
}
```

### 2. Видео калибровка / Video Calibration

**Измеряемые параметры / Measured Parameters:**

| Параметр | Значение по умолчанию | Цель |
|----------|----------------------|------|
| Разрешение | 4096x2048 | Нативное для купола |
| FPS | 60 | 60-120 |
| Проекция | Spherical | По типу купола |
| Яркость | 0.85 | 0.8-0.9 |
| Контрастность | 0.9 | 0.85-0.95 |

**Пример результата / Example Result:**
```json
{
  "success": true,
  "status": "Video calibration completed successfully",
  "data": {
    "resolution": "4096x2048",
    "fps": 60,
    "projection": "spherical",
    "brightness": 0.85,
    "contrast": 0.9,
    "fisheyeCorrection": true,
    "calibratedAt": "2026-02-28T12:00:00Z"
  }
}
```

---

## 🚀 Быстрый старт / Quick Start

### Использование / Usage

```dart
// Инициализация / Initialization
final service = FreedomeIntegrationService();
await service.initialize();

// Аудио калибровка / Audio Calibration
final audioResult = await service.calibrateAudio(
  devices: ['Default Audio Device'],
  options: {'spatialAudio': true},
);

print('Аудио калибровка: ${audioResult.status}');
print('Частота: ${audioResult.data!['sampleRate']} Гц');
print('Каналы: ${audioResult.data!['channels']}');
print('Задержка: ${audioResult.data!['latency']} мс');

// Видео калибровка / Video Calibration
final videoResult = await service.calibrateVideo(
  settings: {'resolution': '4096x2048'},
  options: {'fisheyeCorrection': true},
);

print('Видео калибровка: ${videoResult.status}');
print('Разрешение: ${videoResult.data!['resolution']}');
print('FPS: ${videoResult.data!['fps']}');
print('Проекция: ${videoResult.data!['projection']}');

// Получение списка устройств / Get Device List
final devices = await service.getAvailableDevices();
for (final device in devices) {
  print('${device.name} (${device.type}) - ${device.isAvailable ? "Доступно" : "Недоступно"}');
}
```

---

## 📊 Время калибровки / Calibration Timing

| Тип калибровки / Calibration Type | Время / Time |
|-----------------------------------|--------------|
| Аудио / Audio | 2-3 секунды |
| Видео / Video | 3-4 секунды |
| Определение устройств / Device Detection | < 1 секунды |

---

## 🔌 Интеграция / Integration

### С FreeDome Manager / With FreeDome Manager

```dart
// Автоматическая калибровка при подключении / Auto-calibrate on connect
final service = FreedomeIntegrationService();
await service.initialize();
await service.connect();

// Калибровка обоих систем / Calibrate both systems
final audioResult = await service.calibrateAudio();
final videoResult = await service.calibrateVideo();

// Проверка результатов / Check results
if (audioResult.success && videoResult.success) {
  print('✅ Система откалибрована и готова к работе');
} else {
  print('❌ Ошибка калибровки: ${audioResult.error ?? videoResult.error}');
}
```

### С Lyubomir AI / With Lyubomir AI

```dart
// Использование данных калибровки для анализа / Use calibration data for analysis
final audioCalibration = await service.calibrateAudio();
final understanding = await lyubomirService.createUnderstanding(
  name: 'Аудио анализ',
  type: UnderstandingType.audio,
  metadata: {
    'calibration': audioCalibration.data,
    'optimized': true,
  },
);
```

---

## ⚙️ Расширенные настройки / Advanced Settings

### Настройки аудио калибровки / Audio Calibration Settings

```dart
final audioOptions = {
  'spatialAudio': true,           // Пространственное аудио
  'quantumResonance': false,      // Квантовые резонансы anAntaSound
  'multiChannel': true,           // Многоканальный режим
  'targetLatency': 15.0,          // Целевая задержка (мс)
  'autoGainControl': true,        // Автоматическая регулировка增益
};

final result = await service.calibrateAudio(options: audioOptions);
```

### Настройки видео калибровки / Video Calibration Settings

```dart
final videoSettings = {
  'resolution': '4096x2048',      // Разрешение
  'fps': 60,                      // Кадры в секунду
  'hdr': true,                    // HDR поддержка
  'colorSpace': 'Rec.2020',       // Цветовое пространство
};

final videoOptions = {
  'fisheyeCorrection': true,      // Коррекция рыбий глаз
  'sphericalProjection': true,    // Сферическая проекция
  'ambientLightCompensation': false, // Компенсация освещения
  'autoBrightness': true,         // Автоматическая яркость
};

final result = await service.calibrateVideo(
  settings: videoSettings,
  options: videoOptions,
);
```

---

## 📁 История калибровок / Calibration History

### Сохранение калибровки / Save Calibration

```dart
// Сохранение текущей калибровки / Save current calibration
final calibration = {
  'audio': audioResult.data,
  'video': videoResult.data,
  'timestamp': DateTime.now(),
  'venue': 'Planetarium Moscow',
};

// В реальной реализации сохраняется в SharedPreferences / In real implementation saves to SharedPreferences
await saveCalibrationHistory(calibration);
```

### Сравнение калибровок / Compare Calibrations

```dart
// Получение истории / Get history
final history = await getCalibrationHistory();

// Сравнение текущей с предыдущей / Compare current with previous
final previous = history.last;
final current = audioResult.data;

print('Изменение задержки: ${previous['latency']} → ${current['latency']} мс');
print('Изменение яркости: ${previous['brightness']} → ${current['brightness']}');
```

---

## 🐛 Обработка ошибок / Error Handling

### Типичные ошибки / Common Errors

| Ошибка / Error | Причина / Cause | Решение / Solution |
|----------------|-----------------|-------------------|
| "No devices detected" | Устройства не найдены | Проверьте подключения |
| "Calibration timeout" | Превышено время | Повторите попытку |
| "Invalid settings" | Некорректные настройки | Используйте настройки по умолчанию |
| "Device unavailable" | Устройство недоступно | Выберите другое устройство |

### Пример обработки / Error Handling Example

```dart
try {
  final result = await service.calibrateAudio();
  if (result.success) {
    print('✅ Калибровка успешна');
  } else {
    print('❌ Ошибка: ${result.error}');
    print('💡 Решение: Проверьте подключения устройств');
  }
} catch (e) {
  print('❌ Исключение: $e');
  print('💡 Попробуйте перезапустить сервис');
}
```

---

## 📊 Метрики производительности / Performance Metrics

### Время выполнения / Execution Time

```dart
final stopwatch = Stopwatch()..start();
await service.calibrateAudio();
stopwatch.stop();

print('Время аудио калибровки: ${stopwatch.elapsedMilliseconds} мс');
// Ожидается / Expected: < 3000 мс
```

### Использование памяти / Memory Usage

```dart
// Мониторинг памяти во время калибровки / Monitor memory during calibration
final info = await ProcessInfo.instance.currentProcess;
print('Использование памяти: ${info.residentSetSize ~/ 1024} KB');
// Ожидается / Expected: < 50 MB
```

---

## 🧪 Тестирование / Testing

```bash
# Запуск тестов калибровки / Run calibration tests
flutter test test/freedome_integration_test.dart --plain-name "calibrate"

# Тесты аудио калибровки / Audio calibration tests
flutter test test/calibration/audio_calibration_test.dart

# Тесты видео калибровки / Video calibration tests
flutter test test/calibration/video_calibration_test.dart
```

---

## 📝 SDD Документация / SDD Documentation

- [`01-requirements.md`](./01-requirements.md) - Требования и сценарии использования
- [`02-specifications.md`](./02-specifications.md) - Архитектура и спецификации
- [`03-plan.md`](./03-plan.md) - План реализации

---

## 🔗 Связанные системы / Related Systems

- **FreeDome Manager** - Общая система интеграции
- **Lyubomir AI** - ИИ анализ контента
- **anAntaSound** - Квантовая обработка аудио

---

**Last Updated:** 2026-02-28
**Version:** 1.0.0 (development)
