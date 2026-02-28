# Lyubomir AI Understanding System

> **Интеллектуальная система анализа контента**
> 
> **Intelligent Content Analysis System**
>
> **Версия:** 1.0.0 (в разработке)
> **Платформа:** Flutter (iOS, Android, Quest 3)
> **Язык:** Русский / English

---

## 📖 Обзор / Overview

**Lyubomir** — это ИИ система для автоматического анализа и понимания контента с 11 типами понимания, специально разработанная для оптимизации контента под купольные дисплеи.

**Lyubomir** is an AI-powered content analysis system with 11 understanding types, specifically designed for dome display content optimization.

### 🎯 Основные возможности / Key Features

- **11 типов понимания** - Визуальный, Аудио, Текст, Пространственный, Временной, Семантический, Интерактивный, Эмоциональный, Квантовый, Холистический, 3D
- **Автоматический анализ** - Определение типа контента и запуск соответствующего анализа
- **Рекомендации** - Специфичные для купольных сред рекомендации по оптимизации
- **Интеграция** - Поддержка ZELIM, COLLADA, стандартных медиа форматов
- **Настройки** - Гибкая конфигурация алгоритмов, чувствительности, типов анализа

---

## 🔧 Типы понимания / Understanding Types

| Тип / Type | Описание / Description | Время / Time |
|------------|------------------------|--------------|
| **Visual** | Анализ цветов, объектов, композиции | 2 сек |
| **Audio** | Частота, амплитуда, пространственное аудио | 3 сек |
| **Text** | Тональность, ключевые слова, язык | 1 сек |
| **Spatial** | 3D геометрия, материалы, UV-маппинг | 4 сек |
| **Temporal** | Длительность, ключевые кадры, переходы | 3.5 сек |
| **Semantic** | Смысл, концепции, контекст | 2.5 сек |
| **Interactive** | Интерактивность, UX, доступность | 3.5 сек |
| **Emotional** | Эмоции, интенсивность, валентность | 2 сек |
| **Quantum** | Когерентность, запутанность, суперпозиция | 5 сек |
| **Holistic** | Целостность, взаимосвязи, эмерджентность | 4.5 сек |
| **ThreeDimensional** | Вершины, грани, LOD, оптимизация | 4 сек |

---

## 🚀 Быстрый старт / Quick Start

### Использование / Usage

```dart
// Инициализация / Initialization
final service = LyubomirUnderstandingService();
await service.initialize();

// Создание понимания / Create understanding
final understanding = await service.createUnderstanding(
  name: 'Моя 3D модель',
  description: 'Квантовая сфера',
  type: UnderstandingType.spatial,
);

// Анализ / Analysis
await service.analyzeContent(understanding.id, filePath: '/path/to/model.zelim');

// Получение рекомендаций / Get recommendations
final recommendations = service.getRecommendations(understanding.id);
// ['Рассмотрите оптимизацию полигонов...', ...]

// Проверка результатов / Check results
final results = understanding.results;
for (final result in results) {
  print('Тип: ${result.type}');
  print('Уверенность: ${result.confidence}');
  print('Данные: ${result.data}');
}
```

---

## 📊 Примеры результатов / Example Results

### Визуальный анализ / Visual Analysis

```json
{
  "type": "visual",
  "confidence": 0.85,
  "data": {
    "dominantColors": ["#FF6B6B", "#4ECDC4", "#45B7D1"],
    "colorTemperature": "warm",
    "brightness": 0.7,
    "contrast": 0.8,
    "objects": ["person", "building"],
    "dome_projection_suitable": true
  }
}
```

### Пространственный анализ / Spatial Analysis

```json
{
  "type": "spatial",
  "confidence": 0.92,
  "data": {
    "vertices": 2847,
    "faces": 5694,
    "materials": ["metal", "glass"],
    "dome_optimized": true,
    "quantum_elements_detected": 108,
    "uv_mapping_valid": true
  }
}
```

### Аудио анализ / Audio Analysis

```json
{
  "type": "audio",
  "confidence": 0.88,
  "data": {
    "frequency": 440.0,
    "amplitude": 0.6,
    "duration": 120.5,
    "spatial_audio_compatible": true,
    "quantum_resonance_detected": false,
    "channels": 8
  }
}
```

---

## ⚙️ Настройки / Settings

### Конфигурация / Configuration

```dart
final settings = LyubomirSettings(
  enabled: true,              // Включить систему
  learningRate: 0.01,         // Скорость обучения
  maxIterations: 1000,        // Максимум итераций
  algorithm: 'quantum_neural',// Алгоритм анализа
  autoAnalyze: true,          // Авто-анализ файлов
  sensitivity: 0.7,           // Чувствительность
  enabledTypes: [
    UnderstandingType.visual,
    UnderstandingType.spatial,
    UnderstandingType.audio,
  ],
);

await service.updateSettings(settings);
```

---

## 📁 Поддерживаемые форматы / Supported Formats

| Формат / Format | Расширения / Extensions | Тип анализа / Analysis Type |
|-----------------|-------------------------|----------------------------|
| 3D Models | .zelim, .dae, .blend | Spatial, ThreeDimensional |
| Images | .jpg, .png, .gif | Visual |
| Video | .mp4, .mov, .avi | Visual, Temporal |
| Audio | .mp3, .wav, .ogg | Audio |
| Text | .txt, .md, .json | Text, Semantic |

---

## 🎯 Рекомендации / Recommendations

### Примеры рекомендаций / Example Recommendations

**Для 3D моделей / For 3D Models:**
- "Рассмотрите оптимизацию полигонов для купольной проекции"
- "Проверьте квантовые резонансы для anAntaSound интеграции"
- "Убедитесь в правильности UV-маппинга для сферической проекции"

**Для изображений / For Images:**
- "Используйте HDR тональное отображение для купольных дисплеев"
- "Рассмотрите применение рыбий глаз проекции"
- "Оптимизируйте контрастность для темных планетариев"

**Для аудио / For Audio:**
- "Настройте пространственное аудио для купольной акустики"
- "Используйте квантовые резонансы anAntaSound"
- "Проверьте фазовые соотношения для многоканального воспроизведения"

---

## 📊 Статистика / Statistics

### Метрики / Metrics

```dart
final totalAnalyzed = service.totalAnalyzed;      // Всего проанализировано
final successRate = service.successRate;          // Процент успеха
final lastAnalysisTime = service.lastAnalysisTime; // Последнее время анализа

print('Проанализировано: $totalAnalyzed');
print('Успешность: ${(successRate * 100).toStringAsFixed(1)}%');
```

---

## 🔌 Интеграция / Integration

### С другими системами / With Other Systems

**FreeDome Manager:**
- Работает вместе с калибровкой аудио/видео
- Использует данные калибровки для рекомендаций

**ZELIM Parser:**
- Автоматический анализ квантовых 3D моделей
- Извлечение метаданных для понимания

**COLLADA Parser:**
- Анализ моделей из samskara/Blender
- Интеграция с существующими 3D workflow

---

## 🧪 Тестирование / Testing

```bash
# Запуск тестов / Run tests
flutter test test/lyubomir_understanding_service_test.dart

# С покрытием / With coverage
flutter test --coverage
```

---

## 📝 SDD Документация / SDD Documentation

- [`01-requirements.md`](./01-requirements.md) - Требования и пользовательские истории
- [`02-specifications.md`](./02-specifications.md) - Архитектура и спецификации
- [`03-plan.md`](./03-plan.md) - План реализации

---

## 🤝 Вклад / Contributing

Следуйте тем же стандартам, что и в основном проекте FreeDome Manager:
- Билингвальные комментарии (RU/EN)
- Используйте `flutter analyze`
- Добавляйте тесты для нового функционала

---

**Last Updated:** 2026-02-28
**Version:** 1.0.0 (development)
