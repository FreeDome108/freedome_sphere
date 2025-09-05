# 🎮 ZELIM FORMAT - Техническая документация для 3D

## 🎯 О формате .zelim

**ZELIM** (Z-axis Enhanced Lighting and Interactive Models) - это современный формат для 3D контента в freedome_sphere, специально разработанный для работы с 3D моделями, сценами и анимациями в купольном отображении.

## ✨ Особенности формата

### 🎮 3D Оптимизация:
- **Купольная проекция** - Специальная оптимизация для сферического отображения
- **Real-time рендеринг** - Оптимизация для интерактивного отображения
- **Мобильная совместимость** - Адаптация для слабых устройств
- **Физика и интерактивность** - Поддержка физических симуляций

### 🚀 Продвинутые возможности:
- **Многослойные сцены** - Сложные 3D композиции
- **Анимации** - Ключевые кадры и скелетная анимация
- **Материалы PBR** - Физически корректные материалы
- **Освещение** - Продвинутые системы освещения
- **LOD система** - Автоматическое упрощение на расстоянии

## 📊 Структура файла .zelim

```json
{
  "header": {
    "format": "zelim",
    "version": "1.0.0",
    "created": "2024-01-01T00:00:00.000Z",
    "author": "Freedome Sphere",
    "compatibility": {
      "freedome_sphere": ">=1.0.0",
      "mbharata_client": ">=1.0.0",
      "three_js": ">=0.150.0"
    }
  },
  "project": {
    "id": "zelim_1234567890_abc123def",
    "name": "3D Project Name",
    "description": "Project description",
    "author": "Author Name",
    "tags": ["3d", "interactive", "dome"],
    "created": "2024-01-01T00:00:00.000Z",
    "modified": "2024-01-01T00:00:00.000Z",
    "version": "1.0.0"
  },
  "dome": {
    "enabled": true,
    "radius": 10,
    "projectionType": "spherical",
    "fisheyeCorrection": true,
    "sphericalMapping": true,
    "optimization": {
      "level": "high",
      "mobileCompatible": true,
      "realTimeRendering": true
    }
  },
  "scene": {
    "id": "scene_1234567890",
    "name": "Main Scene",
    "type": "3d_scene",
    "format": "zelim",
    "camera": {
      "type": "perspective",
      "fov": 75,
      "near": 0.1,
      "far": 1000,
      "position": { "x": 0, "y": 0, "z": 5 },
      "target": { "x": 0, "y": 0, "z": 0 },
      "domeOptimized": true
    },
    "lighting": {
      "ambient": {
        "color": "#404040",
        "intensity": 0.4
      },
      "directional": {
        "color": "#ffffff",
        "intensity": 1.0,
        "position": { "x": 10, "y": 10, "z": 5 },
        "castShadow": true
      },
      "dome": {
        "enabled": true,
        "type": "spherical_lighting",
        "intensity": 0.6
      }
    },
    "environment": {
      "background": {
        "type": "gradient",
        "topColor": "#87CEEB",
        "bottomColor": "#98FB98"
      },
      "fog": {
        "enabled": false,
        "color": "#ffffff",
        "near": 1,
        "far": 100
      }
    }
  },
  "models": [
    {
      "id": "model_1234567890",
      "name": "3D Model",
      "type": "3d_model",
      "format": "zelim",
      "domeOptimized": true,
      "geometry": {
        "type": "buffer",
        "data": "compressed_geometry_data",
        "format": "gltf",
        "compressed": true,
        "compression": "draco"
      },
      "materials": ["material_1"],
      "transform": {
        "position": { "x": 0, "y": 0, "z": 0 },
        "rotation": { "x": 0, "y": 0, "z": 0 },
        "scale": { "x": 1, "y": 1, "z": 1 }
      },
      "dome": {
        "optimized": true,
        "projectionType": "spherical",
        "fisheyeCorrection": true,
        "lod": {
          "enabled": true,
          "levels": 3
        }
      },
      "metadata": {
        "originalFormat": "blend",
        "converted": "2024-01-01T00:00:00.000Z",
        "domeCompatible": true,
        "mobileOptimized": true,
        "triangles": 10000,
        "vertices": 5000
      }
    }
  ],
  "animations": [
    {
      "id": "anim_1234567890",
      "name": "Model Animation",
      "type": "animation",
      "format": "zelim",
      "data": {
        "duration": 2.0,
        "fps": 30,
        "tracks": [],
        "format": "keyframe"
      },
      "playback": {
        "loop": false,
        "autoStart": false,
        "speed": 1.0
      },
      "dome": {
        "optimized": true,
        "sphericalMapping": true
      },
      "metadata": {
        "originalFormat": "blend",
        "converted": "2024-01-01T00:00:00.000Z",
        "domeCompatible": true
      }
    }
  ],
  "materials": [
    {
      "id": "mat_1234567890",
      "name": "PBR Material",
      "type": "material",
      "format": "zelim",
      "properties": {
        "type": "standard",
        "color": "#ffffff",
        "metalness": 0.0,
        "roughness": 0.5,
        "emissive": "#000000",
        "transparent": false,
        "opacity": 1.0
      },
      "textures": {
        "map": "texture_1",
        "normalMap": null,
        "roughnessMap": null,
        "metalnessMap": null,
        "emissiveMap": null
      },
      "dome": {
        "optimized": true,
        "sphericalMapping": true
      },
      "metadata": {
        "originalFormat": "blend",
        "converted": "2024-01-01T00:00:00.000Z",
        "domeCompatible": true
      }
    }
  ],
  "textures": [
    {
      "id": "tex_1234567890",
      "name": "Diffuse Texture",
      "type": "texture",
      "format": "zelim",
      "data": {
        "format": "webp",
        "resolution": { "width": 1024, "height": 1024 },
        "data": "base64_encoded_texture_data",
        "compressed": true
      },
      "settings": {
        "wrapS": "repeat",
        "wrapT": "repeat",
        "minFilter": "linear",
        "magFilter": "linear",
        "generateMipmaps": true
      },
      "dome": {
        "optimized": true,
        "sphericalMapping": true,
        "fisheyeCorrection": true
      },
      "metadata": {
        "originalFormat": "png",
        "converted": "2024-01-01T00:00:00.000Z",
        "domeCompatible": true
      }
    }
  ],
  "physics": {
    "enabled": false,
    "gravity": { "x": 0, "y": -9.81, "z": 0 },
    "world": {
      "broadphase": "sap",
      "solver": "gs"
    },
    "bodies": []
  },
  "interactivity": {
    "enabled": false,
    "controls": {
      "orbit": true,
      "zoom": true,
      "pan": true,
      "dome": true
    },
    "events": []
  },
  "performance": {
    "lod": {
      "enabled": true,
      "levels": [
        { "distance": 10, "quality": "high" },
        { "distance": 50, "quality": "medium" },
        { "distance": 100, "quality": "low" }
      ]
    },
    "culling": {
      "frustum": true,
      "occlusion": false
    },
    "optimization": {
      "instancing": true,
      "batching": true,
      "compression": "draco"
    }
  },
  "statistics": {
    "totalModels": 1,
    "totalTriangles": 10000,
    "totalVertices": 5000,
    "totalTextures": 1,
    "totalAnimations": 1,
    "fileSize": 0,
    "domeOptimized": true,
    "mobileCompatible": true,
    "lastModified": "2024-01-01T00:00:00.000Z"
  }
}
```

## 🔧 Технические характеристики

### 3D Модели:
- **Геометрия**: BufferGeometry, CompressedGeometry
- **Сжатие**: Draco (до 90% уменьшения размера)
- **LOD**: Автоматическое упрощение на расстоянии
- **Инстансинг**: Повторное использование геометрии
- **Батчинг**: Группировка объектов для производительности

### Материалы:
- **PBR**: Физически корректные материалы
- **Типы**: Standard, Principled, Unlit, Toon
- **Свойства**: Metalness, Roughness, Emissive, Transparency
- **Текстуры**: Diffuse, Normal, Roughness, Metalness, Emissive

### Анимации:
- **Типы**: Keyframe, Skeletal, Morphing
- **Форматы**: JSON, Binary
- **Сжатие**: Quantized keyframes
- **Оптимизация**: Удаление избыточных кадров

### Освещение:
- **Типы**: Ambient, Directional, Point, Spot
- **Купольное освещение**: Специальные алгоритмы для купола
- **Тени**: Real-time shadow mapping
- **Глобальное освещение**: IBL, Light probes

## 🎮 Купольная оптимизация

### Проекция:
```javascript
function applyDomeProjection(geometry, domeRadius) {
    const vertices = geometry.attributes.position.array;
    
    for (let i = 0; i < vertices.length; i += 3) {
        const x = vertices[i];
        const y = vertices[i + 1];
        const z = vertices[i + 2];
        
        // Сферическая проекция
        const radius = Math.sqrt(x*x + y*y + z*z);
        const theta = Math.atan2(y, x);
        const phi = Math.acos(z / radius);
        
        // Коррекция для купола
        const domeX = domeRadius * Math.sin(phi) * Math.cos(theta);
        const domeY = domeRadius * Math.sin(phi) * Math.sin(theta);
        const domeZ = domeRadius * Math.cos(phi);
        
        vertices[i] = domeX;
        vertices[i + 1] = domeY;
        vertices[i + 2] = domeZ;
    }
    
    geometry.attributes.position.needsUpdate = true;
}
```

### LOD система:
```javascript
function createLODLevels(model, distances) {
    const lod = new THREE.LOD();
    
    distances.forEach((distance, index) => {
        const simplified = simplifyGeometry(model.geometry, index);
        lod.addLevel(simplified, distance);
    });
    
    return lod;
}

function simplifyGeometry(geometry, level) {
    const ratio = Math.pow(0.5, level); // 1.0, 0.5, 0.25, 0.125
    return simplify(geometry, ratio);
}
```

## 🚀 Производительность

### Оптимизация для мобильных:
- **Геометрия**: Упрощение до 1000-5000 треугольников
- **Текстуры**: Разрешение до 512x512
- **Материалы**: Упрощенные шейдеры
- **Анимации**: Снижение FPS до 30

### Настройки производительности:
```javascript
const performanceSettings = {
    mobile: {
        maxTriangles: 5000,
        maxTextureSize: 512,
        maxLights: 2,
        shadowQuality: "low"
    },
    desktop: {
        maxTriangles: 50000,
        maxTextureSize: 2048,
        maxLights: 8,
        shadowQuality: "high"
    },
    highEnd: {
        maxTriangles: 200000,
        maxTextureSize: 4096,
        maxLights: 16,
        shadowQuality: "ultra"
    }
};
```

## 🔄 Конвертация форматов

### Поддерживаемые входные форматы:
- **Blender**: .blend (нативные файлы)
- **FBX**: .fbx (Autodesk)
- **OBJ**: .obj (Wavefront)
- **glTF**: .gltf, .glb (Khronos)
- **Unreal Engine**: .uasset, .umap
- **3DS Max**: .max
- **Collada**: .dae
- **3DS**: .3ds

### Процесс конвертации:
1. **Анализ** исходного формата
2. **Извлечение** геометрии, материалов, анимаций
3. **Оптимизация** для купольного отображения
4. **Сжатие** геометрии и текстур
5. **Создание** LOD уровней
6. **Сохранение** в формате .zelim

## 📱 Интеграция с mbharata_client

### Совместимость:
- **Формат данных**: Полная совместимость
- **Производительность**: Оптимизация для мобильных
- **Купольное отображение**: Нативная поддержка
- **Интерактивность**: Ограниченная для мобильных

### Экспорт для mbharata_client:
```javascript
function exportForMbharataClient(zelimData) {
    return {
        format: "mbp",
        version: "1.0.0",
        type: "3d_content",
        content: {
            scene: zelimData.scene,
            dome: zelimData.dome,
            models: zelimData.models.map(model => ({
                id: model.id,
                name: model.name,
                geometry: model.geometry,
                materials: model.materials,
                transform: model.transform
            })),
            animations: zelimData.animations,
            materials: zelimData.materials,
            textures: zelimData.textures
        },
        metadata: {
            domeOptimized: true,
            mobileCompatible: true,
            projectionType: "spherical",
            originalFormat: "zelim"
        }
    };
}
```

## 🐛 Отладка и валидация

### Валидация .zelim файла:
```javascript
function validateZelimFile(zelimData) {
    const errors = [];
    const warnings = [];

    // Проверка заголовка
    if (!zelimData.header || zelimData.header.format !== "zelim") {
        errors.push("Неверный формат файла");
    }

    // Проверка проекта
    if (!zelimData.project) {
        errors.push("Отсутствуют данные проекта");
    }

    // Проверка сцены
    if (!zelimData.scene) {
        errors.push("Отсутствуют данные сцены");
    }

    // Проверка моделей
    if (!zelimData.models || zelimData.models.length === 0) {
        warnings.push("Отсутствуют 3D модели");
    }

    return {
        valid: errors.length === 0,
        errors: errors,
        warnings: warnings
    };
}
```

### Проверка производительности:
- **Количество треугольников**: Соответствие лимитам
- **Размер текстур**: Оптимальное разрешение
- **Количество источников света**: Ограничения платформы
- **Сложность материалов**: Упрощение для мобильных

## 🎯 Использование в freedome_sphere

### Создание .zelim проекта:
```javascript
const zelimFormat = new Zelim3DFormat();

const projectData = {
    name: "My 3D Project",
    author: "Artist Name",
    description: "3D scene for dome display",
    domeRadius: 10,
    projectionType: "spherical"
};

const zelimStructure = zelimFormat.createZelimStructure(projectData);
```

### Загрузка .zelim файла:
```javascript
const result = await ipcRenderer.invoke('load-zelim-file', filePath);

if (result.success) {
    const zelimData = result.data;
    // Обработка загруженных данных
}
```

### Сохранение в .zelim формат:
```javascript
const result = await ipcRenderer.invoke('save-zelim-file', content3D, outputPath);

if (result.success) {
    console.log('Zelim file saved:', result.path);
}
```

## 📄 Лицензия

NativeMindNONC - Все права защищены.

---

*ZELIM Format - Современный формат для 3D контента в купольном отображении*
