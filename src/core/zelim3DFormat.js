/**
 * Формат .zelim - Продвинутый формат 3D контента для freedome_sphere
 * Специализированный формат для 3D моделей, сцен и анимаций в купольном отображении
 */
class Zelim3DFormat {
    constructor() {
        this.version = "1.0.0";
        this.format = "zelim";
        this.supportedImportFormats = ['.blend', '.fbx', '.obj', '.gltf', '.glb', '.uasset', '.umap', '.dae', '.3ds', '.max'];
        this.exportFormat = '.zelim';
        this.domeFeatures = {
            'spherical_projection': true,
            'fisheye_correction': true,
            'dome_optimization': true,
            'real_time_rendering': true,
            'mobile_optimization': true
        };
    }

    /**
     * Создание структуры .zelim файла
     * @param {Object} projectData - Данные 3D проекта
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
                    mbharata_client: ">=1.0.0",
                    three_js: ">=0.150.0"
                }
            },

            // Метаданные проекта
            project: {
                id: projectData.id || this.generateId(),
                name: projectData.name || "Untitled 3D Project",
                description: projectData.description || "",
                author: projectData.author || "Unknown",
                tags: projectData.tags || [],
                created: projectData.created || new Date().toISOString(),
                modified: new Date().toISOString(),
                version: projectData.version || "1.0.0"
            },

            // Настройки купола
            dome: {
                enabled: true,
                radius: projectData.domeRadius || 10,
                projectionType: projectData.projectionType || "spherical",
                fisheyeCorrection: true,
                sphericalMapping: true,
                optimization: {
                    level: "high",
                    mobileCompatible: true,
                    realTimeRendering: true
                }
            },

            // 3D сцена
            scene: {
                id: `scene_${Date.now()}`,
                name: "Main Scene",
                type: "3d_scene",
                format: "zelim",
                
                // Настройки камеры
                camera: {
                    type: "perspective",
                    fov: 75,
                    near: 0.1,
                    far: 1000,
                    position: { x: 0, y: 0, z: 5 },
                    target: { x: 0, y: 0, z: 0 },
                    domeOptimized: true
                },

                // Освещение
                lighting: {
                    ambient: {
                        color: "#404040",
                        intensity: 0.4
                    },
                    directional: {
                        color: "#ffffff",
                        intensity: 1.0,
                        position: { x: 10, y: 10, z: 5 },
                        castShadow: true
                    },
                    dome: {
                        enabled: true,
                        type: "spherical_lighting",
                        intensity: 0.6
                    }
                },

                // Окружение
                environment: {
                    background: {
                        type: "gradient",
                        topColor: "#87CEEB",
                        bottomColor: "#98FB98"
                    },
                    fog: {
                        enabled: false,
                        color: "#ffffff",
                        near: 1,
                        far: 100
                    }
                }
            },

            // 3D модели
            models: this.processModels(projectData.models || []),

            // Анимации
            animations: this.processAnimations(projectData.animations || []),

            // Материалы
            materials: this.processMaterials(projectData.materials || []),

            // Текстуры
            textures: this.processTextures(projectData.textures || []),

            // Физика
            physics: {
                enabled: projectData.physicsEnabled || false,
                gravity: { x: 0, y: -9.81, z: 0 },
                world: {
                    broadphase: "sap",
                    solver: "gs"
                },
                bodies: projectData.physicsBodies || []
            },

            // Интерактивность
            interactivity: {
                enabled: projectData.interactivityEnabled || false,
                controls: {
                    orbit: true,
                    zoom: true,
                    pan: true,
                    dome: true
                },
                events: projectData.events || []
            },

            // Производительность
            performance: {
                lod: {
                    enabled: true,
                    levels: [
                        { distance: 10, quality: "high" },
                        { distance: 50, quality: "medium" },
                        { distance: 100, quality: "low" }
                    ]
                },
                culling: {
                    frustum: true,
                    occlusion: false
                },
                optimization: {
                    instancing: true,
                    batching: true,
                    compression: "draco"
                }
            },

            // Статистика
            statistics: {
                totalModels: 0,
                totalTriangles: 0,
                totalVertices: 0,
                totalTextures: 0,
                totalAnimations: 0,
                fileSize: 0,
                domeOptimized: true,
                mobileCompatible: true,
                lastModified: new Date().toISOString()
            }
        };
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
            
            // Геометрия
            geometry: {
                type: model.geometryType || "buffer",
                data: model.geometryData || null,
                format: "gltf",
                compressed: true,
                compression: "draco"
            },
            
            // Материалы
            materials: model.materials || [],
            
            // Трансформация
            transform: {
                position: model.position || { x: 0, y: 0, z: 0 },
                rotation: model.rotation || { x: 0, y: 0, z: 0 },
                scale: model.scale || { x: 1, y: 1, z: 1 }
            },
            
            // Купольная оптимизация
            dome: {
                optimized: true,
                projectionType: "spherical",
                fisheyeCorrection: true,
                lod: {
                    enabled: true,
                    levels: 3
                }
            },
            
            // Метаданные
            metadata: {
                originalFormat: model.originalFormat || "unknown",
                converted: new Date().toISOString(),
                domeCompatible: true,
                mobileOptimized: true,
                triangles: model.triangles || 0,
                vertices: model.vertices || 0
            }
        }));
    }

    /**
     * Обработка анимаций для .zelim формата
     * @param {Array} animations - Массив анимаций
     * @returns {Array} Обработанные анимации
     */
    processAnimations(animations) {
        return animations.map((animation, index) => ({
            id: animation.id || `anim_${index}`,
            name: animation.name || `Animation ${index + 1}`,
            type: "animation",
            format: "zelim",
            
            // Анимационные данные
            data: {
                duration: animation.duration || 1.0,
                fps: animation.fps || 30,
                tracks: animation.tracks || [],
                format: "keyframe"
            },
            
            // Настройки воспроизведения
            playback: {
                loop: animation.loop || false,
                autoStart: animation.autoStart || false,
                speed: animation.speed || 1.0
            },
            
            // Купольная оптимизация
            dome: {
                optimized: true,
                sphericalMapping: true
            },
            
            // Метаданные
            metadata: {
                originalFormat: animation.originalFormat || "unknown",
                converted: new Date().toISOString(),
                domeCompatible: true
            }
        }));
    }

    /**
     * Обработка материалов для .zelim формата
     * @param {Array} materials - Массив материалов
     * @returns {Array} Обработанные материалы
     */
    processMaterials(materials) {
        return materials.map((material, index) => ({
            id: material.id || `mat_${index}`,
            name: material.name || `Material ${index + 1}`,
            type: "material",
            format: "zelim",
            
            // Свойства материала
            properties: {
                type: material.type || "standard",
                color: material.color || "#ffffff",
                metalness: material.metalness || 0.0,
                roughness: material.roughness || 0.5,
                emissive: material.emissive || "#000000",
                transparent: material.transparent || false,
                opacity: material.opacity || 1.0
            },
            
            // Текстуры
            textures: {
                map: material.map || null,
                normalMap: material.normalMap || null,
                roughnessMap: material.roughnessMap || null,
                metalnessMap: material.metalnessMap || null,
                emissiveMap: material.emissiveMap || null
            },
            
            // Купольная оптимизация
            dome: {
                optimized: true,
                sphericalMapping: true
            },
            
            // Метаданные
            metadata: {
                originalFormat: material.originalFormat || "unknown",
                converted: new Date().toISOString(),
                domeCompatible: true
            }
        }));
    }

    /**
     * Обработка текстур для .zelim формата
     * @param {Array} textures - Массив текстур
     * @returns {Array} Обработанные текстуры
     */
    processTextures(textures) {
        return textures.map((texture, index) => ({
            id: texture.id || `tex_${index}`,
            name: texture.name || `Texture ${index + 1}`,
            type: "texture",
            format: "zelim",
            
            // Данные текстуры
            data: {
                format: "webp",
                resolution: texture.resolution || { width: 1024, height: 1024 },
                data: texture.data || null,
                compressed: true
            },
            
            // Настройки текстуры
            settings: {
                wrapS: texture.wrapS || "repeat",
                wrapT: texture.wrapT || "repeat",
                minFilter: texture.minFilter || "linear",
                magFilter: texture.magFilter || "linear",
                generateMipmaps: texture.generateMipmaps || true
            },
            
            // Купольная оптимизация
            dome: {
                optimized: true,
                sphericalMapping: true,
                fisheyeCorrection: true
            },
            
            // Метаданные
            metadata: {
                originalFormat: texture.originalFormat || "unknown",
                converted: new Date().toISOString(),
                domeCompatible: true
            }
        }));
    }

    /**
     * Конвертация 3D контента в .zelim формат
     * @param {Object} content3D - 3D контент
     * @returns {Object} Конвертированный контент в .zelim формате
     */
    convertToZelimFormat(content3D) {
        return {
            id: content3D.id || this.generateId(),
            name: content3D.name || "Converted 3D Content",
            type: "3d_content",
            format: "zelim",
            domeOptimized: true,
            
            // 3D данные
            scene: {
                models: this.processModels(content3D.models || []),
                animations: this.processAnimations(content3D.animations || []),
                materials: this.processMaterials(content3D.materials || []),
                textures: this.processTextures(content3D.textures || [])
            },
            
            // Купольные настройки
            dome: {
                radius: content3D.domeRadius || 10,
                projectionType: "spherical",
                fisheyeCorrection: true,
                optimization: "high"
            },
            
            // Метаданные
            metadata: {
                originalFormat: content3D.originalFormat || "unknown",
                converted: new Date().toISOString(),
                domeCompatible: true,
                mobileOptimized: true
            }
        };
    }

    /**
     * Обработка для купольного отображения
     * @param {Object} zelimData - Данные .zelim файла
     * @param {Object} domeSettings - Настройки купола
     * @returns {Object} Обработанные данные
     */
    processForDome(zelimData, domeSettings) {
        return {
            ...zelimData,
            dome: {
                ...zelimData.dome,
                radius: domeSettings.radius || 10,
                projectionType: domeSettings.projectionType || "spherical",
                fisheyeCorrection: true,
                sphericalMapping: true,
                optimization: {
                    level: "high",
                    mobileCompatible: true,
                    realTimeRendering: true
                }
            },
            scene: {
                ...zelimData.scene,
                camera: {
                    ...zelimData.scene.camera,
                    domeOptimized: true,
                    fov: this.calculateDomeFOV(domeSettings.radius)
                }
            }
        };
    }

    /**
     * Расчет FOV для купольного отображения
     * @param {number} domeRadius - Радиус купола
     * @returns {number} FOV в градусах
     */
    calculateDomeFOV(domeRadius) {
        // Оптимальный FOV для купольного отображения
        const baseFOV = 75;
        const radiusFactor = Math.min(domeRadius / 10, 2.0);
        return Math.floor(baseFOV * radiusFactor);
    }

    /**
     * Валидация .zelim файла
     * @param {Object} zelimData - Данные .zelim файла
     * @returns {Object} Результат валидации
     */
    validateZelimFile(zelimData) {
        const errors = [];
        const warnings = [];

        // Проверка заголовка
        if (!zelimData.header) {
            errors.push("Отсутствует заголовок файла");
        } else {
            if (zelimData.header.format !== "zelim") {
                errors.push("Неверный формат файла");
            }
            if (!zelimData.header.version) {
                warnings.push("Отсутствует версия формата");
            }
        }

        // Проверка проекта
        if (!zelimData.project) {
            errors.push("Отсутствуют данные проекта");
        }

        // Проверка сцены
        if (!zelimData.scene) {
            errors.push("Отсутствуют данные сцены");
        }

        // Проверка купольных настроек
        if (!zelimData.dome) {
            warnings.push("Отсутствуют настройки купола");
        }

        return {
            valid: errors.length === 0,
            errors: errors,
            warnings: warnings
        };
    }

    /**
     * Генерация уникального ID
     * @returns {string} Уникальный ID
     */
    generateId() {
        return `zelim_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    }

    /**
     * Получение информации о формате
     * @returns {Object} Информация о формате
     */
    getFormatInfo() {
        return {
            name: "Zelim 3D Format",
            version: this.version,
            description: "Продвинутый формат 3D контента для купольного отображения",
            supportedImport: this.supportedImportFormats,
            exportFormat: this.exportFormat,
            features: [
                "3D модели и сцены",
                "Анимации и ключевые кадры",
                "Материалы и текстуры",
                "Купольная проекция",
                "Мобильная оптимизация",
                "Real-time рендеринг",
                "Физика и интерактивность"
            ],
            domeFeatures: this.domeFeatures
        };
    }
}

module.exports = Zelim3DFormat;
