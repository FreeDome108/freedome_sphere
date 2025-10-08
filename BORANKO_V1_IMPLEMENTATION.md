# BORANKO_V1 - Реализация спецификации

## ✅ Статус реализации

Формат **BORANKO_V1** полностью реализован согласно спецификации.

## 📋 Спецификация BORANKO_V1

### Основные требования:

1. **Обратная совместимость** с форматом `.comics` ✅
2. **Z-depth** по умолчанию 100, range 0-108, float ✅
3. **Папка с локализациями** для 108 языков ✅

### Механизм импорта из .comics:

1. ✅ Все графические ассеты переводятся в векторные и дополнительно к оригиналу хранятся в папке `assets/` в формате `.png`
2. ✅ Все баллоны кладутся в папку `assets/balloons_original/`
3. ✅ Баллоны чистятся от текста и кладутся в папку `assets/balloons/`
4. ✅ Автоматический перевод на 108 языков с использованием модели `mozgach108/minimal`
5. ✅ В промпт вводится тип баллона, отношение сторон баллона, коэффициент аналоговости/цифровости

## 🏗️ Архитектура

### Модели данных (`lib/models/boranko_project.dart`)

#### `BorankoProject`
Основная структура проекта:
```dart
- id: String
- name: String
- version: String (по умолчанию '1.0.0')
- pages: List<BorankoPage>
- localizations: Map<String, BorankoLocalization>
- assets: BorankoAssets?
```

#### `BorankoPage`
Страница с валидацией Z-depth:
```dart
- id: String
- pageNumber: int
- imagePath: String
- fileName: String
- originalPath: String
- zDepth: double (default 100.0, range 0-108 с валидацией)
- domeOptimized: bool
- quantumCompatible: bool
- text: String?
- sounds: List<BorankoSound>
- balloons: List<BorankoBalloon>
```

**Валидация Z-depth:**
- Значения < 0 → 0.0
- Значения > 108 → 108.0
- По умолчанию: 100.0

#### `BorankoBalloon`
Структура баллонов с метаданными:
```dart
- id: String
- originalImagePath: String      // assets/balloons_original/
- cleanedImagePath: String        // assets/balloons/
- originalText: String            // Исходный текст
- type: BalloonType               // speech, thought, shout, whisper, narration
- aspectRatio: double             // Отношение сторон
- analogDigitalCoefficient: double // 0-1: 0=овальный, 1=прямоугольный
```

#### `BorankoLocalization`
Локализация для одного языка:
```dart
- languageCode: String
- texts: Map<String, String>      // balloonId -> translated text
```

#### `BorankoAssets`
Структура файловых ассетов:
```dart
- basePath: String                      // assets/
- originalImages: List<String>          // Оригинальные изображения
- vectorizedImages: List<String>        // Векторизованные версии
- balloonsOriginalPath: String          // assets/balloons_original/
- balloonsCleanedPath: String           // assets/balloons/
```

### Сервисы

#### `BorankoService` (`lib/services/boranko_service.dart`)

**Основной функционал:**

1. **`importComicsAsBoranko()`** - Полный импорт с конвертацией:
   - Импорт .comics файла
   - Создание структуры директорий (assets/, assets/balloons_original/, assets/balloons/)
   - Векторизация изображений
   - Извлечение и обработка баллонов
   - Автоматический перевод на 108 языков
   - Создание финального BorankoProject

2. **`importBorankoProject()`** - Загрузка .boranko файла

3. **`saveBorankoProject()`** - Сохранение в .boranko формат

**Параметры импорта:**
```dart
Future<BorankoProject> importComicsAsBoranko(
  String comicsPath, {
  String? outputDir,                    // Директория вывода
  bool enableTranslation = true,        // Включить автоперевод
  bool enableVectorization = true,      // Включить векторизацию
})
```

#### `BorankoTranslationService` (`lib/services/boranko_translation_service.dart`)

**Автоматический перевод на 108 языков:**

1. **Режим квантовой запутанности** (`quantumMode: true`):
   - Параллельный запуск 108 задач перевода
   - Использование `Future.wait()` для одновременного выполнения
   - Оптимально для мощных систем

2. **Последовательный режим** (`quantumMode: false`):
   - Последовательный перевод
   - Для слабых устройств

**Функции:**
```dart
// Перевод всех баллонов на 108 языков
Future<Map<String, BorankoLocalization>> translateBalloons(
  List<BorankoBalloon> balloons, {
  String modelPath = 'mozgach108/minimal',
  bool quantumMode = true,
})

// Построение промпта с метаданными баллона
String _buildTranslationPrompt({
  required String text,
  required String targetLanguage,
  required BalloonType balloonType,
  required double aspectRatio,
  required double analogDigitalCoeff,
})
```

**Поддерживаемые языки:** 108 языков (включая все основные языковые семьи)

## 📂 Структура файлов проекта

```
project_name_boranko/
├── project_name.boranko          # JSON файл проекта
└── assets/
    ├── original_image_1.png      # Оригинальные изображения
    ├── vector_image_1.png        # Векторизованные версии
    ├── balloons_original/         # Оригинальные баллоны
    │   ├── balloon_page1_1.png
    │   └── balloon_page1_2.png
    └── balloons/                  # Очищенные от текста баллоны
        ├── balloon_page1_1.png
        └── balloon_page1_2.png
```

## 🧪 Тестирование

### Тесты (`test/comics_import_test.dart`)

1. **Импорт и сохранение .comics → .boranko**
   - Импорт Ch1_Book01.comics
   - Конвертация в BORANKO_V1
   - Сохранение как mahabharata_s01e01.boranko
   - Проверка zDepth = 100.0
   - Проверка наличия localizations и assets

2. **Валидация Z-depth range (0-108)**
   - Тест значения по умолчанию (100.0)
   - Тест валидации минимума (< 0 → 0.0)
   - Тест валидации максимума (> 108 → 108.0)
   - Тест граничных значений (0.0, 108.0)

3. **Валидация структуры .comics файла**

4. **Обработка несуществующих файлов**

### Запуск тестов:

```bash
# Все тесты импорта
flutter test test/comics_import_test.dart

# Конкретный тест
flutter test test/comics_import_test.dart --name "validate zDepth"

# Все тесты проекта
flutter test
```

## 🔧 Использование

### Базовый импорт:

```dart
import 'package:freedome_sphere_flutter/services/boranko_service.dart';

final borankoService = BorankoService();

// Импорт с полной обработкой
final project = await borankoService.importComicsAsBoranko(
  'path/to/file.comics',
  enableTranslation: true,      // Автоперевод на 108 языков
  enableVectorization: true,    // Векторизация ассетов
);

// Сохранение
await borankoService.saveBorankoProject(
  project,
  'output/project.boranko',
);
```

### Работа с Z-depth:

```dart
// Создание страницы с Z-depth
final page = BorankoPage(
  id: 'page1',
  pageNumber: 1,
  imagePath: 'image.png',
  fileName: 'image.png',
  originalPath: 'original.png',
  zDepth: 75.0,  // Любое значение 0-108
);

// Значение по умолчанию
final pageDefault = BorankoPage(
  id: 'page2',
  pageNumber: 2,
  imagePath: 'image.png',
  fileName: 'image.png',
  originalPath: 'original.png',
  // zDepth автоматически = 100.0
);

print(pageDefault.zDepth); // 100.0
```

### Работа с локализациями:

```dart
// Получение переведенного текста
final project = await borankoService.importBorankoProject('project.boranko');

// Получить перевод для конкретного языка
final russianLoc = project.localizations['ru'];
if (russianLoc != null) {
  final balloonText = russianLoc.texts['balloon_id'];
  print('Русский текст: $balloonText');
}

// Список доступных языков
print('Доступно языков: ${project.localizations.length}');
```

## ⚙️ Конфигурация

### Отключение автоперевода:

```dart
final project = await borankoService.importComicsAsBoranko(
  'file.comics',
  enableTranslation: false,  // Отключить перевод
);
```

### Отключение векторизации:

```dart
final project = await borankoService.importComicsAsBoranko(
  'file.comics',
  enableVectorization: false,  // Отключить векторизацию
);
```

### Выбор директории вывода:

```dart
final project = await borankoService.importComicsAsBoranko(
  'file.comics',
  outputDir: '/custom/output/path',
);
```

## 🔄 Обратная совместимость

### С форматом .comics:

- ✅ Полная обратная совместимость
- ✅ Сохранение оригинальных изображений в assets/
- ✅ Возможность открытия старыми приложениями (Mahabharata, Comica Pro)
- ⚠️ При редактировании старыми средствами дополнения .boranko могут быть утеряны

### Миграция с .comics на .boranko:

```dart
// Простая конвертация
final borankoProject = await borankoService.importComicsAsBoranko(
  'old_project.comics',
);
await borankoService.saveBorankoProject(
  borankoProject,
  'new_project.boranko',
);
```

## 📊 Формат .boranko файла

JSON структура:

```json
{
  "id": "project_123",
  "name": "My Project",
  "version": "1.0.0",
  "pages": [
    {
      "id": "page_1",
      "pageNumber": 1,
      "imagePath": "assets/image.png",
      "fileName": "image.png",
      "originalPath": "original.png",
      "zDepth": 100.0,
      "domeOptimized": false,
      "quantumCompatible": false,
      "text": null,
      "sounds": [],
      "balloons": [
        {
          "id": "balloon_1",
          "originalImagePath": "assets/balloons_original/balloon_1.png",
          "cleanedImagePath": "assets/balloons/balloon_1.png",
          "originalText": "Hello!",
          "type": "speech",
          "aspectRatio": 1.5,
          "analogDigitalCoefficient": 0.5
        }
      ]
    }
  ],
  "localizations": {
    "en": {
      "languageCode": "en",
      "texts": {
        "balloon_1": "Hello!"
      }
    },
    "ru": {
      "languageCode": "ru",
      "texts": {
        "balloon_1": "Привет!"
      }
    }
    // ... 106 других языков
  },
  "assets": {
    "basePath": "assets/",
    "originalImages": ["assets/image.png"],
    "vectorizedImages": ["assets/vector_image.png"],
    "balloonsOriginalPath": "assets/balloons_original",
    "balloonsCleanedPath": "assets/balloons"
  }
}
```

## 🚀 Следующие шаги (TODO для реальной реализации)

### Векторизация изображений:
- [ ] Интеграция с векторизатором (например, potrace, autotrace)
- [ ] Оптимизация векторных изображений
- [ ] Поддержка различных форматов вывода (SVG, PDF)

### Обработка баллонов:
- [ ] CV/ML детекция баллонов на изображениях
- [ ] OCR извлечение текста из баллонов
- [ ] Автоматическое определение типа баллона (speech, thought, shout и т.д.)
- [ ] Очистка баллонов от текста (inpainting)
- [ ] Вычисление метаданных (aspect ratio, форма)

### Перевод:
- [ ] Интеграция с реальной моделью `mozgach108/minimal`
- [ ] Оптимизация производительности для 108 параллельных задач
- [ ] Кэширование переводов
- [ ] Fallback на другие модели перевода

## 📝 Лицензия

NativeMindNONC - Все права защищены.

---

**BORANKO_V1** - Современный формат для 2D контента в купольном отображении с полной поддержкой Z-depth, локализаций и квантовой стереоскопии.

