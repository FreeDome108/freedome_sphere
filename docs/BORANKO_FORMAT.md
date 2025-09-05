# 🎨 BORANKO FORMAT - Техническая документация для 2D

## 🎯 О формате .boranko

**BORANKO** (Baranko Optimized Rendering and Navigation for Komics Output) - это современный формат для 2D контента в freedome_sphere, специально разработанный для работы с комиксами и 2D графикой в купольном отображении.

## ✨ Особенности формата

### 🎨 2D Оптимизация:
- **Купольная проекция** - Специальная оптимизация для сферического отображения
- **Высокое разрешение** - Поддержка 4K и выше для четкого отображения
- **Адаптивное сжатие** - Оптимальное сжатие без потери качества
- **Многослойность** - Поддержка слоев для сложных композиций

### 🚀 Продвинутые возможности:
- **Метаданные** - Богатые метаданные для каждого элемента
- **Версионирование** - Поддержка версий и изменений
- **Совместимость** - Полная совместимость с mbharata_client
- **Производительность** - Оптимизация для мобильных устройств

## 📊 Структура файла .boranko

```json
{
  "header": {
    "format": "boranko",
    "version": "1.0.0",
    "created": "2024-01-01T00:00:00.000Z",
    "author": "Freedome Sphere",
    "compatibility": {
      "freedome_sphere": ">=1.0.0",
      "mbharata_client": ">=1.0.0"
    }
  },
  "project": {
    "id": "proj_1234567890_abc123def",
    "name": "Project Name",
    "description": "Project description",
    "author": "Author Name",
    "created": "2024-01-01T00:00:00.000Z",
    "lastModified": "2024-01-01T00:00:00.000Z",
    "domeRadius": 10,
    "projectionType": "spherical",
    "statistics": {
      "totalComics": 5,
      "totalScenes": 12,
      "totalAudioSources": 3,
      "lastExport": "2024-01-01T00:00:00.000Z"
    }
  },
  "content": {
    "comics": [
      {
        "id": "comic_1234567890_abc123def",
        "name": "Comic Name",
        "type": "comic",
        "format": "boranko",
        "domeOptimized": true,
        "pages": [
          {
            "id": "page_1",
            "index": 0,
            "type": "comic_page",
            "format": "boranko",
            "image": {
              "data": "base64_encoded_image_data",
              "format": "webp",
              "resolution": {
                "width": 4096,
                "height": 2048
              },
              "domeOptimized": true
            },
            "metadata": {
              "title": "Page Title",
              "description": "Page description",
              "created": "2024-01-01T00:00:00.000Z",
              "originalFormat": "jpg"
            }
          }
        ],
        "metadata": {
          "title": "Comic Title",
          "author": "Comic Author",
          "description": "Comic description",
          "originalFormat": "comics",
          "converted": "2024-01-01T00:00:00.000Z",
          "domeCompatible": true,
          "projectionType": "spherical"
        },
        "display": {
          "aspectRatio": "16:9",
          "resolution": {
            "width": 4096,
            "height": 2048
          },
          "sphericalMapping": true,
          "fisheyeCorrection": true
        },
        "original": {
          "path": "/path/to/original/file.comics",
          "format": "comics",
          "imported": "2024-01-01T00:00:00.000Z"
        }
      }
    ],
    "scenes": [],
    "audioSources": []
  }
}
```

## 🔧 Технические характеристики

### Изображения:
- **Формат**: WebP (оптимальный для веб)
- **Разрешение**: 4096x2048 (стандарт), до 8192x4096 (высокое качество)
- **Сжатие**: Lossless или Lossy (настраиваемое)
- **Цветовое пространство**: sRGB, Adobe RGB, P3
- **Глубина цвета**: 8-bit, 16-bit, 32-bit

### Купольная проекция:
- **Тип проекции**: Spherical, Fisheye, Equirectangular
- **Радиус купола**: 5-50 метров (настраиваемый)
- **Коррекция**: Fisheye correction, Spherical mapping
- **Оптимизация**: Специальная оптимизация для купольного отображения

### Метаданные:
- **Версионирование**: Поддержка версий и изменений
- **Теги**: Система тегов для организации
- **Статистика**: Автоматическая статистика проекта
- **Совместимость**: Информация о совместимости

## 🎨 Обработка изображений

### Конвертация в купольный формат:
```javascript
function convertToDomeFormat(imageData, domeSettings) {
    const { radius, projectionType } = domeSettings;
    
    // Применение сферической проекции
    const sphericalImage = applySphericalProjection(imageData, radius);
    
    // Коррекция fisheye
    const correctedImage = applyFisheyeCorrection(sphericalImage);
    
    // Оптимизация для купола
    const optimizedImage = optimizeForDome(correctedImage, radius);
    
    return optimizedImage;
}
```

### Оптимизация разрешения:
```javascript
function optimizeResolution(originalWidth, originalHeight, domeRadius) {
    // Базовое разрешение для купола
    const baseWidth = 4096;
    const baseHeight = 2048;
    
    // Масштабирование в зависимости от радиуса купола
    const scaleFactor = Math.min(domeRadius / 10, 2.0);
    
    return {
        width: Math.floor(baseWidth * scaleFactor),
        height: Math.floor(baseHeight * scaleFactor)
    };
}
```

## 🚀 Производительность

### Оптимизация для мобильных:
- **Сжатие**: Адаптивное сжатие в зависимости от устройства
- **Кэширование**: Интеллектуальное кэширование изображений
- **Прогрессивная загрузка**: Постепенная загрузка контента
- **Lazy loading**: Ленивая загрузка неиспользуемых элементов

### Настройки производительности:
```javascript
const performanceSettings = {
    mobile: {
        maxResolution: { width: 2048, height: 1024 },
        compression: "high",
        format: "webp"
    },
    desktop: {
        maxResolution: { width: 4096, height: 2048 },
        compression: "medium",
        format: "webp"
    },
    highEnd: {
        maxResolution: { width: 8192, height: 4096 },
        compression: "low",
        format: "webp"
    }
};
```

## 🔄 Конвертация форматов

### Поддерживаемые входные форматы:
- **.comics** - Legacy формат Баранько (только импорт)
- **.cbr/.cbz** - Архивы комиксов
- **.jpg/.png** - Стандартные изображения
- **.tiff/.exr** - Профессиональные форматы

### Процесс конвертации:
1. **Анализ** исходного формата
2. **Извлечение** изображений и метаданных
3. **Обработка** для купольного отображения
4. **Оптимизация** разрешения и сжатия
5. **Создание** структуры .boranko
6. **Сохранение** в новом формате

## 📱 Интеграция с mbharata_client

### Совместимость:
- **Формат данных**: Полная совместимость
- **Метаданные**: Поддержка всех полей
- **Изображения**: Оптимизированные для мобильных
- **Производительность**: Адаптировано для слабых устройств

### Экспорт для mbharata_client:
```javascript
function exportForMbharataClient(borankoData) {
    return {
        format: "mbp",
        version: "1.0.0",
        content: {
            comics: borankoData.content.comics.map(comic => ({
                id: comic.id,
                name: comic.name,
                pages: comic.pages.map(page => ({
                    id: page.id,
                    image: page.image.data,
                    metadata: page.metadata
                }))
            }))
        },
        metadata: {
            domeOptimized: true,
            mobileCompatible: true,
            projectionType: "spherical"
        }
    };
}
```

## 🐛 Отладка и валидация

### Валидация .boranko файла:
```javascript
function validateBorankoFile(borankoData) {
    const errors = [];
    const warnings = [];

    // Проверка заголовка
    if (!borankoData.header || borankoData.header.format !== "boranko") {
        errors.push("Неверный формат файла");
    }

    // Проверка проекта
    if (!borankoData.project) {
        errors.push("Отсутствуют данные проекта");
    }

    // Проверка контента
    if (!borankoData.content || !borankoData.content.comics) {
        warnings.push("Отсутствует контент");
    }

    return {
        valid: errors.length === 0,
        errors: errors,
        warnings: warnings
    };
}
```

### Проверка качества:
- **Разрешение**: Соответствие стандартам
- **Сжатие**: Оптимальное соотношение размер/качество
- **Метаданные**: Полнота информации
- **Совместимость**: Соответствие спецификации

## 🎯 Использование в freedome_sphere

### Создание .boranko проекта:
```javascript
const borankoFormat = new BorankoFormat();

const projectData = {
    name: "My Comic Project",
    author: "Artist Name",
    description: "Project description",
    domeRadius: 10,
    projectionType: "spherical"
};

const borankoStructure = borankoFormat.createBorankoStructure(projectData);
```

### Загрузка .boranko файла:
```javascript
const result = await ipcRenderer.invoke('load-boranko-file', filePath);

if (result.success) {
    const borankoData = result.data;
    // Обработка загруженных данных
}
```

### Сохранение в .boranko формат:
```javascript
const result = await ipcRenderer.invoke('save-boranko-file', projectData, outputPath);

if (result.success) {
    console.log('Boranko file saved:', result.path);
}
```

## 📄 Лицензия

NativeMindNONC - Все права защищены.

---

*BORANKO Format - Современный формат для 2D контента в купольном отображении*
