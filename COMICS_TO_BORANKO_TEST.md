# Comics to Boranko Import Test

## Описание

Добавлен тест для импорта `.comics` файлов и сохранения их в формате `.boranko`. Тест демонстрирует полный цикл конвертации комиксов из архивного формата в формат Boranko для использования в FreeDome Sphere.

## Что было реализовано

### 1. Обновлен BorankoService

- **Добавлен метод `saveBorankoProject()`** - сохраняет проект Boranko в JSON файл
- **Улучшен метод `importBorankoProject()`** - теперь корректно загружает сохраненные `.boranko` файлы
- **Исправлена конвертация** из ComicsProject в BorankoProject

### 2. Создан тест импорта комиксов

Файл: `test/comics_import_test.dart`

**Основной тест**: 
- Импортирует `samples/import/comics/Ch1_Book01.comics`
- Конвертирует в BorankoProject
- Сохраняет как `mahabharata_s01e01.boranko`
- Проверяет корректность сохранения и возможность повторной загрузки

**Дополнительные тесты**:
- Валидация структуры .comics файла
- Обработка ошибок при отсутствующих файлах

### 3. Обновлен test runner

Добавлен новый тест в `test/test_runner.dart` для интеграции с общим набором тестов.

## Результат тестирования

Тест успешно:
- ✅ Импортировал 815 страниц из `Ch1_Book01.comics`
- ✅ Конвертировал в формат Boranko
- ✅ Сохранил как `mahabharata_s01e01.boranko` (238KB)
- ✅ Загрузил сохраненный файл обратно

## Структура созданного .boranko файла

```json
{
  "id": "unique-uuid",
  "name": "mahabharata_s01e01",
  "version": "1.0.0",
  "pages": [
    {
      "id": "unique-page-id",
      "pageNumber": 1,
      "imagePath": "layers/10_1_1000_0_0.png",
      "fileName": "layers/10_1_1000_0_0.png",
      "originalPath": "samples/import/comics/Ch1_Book01.comics",
      "zDepth": 0.0,
      "domeOptimized": false,
      "quantumCompatible": false,
      "text": null,
      "sounds": []
    }
    // ... 814 других страниц
  ]
}
```

## Запуск тестов

```bash
# Запуск только тестов импорта комиксов
flutter test test/comics_import_test.dart

# Запуск всех тестов
flutter test test/test_runner.dart
```

## Использование в коде

```dart
final borankoService = BorankoService();

// Импорт и конвертация
final project = await borankoService.importComicsAsBoranko('path/to/file.comics');

// Сохранение
await borankoService.saveBorankoProject(project, 'output/project.boranko');

// Загрузка
final loadedProject = await borankoService.importBorankoProject('output/project.boranko');
```
