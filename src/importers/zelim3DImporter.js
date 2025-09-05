const fs = require('fs');
const path = require('path');
const Zelim3DFormat = require('../core/zelim3DFormat');

/**
 * Импортер 3D контента для freedome_sphere
 * 
 * Поддерживает импорт из различных 3D форматов:
 * - Blender (.blend)
 * - FBX (.fbx)
 * - OBJ (.obj)
 * - glTF (.gltf, .glb)
 * - Unreal Engine (.uasset, .umap)
 * - 3DS Max (.max)
 * - Collada (.dae)
 * - 3DS (.3ds)
 * 
 * Конвертирует в современный формат .zelim для 3D
 */
class Zelim3DImporter {
    constructor() {
        this.supportedImportFormats = [
            '.blend', '.fbx', '.obj', '.gltf', '.glb', 
            '.uasset', '.umap', '.dae', '.3ds', '.max'
        ];
        this.exportFormat = '.zelim';
        this.importedContent = [];
        this.zelimFormat = new Zelim3DFormat();
        
        console.log('🎮 Zelim3DImporter initialized');
        console.log(`📁 Supported formats: ${this.supportedImportFormats.join(', ')}`);
        console.log(`💾 Export format: ${this.exportFormat}`);
    }

    /**
     * Импорт 3D контента из папки
     * @param {string} folderPath - Путь к папке с 3D файлами
     * @returns {Promise<Object>} Результат импорта
     */
    async importFromFolder(folderPath) {
        try {
            console.log(`🎮 Импорт 3D контента из папки: ${folderPath}`);
            
            const files = fs.readdirSync(folderPath);
            const contentFiles = files.filter(file => 
                this.supportedImportFormats.some(format => file.toLowerCase().endsWith(format))
            );

            const importedContent = [];

            for (const file of contentFiles) {
                const filePath = path.join(folderPath, file);
                const content = await this.importContent(filePath);
                if (content) {
                    importedContent.push(content);
                }
            }

            this.importedContent = [...this.importedContent, ...importedContent];

            return {
                success: true,
                count: importedContent.length,
                content: importedContent,
                message: `Успешно импортировано ${importedContent.length} 3D файлов`
            };

        } catch (error) {
            console.error('❌ Ошибка импорта 3D контента:', error);
            return {
                success: false,
                error: error.message,
                message: 'Ошибка при импорте 3D контента'
            };
        }
    }

    /**
     * Импорт отдельного 3D файла
     * @param {string} filePath - Путь к 3D файлу
     * @returns {Promise<Object>} Импортированный контент
     */
    async importContent(filePath) {
        try {
            const fileName = path.basename(filePath);
            const fileExt = path.extname(filePath).toLowerCase();
            
            console.log(`🎮 Импорт 3D файла: ${fileName}`);

            let contentData;

            switch (fileExt) {
                case '.blend':
                    contentData = await this.parseBlenderFile(filePath);
                    break;
                case '.fbx':
                    contentData = await this.parseFBXFile(filePath);
                    break;
                case '.obj':
                    contentData = await this.parseOBJFile(filePath);
                    break;
                case '.gltf':
                case '.glb':
                    contentData = await this.parseGLTFFile(filePath);
                    break;
                case '.uasset':
                case '.umap':
                    contentData = await this.parseUnrealFile(filePath);
                    break;
                case '.dae':
                    contentData = await this.parseColladaFile(filePath);
                    break;
                case '.3ds':
                    contentData = await this.parse3DSFile(filePath);
                    break;
                case '.max':
                    contentData = await this.parseMaxFile(filePath);
                    break;
                default:
                    throw new Error(`Неподдерживаемый формат: ${fileExt}`);
            }

            // Конвертация в .zelim формат
            const zelimContent = this.convertToZelimFormat({
                id: Date.now() + Math.random(),
                name: fileName,
                originalPath: filePath,
                originalFormat: fileExt,
                imported: new Date().toISOString(),
                ...contentData
            });

            console.log(`✅ 3D файл импортирован: ${fileName}`);
            return zelimContent;

        } catch (error) {
            console.error(`❌ Ошибка импорта 3D файла ${filePath}:`, error);
            return null;
        }
    }

    /**
     * Парсинг Blender файла (.blend)
     * @param {string} filePath - Путь к файлу
     * @returns {Promise<Object>} Данные файла
     */
    async parseBlenderFile(filePath) {
        console.log(`🎨 Парсинг Blender файла: ${filePath}`);
        
        // Здесь должна быть реальная логика парсинга .blend файлов
        // Пока возвращаем mock данные
        return {
            type: 'blender_scene',
            models: [
                {
                    name: 'Blender Model',
                    geometryType: 'mesh',
                    triangles: 1000,
                    vertices: 500,
                    materials: ['default_material']
                }
            ],
            materials: [
                {
                    name: 'default_material',
                    type: 'principled',
                    color: '#ffffff',
                    metalness: 0.0,
                    roughness: 0.5
                }
            ],
            animations: [],
            textures: []
        };
    }

    /**
     * Парсинг FBX файла
     * @param {string} filePath - Путь к файлу
     * @returns {Promise<Object>} Данные файла
     */
    async parseFBXFile(filePath) {
        console.log(`📦 Парсинг FBX файла: ${filePath}`);
        
        return {
            type: 'fbx_scene',
            models: [
                {
                    name: 'FBX Model',
                    geometryType: 'mesh',
                    triangles: 2000,
                    vertices: 1000,
                    materials: ['fbx_material']
                }
            ],
            materials: [
                {
                    name: 'fbx_material',
                    type: 'standard',
                    color: '#cccccc',
                    metalness: 0.1,
                    roughness: 0.3
                }
            ],
            animations: [
                {
                    name: 'FBX Animation',
                    duration: 2.0,
                    fps: 30,
                    tracks: []
                }
            ],
            textures: []
        };
    }

    /**
     * Парсинг OBJ файла
     * @param {string} filePath - Путь к файлу
     * @returns {Promise<Object>} Данные файла
     */
    async parseOBJFile(filePath) {
        console.log(`📐 Парсинг OBJ файла: ${filePath}`);
        
        return {
            type: 'obj_model',
            models: [
                {
                    name: 'OBJ Model',
                    geometryType: 'mesh',
                    triangles: 500,
                    vertices: 250,
                    materials: ['obj_material']
                }
            ],
            materials: [
                {
                    name: 'obj_material',
                    type: 'basic',
                    color: '#ff0000',
                    metalness: 0.0,
                    roughness: 1.0
                }
            ],
            animations: [],
            textures: []
        };
    }

    /**
     * Парсинг glTF файла
     * @param {string} filePath - Путь к файлу
     * @returns {Promise<Object>} Данные файла
     */
    async parseGLTFFile(filePath) {
        console.log(`🌟 Парсинг glTF файла: ${filePath}`);
        
        return {
            type: 'gltf_scene',
            models: [
                {
                    name: 'glTF Model',
                    geometryType: 'buffer',
                    triangles: 3000,
                    vertices: 1500,
                    materials: ['gltf_material']
                }
            ],
            materials: [
                {
                    name: 'gltf_material',
                    type: 'pbr',
                    color: '#00ff00',
                    metalness: 0.5,
                    roughness: 0.2
                }
            ],
            animations: [
                {
                    name: 'glTF Animation',
                    duration: 3.0,
                    fps: 60,
                    tracks: []
                }
            ],
            textures: [
                {
                    name: 'glTF Texture',
                    resolution: { width: 1024, height: 1024 },
                    format: 'jpg'
                }
            ]
        };
    }

    /**
     * Парсинг Unreal Engine файла
     * @param {string} filePath - Путь к файлу
     * @returns {Promise<Object>} Данные файла
     */
    async parseUnrealFile(filePath) {
        console.log(`🎮 Парсинг Unreal Engine файла: ${filePath}`);
        
        return {
            type: 'unreal_scene',
            models: [
                {
                    name: 'Unreal Model',
                    geometryType: 'static_mesh',
                    triangles: 5000,
                    vertices: 2500,
                    materials: ['unreal_material']
                }
            ],
            materials: [
                {
                    name: 'unreal_material',
                    type: 'unlit',
                    color: '#0000ff',
                    metalness: 0.8,
                    roughness: 0.1
                }
            ],
            animations: [],
            textures: [
                {
                    name: 'Unreal Texture',
                    resolution: { width: 2048, height: 2048 },
                    format: 'png'
                }
            ]
        };
    }

    /**
     * Парсинг Collada файла (.dae)
     * @param {string} filePath - Путь к файлу
     * @returns {Promise<Object>} Данные файла
     */
    async parseColladaFile(filePath) {
        console.log(`🎭 Парсинг Collada файла: ${filePath}`);
        
        return {
            type: 'collada_scene',
            models: [
                {
                    name: 'Collada Model',
                    geometryType: 'mesh',
                    triangles: 1500,
                    vertices: 750,
                    materials: ['collada_material']
                }
            ],
            materials: [
                {
                    name: 'collada_material',
                    type: 'lambert',
                    color: '#ffff00',
                    metalness: 0.0,
                    roughness: 0.8
                }
            ],
            animations: [
                {
                    name: 'Collada Animation',
                    duration: 1.5,
                    fps: 24,
                    tracks: []
                }
            ],
            textures: []
        };
    }

    /**
     * Парсинг 3DS файла
     * @param {string} filePath - Путь к файлу
     * @returns {Promise<Object>} Данные файла
     */
    async parse3DSFile(filePath) {
        console.log(`📊 Парсинг 3DS файла: ${filePath}`);
        
        return {
            type: '3ds_model',
            models: [
                {
                    name: '3DS Model',
                    geometryType: 'mesh',
                    triangles: 800,
                    vertices: 400,
                    materials: ['3ds_material']
                }
            ],
            materials: [
                {
                    name: '3ds_material',
                    type: 'standard',
                    color: '#ff00ff',
                    metalness: 0.2,
                    roughness: 0.6
                }
            ],
            animations: [],
            textures: []
        };
    }

    /**
     * Парсинг 3DS Max файла (.max)
     * @param {string} filePath - Путь к файлу
     * @returns {Promise<Object>} Данные файла
     */
    async parseMaxFile(filePath) {
        console.log(`🎯 Парсинг 3DS Max файла: ${filePath}`);
        
        return {
            type: 'max_scene',
            models: [
                {
                    name: 'Max Model',
                    geometryType: 'mesh',
                    triangles: 4000,
                    vertices: 2000,
                    materials: ['max_material']
                }
            ],
            materials: [
                {
                    name: 'max_material',
                    type: 'standard',
                    color: '#00ffff',
                    metalness: 0.3,
                    roughness: 0.4
                }
            ],
            animations: [
                {
                    name: 'Max Animation',
                    duration: 4.0,
                    fps: 30,
                    tracks: []
                }
            ],
            textures: [
                {
                    name: 'Max Texture',
                    resolution: { width: 512, height: 512 },
                    format: 'bmp'
                }
            ]
        };
    }

    /**
     * Конвертация в .zelim формат
     * @param {Object} content3D - 3D контент
     * @returns {Object} Конвертированный контент
     */
    convertToZelimFormat(content3D) {
        return {
            id: content3D.id,
            name: content3D.name,
            type: '3d_content',
            format: 'zelim',
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
                radius: 10,
                projectionType: 'spherical',
                fisheyeCorrection: true,
                optimization: 'high'
            },
            
            // Метаданные
            metadata: {
                originalFormat: content3D.originalFormat,
                converted: new Date().toISOString(),
                domeCompatible: true,
                mobileOptimized: true
            },
            
            // Информация об оригинале
            original: {
                path: content3D.originalPath,
                format: content3D.originalFormat,
                imported: content3D.imported
            }
        };
    }

    /**
     * Обработка моделей
     * @param {Array} models - Массив моделей
     * @returns {Array} Обработанные модели
     */
    processModels(models) {
        return models.map((model, index) => ({
            id: model.id || `model_${index}`,
            name: model.name || `Model ${index + 1}`,
            type: '3d_model',
            format: 'zelim',
            domeOptimized: true,
            
            geometry: {
                type: model.geometryType || 'buffer',
                triangles: model.triangles || 0,
                vertices: model.vertices || 0,
                format: 'zelim',
                compressed: true
            },
            
            materials: model.materials || [],
            
            transform: {
                position: { x: 0, y: 0, z: 0 },
                rotation: { x: 0, y: 0, z: 0 },
                scale: { x: 1, y: 1, z: 1 }
            },
            
            dome: {
                optimized: true,
                projectionType: 'spherical',
                fisheyeCorrection: true
            },
            
            metadata: {
                originalFormat: 'unknown',
                converted: new Date().toISOString(),
                domeCompatible: true,
                mobileOptimized: true
            }
        }));
    }

    /**
     * Обработка анимаций
     * @param {Array} animations - Массив анимаций
     * @returns {Array} Обработанные анимации
     */
    processAnimations(animations) {
        return animations.map((animation, index) => ({
            id: animation.id || `anim_${index}`,
            name: animation.name || `Animation ${index + 1}`,
            type: 'animation',
            format: 'zelim',
            
            data: {
                duration: animation.duration || 1.0,
                fps: animation.fps || 30,
                tracks: animation.tracks || [],
                format: 'keyframe'
            },
            
            playback: {
                loop: false,
                autoStart: false,
                speed: 1.0
            },
            
            dome: {
                optimized: true,
                sphericalMapping: true
            },
            
            metadata: {
                originalFormat: 'unknown',
                converted: new Date().toISOString(),
                domeCompatible: true
            }
        }));
    }

    /**
     * Обработка материалов
     * @param {Array} materials - Массив материалов
     * @returns {Array} Обработанные материалы
     */
    processMaterials(materials) {
        return materials.map((material, index) => ({
            id: material.id || `mat_${index}`,
            name: material.name || `Material ${index + 1}`,
            type: 'material',
            format: 'zelim',
            
            properties: {
                type: material.type || 'standard',
                color: material.color || '#ffffff',
                metalness: material.metalness || 0.0,
                roughness: material.roughness || 0.5,
                emissive: '#000000',
                transparent: false,
                opacity: 1.0
            },
            
            textures: {
                map: null,
                normalMap: null,
                roughnessMap: null,
                metalnessMap: null,
                emissiveMap: null
            },
            
            dome: {
                optimized: true,
                sphericalMapping: true
            },
            
            metadata: {
                originalFormat: 'unknown',
                converted: new Date().toISOString(),
                domeCompatible: true
            }
        }));
    }

    /**
     * Обработка текстур
     * @param {Array} textures - Массив текстур
     * @returns {Array} Обработанные текстуры
     */
    processTextures(textures) {
        return textures.map((texture, index) => ({
            id: texture.id || `tex_${index}`,
            name: texture.name || `Texture ${index + 1}`,
            type: 'texture',
            format: 'zelim',
            
            data: {
                format: 'webp',
                resolution: texture.resolution || { width: 1024, height: 1024 },
                data: null,
                compressed: true
            },
            
            settings: {
                wrapS: 'repeat',
                wrapT: 'repeat',
                minFilter: 'linear',
                magFilter: 'linear',
                generateMipmaps: true
            },
            
            dome: {
                optimized: true,
                sphericalMapping: true,
                fisheyeCorrection: true
            },
            
            metadata: {
                originalFormat: texture.format || 'unknown',
                converted: new Date().toISOString(),
                domeCompatible: true
            }
        }));
    }

    /**
     * Сохранение в .zelim формате
     * @param {Object} content3D - 3D контент
     * @param {string} outputPath - Путь для сохранения
     * @returns {Promise<Object>} Результат сохранения
     */
    async saveAsZelim(content3D, outputPath) {
        try {
            console.log(`💾 Сохранение 3D контента в .zelim формате: ${outputPath}`);
            
            // Создание структуры .zelim
            const zelimData = this.zelimFormat.createZelimStructure(content3D);
            
            // Обработка для купольного отображения
            const domeProcessed = this.zelimFormat.processForDome(zelimData, {
                radius: 10,
                projectionType: 'spherical'
            });
            
            // Сохранение файла
            fs.writeFileSync(outputPath, JSON.stringify(domeProcessed, null, 2));
            
            console.log(`✅ 3D контент сохранен в .zelim формате: ${outputPath}`);
            
            return {
                success: true,
                path: outputPath,
                format: 'zelim',
                message: '3D контент сохранен в формате .zelim'
            };
            
        } catch (error) {
            console.error('❌ Ошибка сохранения .zelim файла:', error);
            return {
                success: false,
                error: error.message,
                message: 'Ошибка сохранения в формате .zelim'
            };
        }
    }

    /**
     * Загрузка .zelim файла
     * @param {string} filePath - Путь к .zelim файлу
     * @returns {Promise<Object>} Данные .zelim файла
     */
    async loadFromZelim(filePath) {
        try {
            console.log(`📁 Загрузка .zelim файла: ${filePath}`);
            
            const zelimData = JSON.parse(fs.readFileSync(filePath, 'utf8'));
            
            // Валидация .zelim файла
            const validation = this.zelimFormat.validateZelimFile(zelimData);
            if (!validation.valid) {
                throw new Error(`Неверный формат .zelim: ${validation.errors.join(', ')}`);
            }
            
            console.log(`✅ .zelim файл загружен: ${zelimData.project.name}`);
            return zelimData;
            
        } catch (error) {
            console.error('❌ Ошибка загрузки .zelim файла:', error);
            throw error;
        }
    }

    /**
     * Экспорт для mbharata_client
     * @param {Object} zelimContent - .zelim контент
     * @returns {Object} Контент для mbharata_client
     */
    exportForMbharataClient(zelimContent) {
        return {
            format: 'mbp',
            version: '1.0.0',
            type: '3d_content',
            content: {
                scene: zelimContent.scene,
                dome: zelimContent.dome,
                models: zelimContent.scene.models,
                animations: zelimContent.scene.animations,
                materials: zelimContent.scene.materials,
                textures: zelimContent.scene.textures
            },
            metadata: {
                domeOptimized: true,
                mobileCompatible: true,
                projectionType: 'spherical',
                originalFormat: 'zelim'
            }
        };
    }

    /**
     * Получение информации о поддерживаемых форматах
     * @returns {Object} Информация о форматах
     */
    getSupportedFormats() {
        return {
            import: this.supportedImportFormats,
            export: this.exportFormat,
            description: '3D контент для купольного отображения'
        };
    }
}

module.exports = Zelim3DImporter;
