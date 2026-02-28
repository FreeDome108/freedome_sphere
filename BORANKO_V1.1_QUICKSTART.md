# BORANKO V1.1 - Быстрый старт

## 🚀 Установка

BORANKO V1.1 уже встроен в `freedome_sphere_flutter`!

```yaml
# pubspec.yaml
dependencies:
  freedome_sphere_flutter: ^1.1.0
```

---

## ⚡ Быстрый старт (3 минуты)

### 1. Импорт .comics файла

```dart
import 'package:freedome_sphere_flutter/services/boranko_service.dart';

void main() async {
  final borankoService = BorankoService();
  
  // Один вызов - вся магия автоматически!
  final project = await borankoService.importComicsAsBoranko(
    'path/to/comics.comics',
  );
  
  print('Версия: ${project.version}');
  print('Страниц: ${project.pages.length}');
}
```

### 2. Проверка привязки звуков

```dart
// Проходим по всем страницам
for (final page in project.pages) {
  print('Страница ${page.pageNumber}:');
  
  // Проверяем звуки
  for (final sound in page.sounds) {
    if (sound.layerId != null) {
      // ✨ Звук привязан к слою!
      print('  🔗 ${sound.soundPath} → ${sound.layerId}');
    } else {
      // Глобальный звук
      print('  🌍 ${sound.soundPath} (глобальный)');
    }
  }
}
```

### 3. Сохранение проекта

```dart
// Сохранить в BORANKO формат
await borankoService.saveBorankoProject(
  project,
  'output/my_project.boranko',
);

// Создастся:
// output/my_project_boranko/
//   ├── data.json
//   ├── layers/
//   └── sounds/
```

---

## 📖 Примеры использования

### Пример 1: Комикс с озвучкой персонажей

```dart
final page = BorankoPage(
  id: 'page_1',
  pageNumber: 1,
  imagePath: 'layers/scene.png',
  fileName: 'scene.png',
  sounds: [
    // Фоновая музыка для всей сцены
    BorankoSound(
      id: 'bgm',
      soundPath: 'sounds/music.mp3',
      volume: 0.3,
      layerId: null,  // Глобальный звук
    ),
    
    // Голос героя привязан к его изображению
    BorankoSound(
      id: 'hero_voice',
      soundPath: 'sounds/hero.mp3',
      layerId: 'layer_hero',  // ✨ Привязан к слою!
    ),
  ],
);
```

### Пример 2: Только извлечение ассетов

```dart
final comicsService = ComicsService();

// Извлекаем layers и sounds в папку
final result = await comicsService.extractLayersAndSounds(
  'comics.comics',
  'output_dir',
);

print('Извлечено:');
print('  Layers: ${result["layersCount"]}');
print('  Sounds: ${result["soundsCount"]}');
```

### Пример 3: Ручной маппинг

```dart
final mapper = BorankoLayerSoundMapper();

// Создаем маппинг вручную
final mapping = mapper.mapSoundsToLayers(
  comicsProject.layers,
  comicsProject.sounds,
);

// Применяем маппинг
final sounds = mapper.createBorankoSounds(
  comicsProject.sounds,
  mapping,
  'sounds/',
);
```

---

## 🎯 Ключевые фишки V1.1

### 1. Автоматическая привязка звуков к слоям

```dart
// Раньше (V1.0):
BorankoSound(soundPath: 'dialog.mp3')  // Просто звук

// Теперь (V1.1):
BorankoSound(
  soundPath: 'dialog.mp3',
  layerId: 'layer_hero',  // ✨ Привязан к герою!
)
```

### 2. Умный импорт

```dart
// Автоматически определяет формат:
final project = await borankoService.importComicsAsBoranko(path);

// Если .comics с data.json → V1.1
// Если .comics без data.json → V1.0 (legacy)
```

### 3. Извлечение структуры

```
comics.comics → project_boranko/
                 ├── data.json
                 ├── layers/      # 815 файлов
                 │   ├── hero.png
                 │   ├── bg.jpg
                 │   └── ...
                 └── sounds/      # 5 файлов
                     ├── dialog.mp3
                     └── music.mp3
```

---

## 🔧 API Reference (кратко)

### BorankoService

```dart
// Импорт .comics → BORANKO
Future<BorankoProject> importComicsAsBoranko(
  String comicsPath, {
  String? outputDir,
  bool enableTranslation = true,
  bool enableVectorization = true,
})

// Загрузка BORANKO проекта
Future<BorankoProject> importBorankoProject(String path)

// Сохранение BORANKO проекта
Future<void> saveBorankoProject(BorankoProject project, String path)
```

### ComicsService

```dart
// Импорт .comics файла
Future<ComicsImportResult> importComicsFile(String path)

// Извлечение layers/ и sounds/
Future<Map<String, String>> extractLayersAndSounds(
  String comicsPath,
  String outputDir,
)
```

### BorankoLayerSoundMapper

```dart
// Создание маппинга звуков к слоям
Map<String, List<String>> mapSoundsToLayers(
  List<ComicsLayer> layers,
  List<ComicsSound> sounds,
)

// Создание звуков с layerId
List<BorankoSound> createBorankoSounds(
  List<ComicsSound> sounds,
  Map<String, List<String>> mapping,
  String soundsDir,
)
```

---

## ❓ FAQ

### Q: Что если в .comics нет data.json?
**A**: Автоматически используется legacy режим (V1.0). Все работает!

### Q: Как звуки привязываются к слоям?
**A**: На основе временных интервалов анимаций. Если слой и звук активны одновременно - они связываются.

### Q: Можно ли вручную настроить маппинг?
**A**: Да! Используйте `BorankoLayerSoundMapper` напрямую.

### Q: Поддерживается ли V1.0?
**A**: Да! Полная обратная совместимость.

### Q: Где посмотреть примеры?
**A**: `test/boranko_v11_import_test.dart` - полные рабочие примеры

---

## 📚 Дополнительная документация

- **Полная документация**: `BORANKO_V1.1_IMPLEMENTATION_COMPLETE.md`
- **Список файлов**: `BORANKO_V1.1_FILES.md`
- **Отчет**: `BORANKO_V1.1_SUMMARY.md`
- **Тесты**: `test/boranko_v11_import_test.dart`

---

## 🧪 Тестирование

```bash
# Запустить тесты
flutter test test/boranko_v11_import_test.dart

# Проверить код
flutter analyze

# Форматирование
dart format lib/ test/
```

---

## ✨ Готово!

Теперь вы можете использовать BORANKO V1.1 в своих проектах!

**Ключевые возможности**:
- ✅ Привязка звуков к слоям
- ✅ Автоматический маппинг
- ✅ Извлечение ассетов
- ✅ Обратная совместимость

**FreeDome Project** - NativeMindNONC

