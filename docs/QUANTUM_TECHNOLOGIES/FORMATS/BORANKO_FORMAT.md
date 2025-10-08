>>>
V1

Обратно с совместим с форматом .comics

Дополнения, не влияющие на работу оригинала:
1. Z - detph (По дефолту 100, range 0-108, float)
2. Папка с локализациями 

Механизм импорта из .comics
1. Все графические ассеты переводятся в векторные и дополнительно к оригиналу хранятся в папке assets в формате .png
2. Все баллуны кладутся в папку assetst/balloons_original/
3. Балуны чистятся от текста и кладутся в папку assets/balloons/


Обратная совместимость работает так, что при попытке воспроизвести или редактировать старыми средлствами - приложегнием Mahabharata и Comica Pro - Действия возможны, но они работают с оригинальными картинками, а дополнения .boranko могут быть утеряны (не известно как работают легаси приложения)


Далее Boranko V2

<<< До сюда не редактировать




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
- **Z-Depth поддержка** - Возможность добавления глубины к плоским изображениям для создания 3D купольных эффектов
- **Квантовая стереоскопия** - Преобразование 2D контента в объемный купольный контент с квантовыми резонансами
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

### 🎭 Z-Depth и 3D купольные эффекты:
- **Z-Depth карты**: Поддержка карт глубины для создания объемности из плоских изображений
- **Квантовая стереоскопия**: Автоматическое преобразование 2D в 3D с использованием квантовых алгоритмов
- **Параллакс эффекты**: Создание эффекта глубины при движении камеры в купольном пространстве
- **Объемное освещение**: Симуляция объемного освещения для усиления 3D эффекта
- **Квантовые резонансы**: Интеграция с системой anAntaSound для создания иммерсивного 3D опыта

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

## 🎭 Работа с Z-Depth и 3D эффектами

### Создание Z-Depth карты:
```javascript
function createZDepthMap(imageData, depthSettings) {
    const { intensity, blur, contrast } = depthSettings;
    
    // Анализ изображения для определения глубины
    const depthMap = analyzeImageDepth(imageData);
    
    // Применение квантовых алгоритмов для улучшения глубины
    const quantumDepth = applyQuantumDepthEnhancement(depthMap, {
        resonanceFrequency: 528, // Гц сольфеджио
        quantumElements: 108,
        coherence: 0.8
    });
    
    // Создание финальной Z-Depth карты
    return {
        depthMap: quantumDepth,
        metadata: {
            intensity: intensity,
            blur: blur,
            contrast: contrast,
            quantumEnhanced: true
        }
    };
}
```

### Применение 3D купольных эффектов:
```javascript
function applyDome3DEffects(borankoData, zDepthMap) {
    return {
        ...borankoData,
        content: {
            ...borankoData.content,
            comics: borankoData.content.comics.map(comic => ({
                ...comic,
                pages: comic.pages.map(page => ({
                    ...page,
                    zDepth: {
                        enabled: true,
                        depthMap: zDepthMap.depthMap,
                        parallaxStrength: 0.5,
                        volumetricLighting: true,
                        quantumResonance: {
                            frequency: 528,
                            amplitude: 0.3,
                            coherence: 0.8
                        }
                    },
                    display: {
                        ...page.display,
                        dome3D: true,
                        stereoscopic: true,
                        volumetricEffects: true
                    }
                }))
            }))
        }
    };
}
```

### Квантовая стереоскопия:
```javascript
function createQuantumStereoscopy(flatImage, zDepthMap) {
    const leftEye = createStereoscopicView(flatImage, zDepthMap, -0.03); // Левый глаз
    const rightEye = createStereoscopicView(flatImage, zDepthMap, 0.03);  // Правый глаз
    
    // Применение квантовых резонансов для улучшения стереоскопии
    const quantumStereo = applyQuantumStereoEnhancement(leftEye, rightEye, {
        resonanceFrequency: 741, // Гц сольфеджио для зрения
        quantumElements: 108,
        coherence: 0.9
    });
    
    return {
        leftEye: quantumStereo.left,
        rightEye: quantumStereo.right,
        metadata: {
            quantumEnhanced: true,
            domeOptimized: true,
            anAntaSoundIntegrated: true
        }
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

## 🆚 Преимущества .boranko над .comic

### Ключевые отличия:

| Функция | .comic (Legacy) | .boranko (Современный) |
|---------|-----------------|------------------------|
| **Z-Depth поддержка** | ❌ Отсутствует | ✅ Полная поддержка с квантовыми алгоритмами |
| **3D купольные эффекты** | ❌ Только плоские изображения | ✅ Объемные эффекты с параллаксом и стереоскопией |
| **Квантовая стереоскопия** | ❌ Не поддерживается | ✅ Автоматическое преобразование 2D→3D |
| **Купольная оптимизация** | ⚠️ Базовая | ✅ Специальная оптимизация для куполов |
| **Метаданные** | ⚠️ Ограниченные | ✅ Богатые метаданные и версионирование |
| **Производительность** | ⚠️ Устаревшая | ✅ Оптимизация для мобильных устройств |
| **Совместимость** | ⚠️ Только legacy mbharata | ✅ Полная совместимость с mbharata_client |

### 🎭 Z-Depth революция:
Формат .boranko в отличие от формата .comic позволяет добавить к объектам **z-depth** (глубину), что позволяет сделать из плоских картинок **купольный контент с 3D эффектами**. Это называется **"Квантовая стереоскопия"** - технология, которая автоматически анализирует плоские изображения и создает карты глубины для преобразования их в объемный купольный контент.

### 🚀 Технические преимущества:
- **Объемное освещение**: Симуляция реалистичного освещения в 3D пространстве
- **Параллакс эффекты**: Создание ощущения глубины при движении камеры
- **Квантовые резонансы**: Интеграция с системой anAntaSound для иммерсивного опыта
- **Автоматическая оптимизация**: Адаптация под различные размеры куполов
- **Мобильная совместимость**: Оптимизация для слабых устройств

## 📄 Лицензия

NativeMindNONC - Все права защищены.

---

*BORANKO Format - Современный формат для 2D контента в купольном отображении с поддержкой Z-Depth и 3D эффектов*
