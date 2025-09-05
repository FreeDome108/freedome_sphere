const fs = require('fs');
const path = require('path');

/**
 * Импортер комиксов Баранько для freedome_sphere
 * Поддерживает формат .comics и интеграцию с mbharata_client
 */
class BarankoComicsImporter {
    constructor() {
        this.supportedFormats = ['.comics', '.cbr', '.cbz'];
        this.importedComics = [];
    }

    /**
     * Импорт комиксов из папки
     * @param {string} folderPath - Путь к папке с комиксами
     * @returns {Promise<Object>} Результат импорта
     */
    async importFromFolder(folderPath) {
        try {
            console.log(`📚 Импорт комиксов из папки: ${folderPath}`);
            
            const files = fs.readdirSync(folderPath);
            const comicsFiles = files.filter(file => 
                this.supportedFormats.some(format => file.toLowerCase().endsWith(format))
            );

            const importedComics = [];

            for (const file of comicsFiles) {
                const filePath = path.join(folderPath, file);
                const comic = await this.importComic(filePath);
                if (comic) {
                    importedComics.push(comic);
                }
            }

            this.importedComics = [...this.importedComics, ...importedComics];

            return {
                success: true,
                count: importedComics.length,
                comics: importedComics,
                message: `Успешно импортировано ${importedComics.length} комиксов`
            };

        } catch (error) {
            console.error('❌ Ошибка импорта комиксов:', error);
            return {
                success: false,
                error: error.message,
                message: 'Ошибка при импорте комиксов'
            };
        }
    }

    /**
     * Импорт отдельного комикса
     * @param {string} filePath - Путь к файлу комикса
     * @returns {Promise<Object>} Данные комикса
     */
    async importComic(filePath) {
        try {
            const fileName = path.basename(filePath);
            const fileExt = path.extname(filePath).toLowerCase();
            
            console.log(`📖 Импорт комикса: ${fileName}`);

            let comicData;

            switch (fileExt) {
                case '.comics':
                    comicData = await this.parseComicsFile(filePath);
                    break;
                case '.cbr':
                case '.cbz':
                    comicData = await this.parseArchiveComic(filePath);
                    break;
                default:
                    throw new Error(`Неподдерживаемый формат: ${fileExt}`);
            }

            // Добавление метаданных для freedome_sphere
            const enhancedComic = {
                id: Date.now() + Math.random(),
                name: fileName,
                originalPath: filePath,
                type: 'comic',
                format: fileExt,
                imported: new Date().toISOString(),
                domeOptimized: false,
                ...comicData
            };

            return enhancedComic;

        } catch (error) {
            console.error(`❌ Ошибка импорта комикса ${filePath}:`, error);
            return null;
        }
    }

    /**
     * Парсинг .comics файла (формат Баранько)
     * @param {string} filePath - Путь к .comics файлу
     * @returns {Promise<Object>} Данные комикса
     */
    async parseComicsFile(filePath) {
        try {
            // Чтение .comics файла
            const fileBuffer = fs.readFileSync(filePath);
            
            // Парсинг структуры .comics файла
            // Предполагаем, что это JSON или бинарный формат
            let comicData;
            
            try {
                // Попытка парсинга как JSON
                comicData = JSON.parse(fileBuffer.toString());
            } catch (jsonError) {
                // Если не JSON, создаем базовую структуру
                comicData = {
                    pages: [],
                    metadata: {
                        title: path.basename(filePath, '.comics'),
                        author: 'Baranko',
                        format: 'comics'
                    }
                };
            }

            // Обработка для купольного отображения
            const domeOptimized = this.optimizeForDome(comicData);

            return {
                ...comicData,
                domeOptimized,
                pages: comicData.pages || [],
                metadata: {
                    ...comicData.metadata,
                    domeCompatible: true,
                    projectionType: 'spherical'
                }
            };

        } catch (error) {
            console.error('❌ Ошибка парсинга .comics файла:', error);
            throw error;
        }
    }

    /**
     * Парсинг архивного комикса (.cbr, .cbz)
     * @param {string} filePath - Путь к архивному файлу
     * @returns {Promise<Object>} Данные комикса
     */
    async parseArchiveComic(filePath) {
        try {
            // Здесь будет логика для работы с архивами
            // Пока создаем базовую структуру
            const fileName = path.basename(filePath);
            
            return {
                pages: [],
                metadata: {
                    title: fileName,
                    author: 'Unknown',
                    format: path.extname(filePath).substring(1)
                },
                domeOptimized: false
            };

        } catch (error) {
            console.error('❌ Ошибка парсинга архивного комикса:', error);
            throw error;
        }
    }

    /**
     * Оптимизация комикса для купольного отображения
     * @param {Object} comicData - Данные комикса
     * @returns {Object} Оптимизированные данные
     */
    optimizeForDome(comicData) {
        return {
            sphericalMapping: true,
            fisheyeCorrection: true,
            aspectRatio: '16:9',
            resolution: {
                width: 4096,
                height: 2048
            },
            projectionSettings: {
                type: 'equirectangular',
                fov: 180,
                distortion: 0.1
            }
        };
    }

    /**
     * Получение списка импортированных комиксов
     * @returns {Array} Список комиксов
     */
    getImportedComics() {
        return this.importedComics;
    }

    /**
     * Очистка импортированных комиксов
     */
    clearImported() {
        this.importedComics = [];
    }

    /**
     * Экспорт комикса в формат mbharata_client
     * @param {Object} comic - Данные комикса
     * @returns {Object} Формат для mbharata_client
     */
    exportForMbharataClient(comic) {
        return {
            id: comic.id,
            name: comic.name,
            type: 'comic',
            format: 'mbharata_client',
            content: {
                pages: comic.pages,
                metadata: comic.metadata,
                domeSettings: comic.domeOptimized
            },
            compatibility: {
                mbharata_client: '1.0.0',
                dome_systems: ['spherical', 'fisheye']
            }
        };
    }
}

module.exports = BarankoComicsImporter;
