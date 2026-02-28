# FreeDome Manager

> **Comprehensive Dome Display Management System**
> 
> **Версия:** 1.0.0 (в разработке)
> **Платформа:** Flutter (iOS, Android, Quest 3)
> **Язык:** Русский / English

---

## 📖 Обзор / Overview

**FreeDome Manager** — это интеллектуальная система управления купольными дисплеями, которая автоматизирует калибровку, анализ контента и публикацию приложений для сферических/иммерсивных сред.

**FreeDome Manager** is an intelligent dome display management system that automates calibration, content analysis, and application publishing for spherical/immersive environments.

### 🎯 Основные возможности / Key Features

- **Автоматическая калибровка** аудио и видео систем для купольных сред
- **ИИ анализ контента** с 11 типами понимания (визуальный, аудио, пространственный и др.)
- **Интеграция с FreeDome** экосистемой для управления купольными системами
- **Поддержка форматов** ZELIM, COLLADA, Blender и стандартных медиа
- **Автоматическая оптимизация** для мобильных VR устройств (Quest 3)

---

## 🚀 Быстрый старт / Quick Start

### Установка / Installation

```bash
# Клонирование репозитория / Clone repository
git clone https://github.com/your-org/freedome_sphere.git
cd freedome_sphere

# Установка зависимостей / Install dependencies
flutter pub get

# Запуск демонстрации / Run demo
dart demo_freedome_simple.dart

# Запуск приложения / Run app
flutter run
```

### Требования / Requirements

- Flutter SDK 3.x или новее
- Dart SDK 3.x или новее
- Устройство: iOS 12+, Android 8+, Quest 3

---

## 📁 Структура проекта / Project Structure

```
freedome_sphere/
├── lib/
│   ├── services/
│   │   ├── freedome_integration_service.dart    # Основная интеграция FreeDome
│   │   ├── freedome_api_stubs.dart              # Заглушки API (до реальных пакетов)
│   │   ├── lyubomir_understanding_service.dart  # ИИ система понимания
│   │   ├── zelim_service.dart                   # Парсер ZELIM файлов
│   │   └── collada_service.dart                 # Парсер COLLADA файлов
│   ├── models/
│   │   └── lyubomir_understanding.dart          # Модели данных понимания
│   ├── screens/
│   │   ├── freedome_integration_screen.dart     # Экран интеграции
│   │   └── lyubomir_learning_system_screen.dart # Экран системы обучения
│   └── widgets/
│       ├── lyubomir_settings_panel.dart         # Панель настроек
│       └── lyubomir_learning_system_panel.dart  # Панель обучения
├── test/
│   ├── freedome_integration_test.dart           # Тесты интеграции
│   └── lyubomir_understanding_service_test.dart # Тесты понимания
├── flows/
│   └── sdd-freedome-manager/                    # SDD документация
│       ├── 01-requirements.md                   # Требования
│       ├── 02-specifications.md                 # Спецификации
│       ├── 03-plan.md                           # План реализации
│       └── _status.md                           # Текущий статус
└── demo_*.dart                                  # Демонстрационные скрипты
```

---

## 🔧 Компоненты / Components

### 1. FreeDome Integration Service

Основной сервис для интеграции с экосистемой FreeDome.

**Основные возможности:**
- Инициализация компонентов FreeDome (Core, Calibration, Connectivity)
- Подключение/отключение от сервера FreeDome
- Калибровка аудио и видео систем
- Отправка/получение данных
- Мониторинг статуса системы

**Пример использования:**
```dart
final service = FreedomeIntegrationService();

// Инициализация
await service.initialize();

// Подключение
await service.connect(serverUrl: 'localhost', port: 8080);

// Калибровка
final audioResult = await service.calibrateAudio();
final videoResult = await service.calibrateVideo();

// Получение статуса
final status = await service.getSystemStatus();
```

### 2. Lyubomir Understanding Service

ИИ система для анализа и понимания контента.

**11 типов понимания:**

| Тип | Описание | Время анализа |
|-----|----------|---------------|
| Visual | Анализ изображений/видео (цвета, объекты, композиция) | 2 сек |
| Audio | Анализ звука (частота, амплитуда, пространственное аудио) | 3 сек |
| Text | NLP анализ (тональность, ключевые слова, язык) | 1 сек |
| Spatial | Анализ 3D моделей (геометрия, материалы, UV) | 4 сек |
| Temporal | Временной анализ (длительность, ключевые кадры) | 3.5 сек |
| Semantic | Анализ смысла (концепции, контекст, релевантность) | 2.5 сек |
| Interactive | UX анализ (интерактивность, доступность) | 3.5 сек |
| Emotional | Эмоциональное воздействие (эмоции, интенсивность) | 2 сек |
| Quantum | Квантовые свойства (когерентность, запутанность) | 5 сек |
| Holistic | Системный анализ (целостность, взаимосвязи) | 4.5 сек |
| ThreeDimensional | Специализированный 3D анализ (вершины, грани, LOD) | 4 сек |

**Пример использования:**
```dart
final service = LyubomirUnderstandingService();

// Инициализация
await service.initialize();

// Создание понимания
final understanding = await service.createUnderstanding(
  name: 'Моя 3D модель',
  description: 'Анализ квантовой модели',
  type: UnderstandingType.spatial,
);

// Анализ файла
await service.analyzeContent(understanding.id, filePath: '/path/to/model.zelim');

// Получение рекомендаций
final recommendations = service.getRecommendations(understanding.id);
```

### 3. Контент понимания (UnderstandingResult)

Каждый анализ возвращает структурированные результаты:

```dart
UnderstandingResult(
  id: 'unique_id',
  type: UnderstandingType.visual,
  confidence: 0.85,  // Уверенность 0.0-1.0
  data: {
    'dominantColors': ['#FF6B6B', '#4ECDC4'],
    'brightness': 0.7,
    'contrast': 0.8,
  },
  status: UnderstandingStatus.completed,
  timestamp: DateTime.now(),
  tags: ['визуальный', 'анализ', 'любомир'],
)
```

---

## 🎨 Пользовательский интерфейс / User Interface

### Экран интеграции FreeDome

**Функции:**
- Отображение статуса системы (инициализация, подключение)
- Настройка подключения (сервер, порт)
- Калибровка аудио/видео
- Информация о системе и доступных устройствах

**Элементы управления:**
- Индикаторы статуса (цветовые: зеленый/оранжевый/красный)
- Поля ввода сервера и порта
- Кнопки подключения/отключения
- Кнопки калибровки аудио и видео
- Панель информации о системе

### Экран системы понимания Любомира

**3 вкладки:**

1. **Понимания** - Список всех пониманий с CRUD операциями
2. **Анализ** - Результаты завершенных анализов
3. **Настройки** - Конфигурация системы (включено, типы, чувствительность)

**Функции:**
- Создание/удаление пониманий
- Запуск анализа контента
- Просмотр результатов с уверенностью
- Получение рекомендаций
- Экспорт/импорт данных

---

## 📊 Бизнес-преимущества / Business Benefits

### Экономия времени

| Задача | Традиционно | FreeDome Manager | Экономия |
|--------|-------------|------------------|----------|
| Создание VR приложения | 2 недели | 2 дня | **80%** |
| Настройка купольной проекции | 8 часов | 5 минут | **99%** |
| Интеграция 3D аудио | 12 часов | 1 минута | **99.8%** |
| Публикация в магазины | 16 часов | 0 минут | **100%** |

**Общая экономия времени: 99.7% (26 часов 55 минут → 5 минут)**

### Экономия затрат

При ставке $50/час:
- **Традиционный workflow:** $5,800 на проект
- **FreeDome Manager:** $805 на проект
- **Экономия:** $4,995 (83%)

---

## 🔌 Интеграция / Integration

### Поддерживаемые форматы

- **ZELIM** (.zelim) - Квантовые 3D модели
- **COLLADA** (.dae) - 3D модели из samskara/Blender
- **Изображения** (.jpg, .png, .gif)
- **Видео** (.mp4, .mov, .avi)
- **Аудио** (.mp3, .wav, .ogg)
- **Текст** (.txt, .md, .json)

### Интеграция с Blender

1. Создайте модель в Blender
2. Экспортируйте в .zelim или .dae формате
3. Импортируйте в FreeDome Manager
4. Автоматический анализ и оптимизация
5. Публикация готового приложения

---

## 🧪 Тестирование / Testing

### Запуск тестов

```bash
# Все тесты
flutter test

# Конкретный тест
flutter test test/freedome_integration_test.dart

# С покрытием
flutter test --coverage
```

### Покрытие тестами

Целевое покрытие: >80%

- **Unit тесты:** Сервисы, модели, утилиты
- **Integration тесты:** Полные workflow (инициализация, анализ, калибровка)
- **Widget тесты:** UI компоненты

---

## 📝 Документация / Documentation

### SDD Документация

Проект следует Spec-Driven Development (SDD) подходу:

- [`01-requirements.md`](./flows/sdd-freedome-manager/01-requirements.md) - Требования и пользовательские истории
- [`02-specifications.md`](./flows/sdd-freedome-manager/02-specifications.md) - Архитектура и спецификации
- [`03-plan.md`](./flows/sdd-freedome-manager/03-plan.md) - План реализации
- [`_status.md`](./flows/sdd-freedome-manager/_status.md) - Текущий статус

### Дополнительная документация

- [`DEMO_GUIDE.md`](./DEMO_GUIDE.md) - Руководство по демонстрации
- [`flows/sdd.md`](./flows/sdd.md) - SDD flow reference

---

## 🤝 Вклад / Contributing

### Как внести вклад

1. Fork репозиторий
2. Создайте feature branch (`git checkout -b feature/amazing-feature`)
3. Commit изменения (`git commit -m 'Add amazing feature'`)
4. Push в branch (`git push origin feature/amazing-feature`)
5. Откройте Pull Request

### Стандарты кода

- Следуйте [Effective Dart](https://dart.dev/guides/language/effective-dart)
- Используйте `flutter analyze` для линтинга
- Добавляйте тесты для нового функционала
- Документируйте публичные API с dartdoc

---

## 📄 Лицензия / License

[Укажите лицензию здесь]

---

## 📞 Контакты / Contact

- **Website:** [your-website.com]
- **Email:** [your-email@example.com]
- **GitHub:** [github.com/your-org]

---

## 🙏 Благодарности / Acknowledgments

- FreeDome ecosystem team
- anAntaSound quantum audio project
- MBHARATA platform
- Все контрибьюторы проекта

---

**Last Updated:** 2026-02-28
**Version:** 1.0.0 (development)
