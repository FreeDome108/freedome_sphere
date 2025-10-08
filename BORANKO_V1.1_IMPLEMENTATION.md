# BORANKO V1.1 - Реализация спецификации

## 🆕 Что нового в V1.1

### Основное изменение: **Звук привязывается к конкретному layer id**

### Изменения в формате файлов

1. **Основной файл проекта теперь `data.json`** (вместо `.boranko`)
2. **Звуки могут быть привязаны к конкретным слоям** через параметр `layerId`

## ✅ Статус реализации

Формат **BORANKO V1.1** полностью реализован с обратной совместимостью с V1.0.

## 📋 Спецификация BORANKO V1.1

### Структура проекта

```
project_name_boranko/
├── data.json                     # Основной файл проекта (V1.1)
└── assets/
    ├── original_image_*.png      # Оригинальные изображения
    ├── vector_image_*.png        # Векторизованные версии
    ├── balloons_original/        # Оригинальные баллоны
    │   └── balloon_*.png
    └── balloons/                 # Очищенные баллоны
        └── balloon_*.png
```

### Новая структура звука

```dart
class BorankoSound {
  final String id;
  final String soundPath;
  final double startTime;
  final double volume;
  final String? layerId;  // V1.1: Привязка к конкретному слою
}
```

## 🔄 Изменения в коде

### 1. Модель BorankoSound

**Добавлено:**
- Поле `layerId: String?` - опциональная привязка звука к слою
- Если `layerId == null`, звук воспроизводится глобально
- Если `layerId` указан, звук привязан к конкретному слою

```dart
// Глобальный звук (для всей страницы)
final globalSound = BorankoSound(
  id: 'sound_1',
  soundPath: 'ambient.mp3',
  startTime: 0.0,
  volume: 0.8,
  layerId: null,  // Глобальный
);

// Звук привязанный к слою
final layerSound = BorankoSound(
  id: 'sound_2',
  soundPath: 'dialog.mp3',
  startTime: 2.5,
  volume: 1.0,
  layerId: 'layer_character_1',  // Привязан к слою
);
```

### 2. BorankoProject - версия 1.1.0

```dart
BorankoProject({
  required this.id,
  required this.name,
  this.version = '1.1.0',  // V1.1 по умолчанию
  // ...
});
```

### 3. BorankoService - работа с data.json

#### Сохранение проекта

```dart
// Автоматически создает структуру с data.json
await borankoService.saveBorankoProject(
  project,
  'test_output/mahabharata_s01e01.boranko',
);

// Результат:
// test_output/mahabharata_s01e01_boranko/
//   └── data.json
```

**Поддерживаемые форматы путей:**

1. **`.boranko` расширение** → создает `project_boranko/data.json`
   ```dart
   saveBorankoProject(project, 'output/project.boranko')
   // Создаст: output/project_boranko/data.json
   ```

2. **Прямой путь к `data.json`**
   ```dart
   saveBorankoProject(project, 'output/project_boranko/data.json')
   // Создаст: output/project_boranko/data.json
   ```

3. **Путь к директории проекта**
   ```dart
   saveBorankoProject(project, 'output/project_boranko')
   // Создаст: output/project_boranko/data.json
   ```

#### Загрузка проекта

Поддерживает все форматы:

```dart
// Загрузка из data.json
final project1 = await borankoService.importBorankoProject(
  'project_boranko/data.json',
);

// Загрузка из директории (ищет data.json внутри)
final project2 = await borankoService.importBorankoProject(
  'project_boranko',
);

// Legacy: загрузка из .boranko файла (V1.0)
final project3 = await borankoService.importBorankoProject(
  'old_project.boranko',
);
```

## 📊 Формат data.json

```json
{
  "id": "project_123",
  "name": "mahabharata_s01e01",
  "version": "1.1.0",
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
      "sounds": [
        {
          "id": "sound_ambient",
          "soundPath": "sounds/ambient.mp3",
          "startTime": 0.0,
          "volume": 0.8,
          "layerId": "layer_background"
        },
        {
          "id": "sound_dialog",
          "soundPath": "sounds/dialog.mp3",
          "startTime": 2.5,
          "volume": 1.0,
          "layerId": "layer_character_1"
        },
        {
          "id": "sound_music",
          "soundPath": "sounds/music.mp3",
          "startTime": 0.0,
          "volume": 0.5
          // layerId отсутствует - глобальный звук
        }
      ],
      "balloons": []
    }
  ],
  "localizations": {
    "en": {
      "languageCode": "en",
      "texts": {}
    },
    "ru": {
      "languageCode": "ru",
      "texts": {}
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

## 🔧 Использование

### Создание звука с привязкой к слою

```dart
import 'package:freedome_sphere_flutter/models/boranko_project.dart';

// Звук для конкретного слоя
final layerSound = BorankoSound(
  id: 'sound_character_voice',
  soundPath: 'sounds/character_voice.mp3',
  startTime: 1.0,
  volume: 1.0,
  layerId: 'layer_character_face',  // Привязан к слою лица персонажа
);

// Глобальный фоновый звук
final ambientSound = BorankoSound(
  id: 'sound_ambient',
  soundPath: 'sounds/ambient.mp3',
  startTime: 0.0,
  volume: 0.5,
  // layerId не указан - звук глобальный
);

// Создание страницы со звуками
final page = BorankoPage(
  id: 'page_1',
  pageNumber: 1,
  imagePath: 'image.png',
  fileName: 'image.png',
  originalPath: 'original.png',
  sounds: [layerSound, ambientSound],
);
```

### Сохранение проекта V1.1

```dart
final borankoService = BorankoService();

final project = BorankoProject(
  id: 'project_1',
  name: 'My Comic',
  version: '1.1.0',  // Автоматически по умолчанию
  pages: [page],
);

// Сохраняем - автоматически создастся структура с data.json
await borankoService.saveBorankoProject(
  project,
  'output/my_comic.boranko',
);

// Результат:
// output/my_comic_boranko/
//   ├── data.json
//   └── assets/
//       ├── balloons_original/
//       └── balloons/
```

### Загрузка проекта

```dart
// Загрузка из новой структуры V1.1
final project = await borankoService.importBorankoProject(
  'output/my_comic_boranko',  // Директория проекта
);

print('Версия: ${project.version}');  // 1.1.0

// Проверка привязки звуков
for (final page in project.pages) {
  for (final sound in page.sounds) {
    if (sound.layerId != null) {
      print('Звук ${sound.id} привязан к слою ${sound.layerId}');
    } else {
      print('Звук ${sound.id} глобальный');
    }
  }
}
```

## 🔄 Обратная совместимость

### V1.0 → V1.1

```dart
// Загрузка старого проекта V1.0 (.boranko файл)
final oldProject = await borankoService.importBorankoProject(
  'old_project.boranko',
);

print('Версия: ${oldProject.version}');  // 1.0.0 или 1.1.0

// Сохранение в новом формате V1.1
await borankoService.saveBorankoProject(
  oldProject,
  'new_project.boranko',  // Создастся new_project_boranko/data.json
);
```

### Миграция звуков

```dart
// Старые звуки без layerId работают как глобальные
final oldSound = BorankoSound(
  id: 'sound_1',
  soundPath: 'audio.mp3',
  // layerId отсутствует
);

// Добавление layerId при миграции
final migratedSound = BorankoSound(
  id: oldSound.id,
  soundPath: oldSound.soundPath,
  startTime: oldSound.startTime,
  volume: oldSound.volume,
  layerId: 'layer_main',  // Добавляем привязку
);
```

## 🧪 Тестирование

### Тесты обновлены для V1.1

```dart
test('save and load project as data.json (V1.1)', () async {
  final borankoService = BorankoService();
  
  // Создаем проект V1.1 со звуками
  final project = BorankoProject(
    id: 'test_1',
    name: 'test_project',
    pages: [
      BorankoPage(
        id: 'page_1',
        pageNumber: 1,
        imagePath: 'test.png',
        fileName: 'test.png',
        originalPath: 'test.png',
        sounds: [
          BorankoSound(
            id: 'sound_1',
            soundPath: 'audio.mp3',
            layerId: 'layer_1',  // V1.1: привязка к слою
          ),
        ],
      ),
    ],
  );

  // Сохраняем
  await borankoService.saveBorankoProject(
    project,
    'test_output/test.boranko',
  );

  // Проверяем что создался data.json
  final dataJsonFile = File('test_output/test_boranko/data.json');
  expect(await dataJsonFile.exists(), isTrue);

  // Загружаем обратно
  final loadedProject = await borankoService.importBorankoProject(
    'test_output/test_boranko',
  );

  // Проверяем версию
  expect(loadedProject.version, equals('1.1.0'));

  // Проверяем layerId
  expect(
    loadedProject.pages[0].sounds[0].layerId,
    equals('layer_1'),
  );
});
```

## 📝 Ключевые отличия V1.0 vs V1.1

| Функция | V1.0 | V1.1 |
|---------|------|------|
| **Основной файл** | `.boranko` | `data.json` |
| **Версия** | 1.0.0 | 1.1.0 |
| **Привязка звуков к слоям** | ❌ Нет | ✅ Да (`layerId`) |
| **Структура директорий** | Один файл | `project_boranko/data.json` + `assets/` |
| **Обратная совместимость** | - | ✅ Читает V1.0 |

## 🎯 Примеры использования

### Пример 1: Комикс с озвучкой персонажей

```dart
final page = BorankoPage(
  id: 'page_1',
  pageNumber: 1,
  imagePath: 'page1.png',
  fileName: 'page1.png',
  originalPath: 'page1.png',
  sounds: [
    // Фоновая музыка (глобальная)
    BorankoSound(
      id: 'bgm',
      soundPath: 'sounds/background_music.mp3',
      startTime: 0.0,
      volume: 0.3,
    ),
    
    // Голос главного героя
    BorankoSound(
      id: 'hero_voice',
      soundPath: 'sounds/hero_dialog.mp3',
      startTime: 1.5,
      volume: 1.0,
      layerId: 'layer_hero',
    ),
    
    // Голос злодея
    BorankoSound(
      id: 'villain_voice',
      soundPath: 'sounds/villain_dialog.mp3',
      startTime: 3.0,
      volume: 1.0,
      layerId: 'layer_villain',
    ),
    
    // Звуковой эффект для объекта
    BorankoSound(
      id: 'sword_sound',
      soundPath: 'sounds/sword_clash.mp3',
      startTime: 5.0,
      volume: 0.8,
      layerId: 'layer_sword',
    ),
  ],
);
```

### Пример 2: Импорт с автоматическим созданием структуры

```dart
final borankoService = BorankoService();

// Импорт .comics файла
final project = await borankoService.importComicsAsBoranko(
  'mahabharata.comics',
  enableTranslation: true,
  enableVectorization: true,
);

// Автоматически создается версия 1.1.0
print('Версия проекта: ${project.version}');  // 1.1.0

// Сохранение в новом формате
await borankoService.saveBorankoProject(
  project,
  'output/mahabharata.boranko',
);

// Результат:
// output/mahabharata_boranko/
//   ├── data.json
//   └── assets/
//       ├── original_image_*.png
//       ├── vector_image_*.png
//       ├── balloons_original/
//       │   └── balloon_*.png
//       └── balloons/
//           └── balloon_*.png
```

## 📚 API Reference

### BorankoSound

```dart
class BorankoSound {
  final String id;           // Уникальный идентификатор
  final String soundPath;    // Путь к аудиофайлу
  final double startTime;    // Время начала (секунды)
  final double volume;       // Громкость 0.0-1.0
  final String? layerId;     // V1.1: ID слоя (null = глобальный)
}
```

### BorankoService

```dart
class BorankoService {
  /// Сохранить проект (создает data.json)
  Future<void> saveBorankoProject(
    BorankoProject project,
    String outputPath,
  );

  /// Загрузить проект (поддерживает V1.0 и V1.1)
  Future<BorankoProject> importBorankoProject(String importPath);

  /// Импорт из .comics с конвертацией в V1.1
  Future<BorankoProject> importComicsAsBoranko(
    String comicsPath, {
    String? outputDir,
    bool enableTranslation = true,
    bool enableVectorization = true,
  });
}
```

## 🚀 Миграция с V1.0 на V1.1

### Автоматическая миграция

```dart
// 1. Загрузить старый проект
final oldProject = await borankoService.importBorankoProject(
  'old_format.boranko',
);

// 2. Сохранить в новом формате
await borankoService.saveBorankoProject(
  oldProject,
  'new_format.boranko',
);

// Готово! Проект теперь в формате V1.1 с data.json
```

### Добавление layerId к существующим звукам

```dart
// Загружаем проект
final project = await borankoService.importBorankoProject('project.boranko');

// Обновляем звуки, добавляя layerId
final updatedPages = project.pages.map((page) {
  final updatedSounds = page.sounds.map((sound) {
    // Если звук еще не привязан к слою
    if (sound.layerId == null) {
      return BorankoSound(
        id: sound.id,
        soundPath: sound.soundPath,
        startTime: sound.startTime,
        volume: sound.volume,
        layerId: 'layer_default',  // Привязываем к дефолтному слою
      );
    }
    return sound;
  }).toList();

  return BorankoPage(
    id: page.id,
    pageNumber: page.pageNumber,
    imagePath: page.imagePath,
    fileName: page.fileName,
    originalPath: page.originalPath,
    zDepth: page.zDepth,
    sounds: updatedSounds,
    balloons: page.balloons,
  );
}).toList();

// Сохраняем обновленный проект
final updatedProject = BorankoProject(
  id: project.id,
  name: project.name,
  version: '1.1.0',
  pages: updatedPages,
  localizations: project.localizations,
  assets: project.assets,
);

await borankoService.saveBorankoProject(updatedProject, 'updated.boranko');
```

## 📝 Лицензия

NativeMindNONC - Все права защищены.

---

**BORANKO V1.1** - Современный формат для 2D контента с поддержкой привязки звуков к слоям и структурой проекта на базе `data.json`.

