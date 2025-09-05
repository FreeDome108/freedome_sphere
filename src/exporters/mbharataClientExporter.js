const fs = require('fs');
const path = require('path');

/**
 * Экспортер для mbharata_client
 * Создает пакеты совместимые с мобильным приложением mbharata
 */
class MbharataClientExporter {
    constructor() {
        this.supportedFormats = ['.mbp', '.json'];
        this.exportSettings = {
            compression: 'high',
            quality: 'high',
            domeOptimization: true,
            audioOptimization: true
        };
    }

    /**
     * Экспорт проекта в формат mbharata_client
     * @param {Object} projectData - Данные проекта
     * @param {string} outputPath - Путь для сохранения
     * @returns {Promise<Object>} Результат экспорта
     */
    async exportProject(projectData, outputPath) {
        try {
            console.log(`📱 Экспорт проекта в mbharata_client: ${outputPath}`);

            // Валидация данных проекта
            const validatedProject = this.validateProjectData(projectData);
            
            // Создание пакета mbharata_client
            const mbharataPackage = this.createMbharataPackage(validatedProject);
            
            // Оптимизация для мобильных устройств
            const optimizedPackage = await this.optimizeForMobile(mbharataPackage);
            
            // Сохранение пакета
            await this.savePackage(optimizedPackage, outputPath);
            
            // Создание метаданных
            const metadata = this.createMetadata(optimizedPackage, outputPath);
            
            return {
                success: true,
                path: outputPath,
                metadata: metadata,
                message: 'Проект успешно экспортирован в mbharata_client'
            };

        } catch (error) {
            console.error('❌ Ошибка экспорта в mbharata_client:', error);
            return {
                success: false,
                error: error.message,
                message: 'Ошибка при экспорте проекта'
            };
        }
    }

    /**
     * Валидация данных проекта
     * @param {Object} projectData - Данные проекта
     * @returns {Object} Валидированные данные
     */
    validateProjectData(projectData) {
        const required = ['name', 'domeRadius', 'projectionType'];
        
        for (const field of required) {
            if (!projectData[field]) {
                throw new Error(`Отсутствует обязательное поле: ${field}`);
            }
        }

        return {
            name: projectData.name || 'Untitled Project',
            domeRadius: projectData.domeRadius || 10,
            projectionType: projectData.projectionType || 'spherical',
            scenes: projectData.scenes || [],
            audio: projectData.audio || [],
            comics: projectData.comics || [],
            created: projectData.created || new Date().toISOString(),
            version: projectData.version || '1.0.0'
        };
    }

    /**
     * Создание пакета mbharata_client
     * @param {Object} projectData - Данные проекта
     * @returns {Object} Пакет для mbharata_client
     */
    createMbharataPackage(projectData) {
        return {
            // Метаданные пакета
            packageInfo: {
                version: "1.0.0",
                type: "dome_content",
                format: "mbharata_client",
                created: new Date().toISOString(),
                author: "Freedome Sphere",
                compatibility: {
                    mbharata_client: ">=1.0.0",
                    dome_systems: ["spherical", "fisheye", "equirectangular"]
                }
            },

            // Метаданные проекта
            project: {
                name: projectData.name,
                domeRadius: projectData.domeRadius,
                projectionType: projectData.projectionType,
                created: projectData.created,
                version: projectData.version
            },

            // Контент
            content: {
                scenes: this.processScenes(projectData.scenes),
                audio: this.processAudio(projectData.audio),
                comics: this.processComics(projectData.comics)
            },

            // Настройки купола
            domeSettings: {
                radius: projectData.domeRadius,
                projectionType: projectData.projectionType,
                resolution: {
                    width: 4096,
                    height: 2048
                },
                fov: 180,
                distortion: 0.1
            },

            // Настройки аудио
            audioSettings: {
                spatialAudio: true,
                anAntaSound: true,
                sources: projectData.audio.length,
                format: 'spatial_3d'
            }
        };
    }

    /**
     * Обработка сцен для mbharata_client
     * @param {Array} scenes - Массив сцен
     * @returns {Array} Обработанные сцены
     */
    processScenes(scenes) {
        return scenes.map((scene, index) => ({
            id: scene.id || index,
            name: scene.name || `Scene ${index + 1}`,
            type: scene.type || '3d',
            domeOptimized: true,
            content: scene.content || {},
            metadata: {
                ...scene.metadata,
                domeCompatible: true,
                projectionType: 'spherical'
            }
        }));
    }

    /**
     * Обработка аудио для mbharata_client
     * @param {Array} audio - Массив аудио источников
     * @returns {Array} Обработанные аудио источники
     */
    processAudio(audio) {
        return audio.map((audioSource, index) => ({
            id: audioSource.id || index,
            name: audioSource.name || `Audio ${index + 1}`,
            type: audioSource.type || 'ambient',
            position: audioSource.position || { x: 0, y: 0, z: 0 },
            volume: audioSource.volume || 0.8,
            spatialAudio: true,
            anAntaSound: true,
            metadata: {
                ...audioSource.metadata,
                domeCompatible: true,
                spatial3D: true
            }
        }));
    }

    /**
     * Обработка комиксов для mbharata_client
     * @param {Array} comics - Массив комиксов
     * @returns {Array} Обработанные комиксы
     */
    processComics(comics) {
        return comics.map((comic, index) => ({
            id: comic.id || index,
            name: comic.name || `Comic ${index + 1}`,
            type: 'comic',
            domeOptimized: true,
            pages: comic.pages || [],
            metadata: {
                ...comic.metadata,
                domeCompatible: true,
                projectionType: 'spherical',
                format: 'mbharata_client'
            }
        }));
    }

    /**
     * Оптимизация пакета для мобильных устройств
     * @param {Object} package - Пакет для оптимизации
     * @returns {Promise<Object>} Оптимизированный пакет
     */
    async optimizeForMobile(package) {
        console.log('📱 Оптимизация для мобильных устройств...');

        // Оптимизация изображений
        if (package.content.comics) {
            package.content.comics = await this.optimizeComics(package.content.comics);
        }

        // Оптимизация аудио
        if (package.content.audio) {
            package.content.audio = await this.optimizeAudio(package.content.audio);
        }

        // Оптимизация 3D сцен
        if (package.content.scenes) {
            package.content.scenes = await this.optimizeScenes(package.content.scenes);
        }

        // Добавление настроек оптимизации
        package.optimization = {
            mobileOptimized: true,
            compressionLevel: this.exportSettings.compression,
            qualityLevel: this.exportSettings.quality,
            domeOptimized: this.exportSettings.domeOptimization,
            audioOptimized: this.exportSettings.audioOptimization
        };

        return package;
    }

    /**
     * Оптимизация комиксов для мобильных устройств
     * @param {Array} comics - Массив комиксов
     * @returns {Promise<Array>} Оптимизированные комиксы
     */
    async optimizeComics(comics) {
        return comics.map(comic => ({
            ...comic,
            mobileOptimized: true,
            compression: 'high',
            format: 'webp',
            resolution: {
                width: 2048,
                height: 1024
            }
        }));
    }

    /**
     * Оптимизация аудио для мобильных устройств
     * @param {Array} audio - Массив аудио источников
     * @returns {Promise<Array>} Оптимизированные аудио источники
     */
    async optimizeAudio(audio) {
        return audio.map(audioSource => ({
            ...audioSource,
            mobileOptimized: true,
            format: 'ogg',
            bitrate: 128,
            spatialAudio: true
        }));
    }

    /**
     * Оптимизация 3D сцен для мобильных устройств
     * @param {Array} scenes - Массив сцен
     * @returns {Promise<Array>} Оптимизированные сцены
     */
    async optimizeScenes(scenes) {
        return scenes.map(scene => ({
            ...scene,
            mobileOptimized: true,
            lodLevels: 3,
            textureCompression: 'high',
            polygonReduction: 0.3
        }));
    }

    /**
     * Сохранение пакета
     * @param {Object} package - Пакет для сохранения
     * @param {string} outputPath - Путь для сохранения
     */
    async savePackage(package, outputPath) {
        const packageJson = JSON.stringify(package, null, 2);
        fs.writeFileSync(outputPath, packageJson);
        console.log(`✅ Пакет сохранен: ${outputPath}`);
    }

    /**
     * Создание метаданных экспорта
     * @param {Object} package - Экспортированный пакет
     * @param {string} outputPath - Путь к файлу
     * @returns {Object} Метаданные
     */
    createMetadata(package, outputPath) {
        const stats = fs.statSync(outputPath);
        
        return {
            filePath: outputPath,
            fileName: path.basename(outputPath),
            fileSize: stats.size,
            fileSizeFormatted: this.formatFileSize(stats.size),
            exportDate: new Date().toISOString(),
            packageVersion: package.packageInfo.version,
            contentCount: {
                scenes: package.content.scenes.length,
                audio: package.content.audio.length,
                comics: package.content.comics.length
            },
            optimization: package.optimization
        };
    }

    /**
     * Форматирование размера файла
     * @param {number} bytes - Размер в байтах
     * @returns {string} Форматированный размер
     */
    formatFileSize(bytes) {
        const sizes = ['Bytes', 'KB', 'MB', 'GB'];
        if (bytes === 0) return '0 Bytes';
        const i = Math.floor(Math.log(bytes) / Math.log(1024));
        return Math.round(bytes / Math.pow(1024, i) * 100) / 100 + ' ' + sizes[i];
    }

    /**
     * Настройка параметров экспорта
     * @param {Object} settings - Настройки экспорта
     */
    setExportSettings(settings) {
        this.exportSettings = { ...this.exportSettings, ...settings };
    }

    /**
     * Получение текущих настроек экспорта
     * @returns {Object} Настройки экспорта
     */
    getExportSettings() {
        return this.exportSettings;
    }
}

module.exports = MbharataClientExporter;
