/**
 * Формат .zelim - Продвинутая структура хранения для freedome_sphere
 * Поддерживает импорт из устаревших форматов (.comics, .cbr, .cbz)
 * Но сохраняет только в современном формате .zelim
 */
class ZelimFormat {
    constructor() {
        this.version = "1.0.0";
        this.format = "zelim";
        this.supportedImportFormats = ['.comics', '.cbr', '.cbz'];
        this.exportFormat = '.zelim';
    }

    /**
     * Создание структуры .zelim файла
     * @param {Object} projectData - Данные проекта
     * @returns {Object} Структура .zelim
     */
    createZelimStructure(projectData) {
        return {
            // Заголовок формата
            header: {
                format: "zelim",
                version: this.version,
                created: new Date().toISOString(),
                author: "Freedome Sphere",
                compatibility: {
                    freedome_sphere: ">=1.0.0",
                    mbharata_client: ">=1.0.0"
                }
            },

            // Метаданные проекта
            project: {
                id: projectData.id || this.generateId(),
                name: projectData.name || "Untitled Project",
                description: projectData.description || "",
                tags: projectData.tags || [],
                created: projectData.created || new Date().toISOString(),
                modified: new Date().toISOString(),
                version: projectData.version || "1.0.0"
            },

            // Настройки купола
            dome: {
                radius: projectData.domeRadius || 10,
                projectionType: projectData.projectionType || "spherical",
                resolution: {
                    width: 4096,
                    height: 2048
                },
                settings: {
                    fov: 180,
                    distortion: 0.1,
                    fisheyeCorrection: true,
                    sphericalMapping: true
                }
            },

            // Контент проекта
            content: {
                // Сцены
                scenes: this.processScenes(projectData.scenes || []),
                
                // Комиксы (конвертированные в .boranko формат)
                comics: this.processComics(projectData.comics || []),
                
                // 3D модели
                models: this.processModels(projectData.models || []),
                
                // Аудио
                audio: this.processAudio(projectData.audio || []),
                
                // Анимации
                animations: this.processAnimations(projectData.animations || []),
                
                // Эффекты
                effects: this.processEffects(projectData.effects || [])
            },

            // Настройки anAntaSound
            anAntaSound: {
                enabled: true,
                spatialAudio: true,
                domeReverb: true,
                settings: {
                    roomSize: 0.5,
                    damping: 0.5,
                    wet: 0.3,
                    dry: 0.7
                },
                sources: this.processAudioSources(projectData.audio || [])
            },

            // Настройки экспорта
            export: {
                mbharata_client: {
                    enabled: true,
                    optimization: "high",
                    compression: "webp",
                    audioFormat: "ogg"
                },
                dome_projection: {
                    enabled: true,
                    formats: ["spherical", "fisheye", "equirectangular"]
                }
            },

            // Статистика
            statistics: {
                totalSize: 0,
                contentCount: {
                    scenes: 0,
                    comics: 0,
                    models: 0,
                    audio: 0,
                    animations: 0,
                    effects: 0
                },
                lastModified: new Date().toISOString()
            }
        };
    }

    /**
     * Обработка сцен для .boranko формата
     * @param {Array} scenes - Массив сцен
     * @returns {Array} Обработанные сцены
     */
    processScenes(scenes) {
        return scenes.map((scene, index) => ({
            id: scene.id || `scene_${index}`,
            name: scene.name || `Scene ${index + 1}`,
            type: scene.type || "3d",
            domeOptimized: true,
            content: scene.content || {},
            metadata: {
                ...scene.metadata,
                format: "boranko",
                domeCompatible: true,
                projectionType: "spherical"
            },
            timeline: scene.timeline || [],
            effects: scene.effects || []
        }));
    }

    /**
     * Обработка комиксов для .zelim формата
     * @param {Array} comics - Массив комиксов
     * @returns {Array} Обработанные комиксы
     */
    processComics(comics) {
        return comics.map((comic, index) => ({
            id: comic.id || `comic_${index}`,
            name: comic.name || `Comic ${index + 1}`,
            type: "comic",
            format: "zelim",
            domeOptimized: true,
            
            // Конвертированные страницы
            pages: this.convertComicPages(comic.pages || []),
            
            // Метаданные
            metadata: {
                ...comic.metadata,
                originalFormat: comic.originalFormat || "unknown",
                converted: new Date().toISOString(),
                domeCompatible: true,
                projectionType: "spherical"
            },
            
            // Настройки отображения
            display: {
                aspectRatio: "16:9",
                resolution: {
                    width: 4096,
                    height: 2048
                },
                sphericalMapping: true,
                fisheyeCorrection: true
            }
        }));
    }

    /**
     * Конвертация страниц комикса в .zelim формат
     * @param {Array} pages - Страницы комикса
     * @returns {Array} Конвертированные страницы
     */
    convertComicPages(pages) {
        return pages.map((page, index) => ({
            id: page.id || `page_${index}`,
            index: index,
            type: "comic_page",
            format: "zelim",
            
            // Конвертированное изображение
            image: {
                data: page.imageData || null,
                format: "webp",
                resolution: {
                    width: 2048,
                    height: 1024
                },
                domeOptimized: true
            },
            
            // Метаданные страницы
            metadata: {
                ...page.metadata,
                converted: new Date().toISOString(),
                originalFormat: page.originalFormat || "unknown"
            }
        }));
    }

    /**
     * Обработка 3D моделей для .zelim формата
     * @param {Array} models - Массив моделей
     * @returns {Array} Обработанные модели
     */
    processModels(models) {
        return models.map((model, index) => ({
            id: model.id || `model_${index}`,
            name: model.name || `Model ${index + 1}`,
            type: "3d_model",
            format: "zelim",
            domeOptimized: true,
            
            // Конвертированная модель
            model: {
                data: model.modelData || null,
                format: "gltf",
                compression: "draco",
                lodLevels: 3
            },
            
            // Метаданные
            metadata: {
                ...model.metadata,
                originalFormat: model.originalFormat || "unknown",
                converted: new Date().toISOString(),
                domeCompatible: true
            }
        }));
    }

    /**
     * Обработка аудио для .boranko формата
     * @param {Array} audio - Массив аудио
     * @returns {Array} Обработанное аудио
     */
    processAudio(audio) {
        return audio.map((audioItem, index) => ({
            id: audioItem.id || `audio_${index}`,
            name: audioItem.name || `Audio ${index + 1}`,
            type: "audio",
            format: "boranko",
            
            // Конвертированное аудио
            audio: {
                data: audioItem.audioData || null,
                format: "ogg",
                bitrate: 128,
                spatialAudio: true
            },
            
            // Метаданные
            metadata: {
                ...audioItem.metadata,
                originalFormat: audioItem.originalFormat || "unknown",
                converted: new Date().toISOString(),
                anAntaSound: true
            }
        }));
    }

    /**
     * Обработка анимаций для .boranko формата
     * @param {Array} animations - Массив анимаций
     * @returns {Array} Обработанные анимации
     */
    processAnimations(animations) {
        return animations.map((animation, index) => ({
            id: animation.id || `animation_${index}`,
            name: animation.name || `Animation ${index + 1}`,
            type: "animation",
            format: "boranko",
            
            // Конвертированная анимация
            animation: {
                data: animation.animationData || null,
                format: "gltf",
                duration: animation.duration || 0,
                loop: animation.loop || false
            },
            
            // Метаданные
            metadata: {
                ...animation.metadata,
                originalFormat: animation.originalFormat || "unknown",
                converted: new Date().toISOString()
            }
        }));
    }

    /**
     * Обработка эффектов для .boranko формата
     * @param {Array} effects - Массив эффектов
     * @returns {Array} Обработанные эффекты
     */
    processEffects(effects) {
        return effects.map((effect, index) => ({
            id: effect.id || `effect_${index}`,
            name: effect.name || `Effect ${index + 1}`,
            type: "effect",
            format: "boranko",
            
            // Конвертированный эффект
            effect: {
                data: effect.effectData || null,
                type: effect.effectType || "visual",
                parameters: effect.parameters || {}
            },
            
            // Метаданные
            metadata: {
                ...effect.metadata,
                originalFormat: effect.originalFormat || "unknown",
                converted: new Date().toISOString()
            }
        }));
    }

    /**
     * Обработка аудио источников anAntaSound
     * @param {Array} audio - Массив аудио
     * @returns {Array} Обработанные аудио источники
     */
    processAudioSources(audio) {
        return audio.map((audioItem, index) => ({
            id: audioItem.id || `audio_source_${index}`,
            name: audioItem.name || `Audio Source ${index + 1}`,
            type: audioItem.type || "ambient",
            position: audioItem.position || { x: 0, y: 0, z: 0 },
            volume: audioItem.volume || 0.8,
            loop: audioItem.loop || false,
            spatialAudio: true,
            anAntaSound: true
        }));
    }

    /**
     * Генерация уникального ID
     * @returns {string} Уникальный ID
     */
    generateId() {
        return `boranko_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    }

    /**
     * Валидация .boranko файла
     * @param {Object} borankoData - Данные .boranko файла
     * @returns {Object} Результат валидации
     */
    validateBorankoFile(borankoData) {
        const errors = [];
        const warnings = [];

        // Проверка заголовка
        if (!borankoData.header) {
            errors.push("Отсутствует заголовок файла");
        } else {
            if (borankoData.header.format !== "boranko") {
                errors.push("Неверный формат файла");
            }
            if (!borankoData.header.version) {
                warnings.push("Отсутствует версия формата");
            }
        }

        // Проверка проекта
        if (!borankoData.project) {
            errors.push("Отсутствуют данные проекта");
        }

        // Проверка контента
        if (!borankoData.content) {
            errors.push("Отсутствует контент");
        }

        return {
            valid: errors.length === 0,
            errors: errors,
            warnings: warnings
        };
    }

    /**
     * Обновление статистики .boranko файла
     * @param {Object} borankoData - Данные .boranko файла
     * @returns {Object} Обновленные данные
     */
    updateStatistics(borankoData) {
        const content = borankoData.content;
        
        borankoData.statistics = {
            totalSize: this.calculateTotalSize(borankoData),
            contentCount: {
                scenes: content.scenes ? content.scenes.length : 0,
                comics: content.comics ? content.comics.length : 0,
                models: content.models ? content.models.length : 0,
                audio: content.audio ? content.audio.length : 0,
                animations: content.animations ? content.animations.length : 0,
                effects: content.effects ? content.effects.length : 0
            },
            lastModified: new Date().toISOString()
        };

        return borankoData;
    }

    /**
     * Расчет общего размера контента
     * @param {Object} borankoData - Данные .boranko файла
     * @returns {number} Общий размер в байтах
     */
    calculateTotalSize(borankoData) {
        // Упрощенный расчет размера
        let totalSize = 0;
        
        if (borankoData.content) {
            const content = borankoData.content;
            
            // Размер комиксов
            if (content.comics) {
                totalSize += content.comics.length * 1024 * 1024; // ~1MB на комикс
            }
            
            // Размер моделей
            if (content.models) {
                totalSize += content.models.length * 5 * 1024 * 1024; // ~5MB на модель
            }
            
            // Размер аудио
            if (content.audio) {
                totalSize += content.audio.length * 2 * 1024 * 1024; // ~2MB на аудио
            }
        }
        
        return totalSize;
    }

    /**
     * Получение информации о формате
     * @returns {Object} Информация о формате
     */
    getFormatInfo() {
        return {
            name: "Boranko Format",
            version: this.version,
            description: "Продвинутая структура хранения для freedome_sphere",
            supportedImport: this.supportedImportFormats,
            exportFormat: this.exportFormat,
            features: [
                "Купольная оптимизация",
                "anAntaSound интеграция",
                "Многоформатный импорт",
                "Современная структура данных",
                "Совместимость с mbharata_client"
            ]
        };
    }
}

module.exports = BorankoFormat;
