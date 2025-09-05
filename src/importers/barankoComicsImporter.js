const fs = require('fs');
const path = require('path');
const BorankoFormat = require('../core/borankoFormat');

/**
 * Импортер комиксов Баранько для freedome_sphere
 * 
 * ⚠️ ВАЖНОЕ ПРЕДУПРЕЖДЕНИЕ:
 * Формат .comics поддерживается ТОЛЬКО в режиме ASIS для единственного 
 * legacy приложения mbharata (с комиксами нарисованными Боранько).
 * 
 * 🚨 DEPRECATION NOTICE:
 * Формат .comics будет скоро признан DEPRECATED и УДАЛЕН из системы.
 * Используйте современный формат .zelim для всех новых проектов.
 * 
 * Импортирует из устаревших форматов (.comics, .cbr, .cbz)
 * Конвертирует в современный формат .boranko для 2D
 */
class BarankoComicsImporter {
    constructor() {
        this.supportedImportFormats = ['.comics', '.cbr', '.cbz']; // Только для импорта
        this.exportFormat = '.boranko'; // Сохраняем только в .boranko для 2D
        this.importedComics = [];
        this.borankoFormat = new BorankoFormat();
        
        // Предупреждение о deprecation
        this.showDeprecationWarning();
    }

    /**
     * Показать предупреждение о deprecation формата .comics
     */
    showDeprecationWarning() {
        console.warn(`
🚨 DEPRECATION WARNING 🚨
═══════════════════════════════════════════════════════════════
⚠️  Формат .comics поддерживается ТОЛЬКО в режиме ASIS
   для единственного legacy приложения mbharata 
   (с комиксами нарисованными Боранько).

🚨 ВНИМАНИЕ: Формат .comics будет скоро признан DEPRECATED 
   и УДАЛЕН из системы!

✅ РЕКОМЕНДАЦИЯ: Используйте современный формат .boranko 
   для всех новых 2D проектов.

📅 Планируемое удаление: Следующая мажорная версия
═══════════════════════════════════════════════════════════════
        `);
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
                this.supportedImportFormats.some(format => file.toLowerCase().endsWith(format))
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
                    // Предупреждение для .comics файлов
                    console.warn(`⚠️ DEPRECATION WARNING: Импорт устаревшего формата .comics из ${fileName}`);
                    console.warn(`   Этот формат поддерживается только в режиме ASIS для legacy mbharata`);
                    console.warn(`   Рекомендуется использовать современный формат .boranko для 2D`);
                    comicData = await this.parseComicsFile(filePath);
                    break;
                case '.cbr':
                case '.cbz':
                    comicData = await this.parseArchiveComic(filePath);
                    break;
                default:
                    throw new Error(`Неподдерживаемый формат: ${fileExt}`);
            }

            // Конвертация в .boranko формат
            const borankoComic = this.convertToBorankoFormat({
                id: Date.now() + Math.random(),
                name: fileName,
                originalPath: filePath,
                originalFormat: fileExt,
                imported: new Date().toISOString(),
                ...comicData
            });

            return borankoComic;

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
     * Конвертация комикса в .boranko формат
     * @param {Object} comic - Данные комикса
     * @returns {Object} Конвертированный комикс в .boranko формате
     */
    convertToBorankoFormat(comic) {
        return {
            id: comic.id,
            name: comic.name,
            type: 'comic',
            format: 'boranko',
            domeOptimized: true,
            
            // Конвертированные страницы
            pages: this.convertPagesToBoranko(comic.pages || []),
            
            // Метаданные
            metadata: {
                ...comic.metadata,
                originalFormat: comic.originalFormat,
                converted: new Date().toISOString(),
                domeCompatible: true,
                projectionType: 'spherical'
            },
            
            // Настройки отображения
            display: {
                aspectRatio: '16:9',
                resolution: {
                    width: 4096,
                    height: 2048
                },
                sphericalMapping: true,
                fisheyeCorrection: true
            },
            
            // Информация об оригинале
            original: {
                path: comic.originalPath,
                format: comic.originalFormat,
                imported: comic.imported
            }
        };
    }

    /**
     * Конвертация страниц в .boranko формат
     * @param {Array} pages - Страницы комикса
     * @returns {Array} Конвертированные страницы
     */
    convertPagesToBoranko(pages) {
        return pages.map((page, index) => ({
            id: page.id || `page_${index}`,
            index: index,
            type: 'comic_page',
            format: 'boranko',
            
            // Конвертированное изображение
            image: {
                data: page.imageData || null,
                format: 'webp',
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
                originalFormat: page.originalFormat || 'unknown'
            }
        }));
    }

    /**
     * Сохранение комикса в .boranko формате
     * @param {Object} comic - Данные комикса
     * @param {string} outputPath - Путь для сохранения
     * @returns {Promise<Object>} Результат сохранения
     */
    async saveAsBoranko(comic, outputPath) {
        try {
            const borankoComic = this.convertToBorankoFormat(comic);
            const borankoData = this.borankoFormat.createBorankoStructure({
                name: comic.name,
                comics: [borankoComic]
            });
            
            // Обновление статистики
            const updatedData = this.borankoFormat.updateStatistics(borankoData);
            
            // Сохранение файла
            fs.writeFileSync(outputPath, JSON.stringify(updatedData, null, 2));
            
            return {
                success: true,
                path: outputPath,
                format: 'boranko',
                message: 'Комикс сохранен в формате .boranko'
            };
            
        } catch (error) {
            return {
                success: false,
                error: error.message,
                message: 'Ошибка сохранения в формате .boranko'
            };
        }
    }

    /**
     * Загрузка комикса из .boranko формата
     * @param {string} filePath - Путь к .boranko файлу
     * @returns {Promise<Object>} Загруженный комикс
     */
    async loadFromBoranko(filePath) {
        try {
            const fileContent = fs.readFileSync(filePath, 'utf8');
            const borankoData = JSON.parse(fileContent);
            
            // Валидация файла
            const validation = this.borankoFormat.validateBorankoFile(borankoData);
            if (!validation.valid) {
                throw new Error(`Неверный формат .boranko: ${validation.errors.join(', ')}`);
            }
            
            // Извлечение комиксов
            const comics = borankoData.content.comics || [];
            
            return {
                success: true,
                comics: comics,
                metadata: borankoData.project,
                message: `Загружено ${comics.length} комиксов из .boranko файла`
            };
            
        } catch (error) {
            return {
                success: false,
                error: error.message,
                message: 'Ошибка загрузки .boranko файла'
            };
        }
    }

    /**
     * Экспорт комикса в формат mbharata_client
     * @param {Object} comic - Данные комикса в .boranko формате
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
                domeSettings: comic.display
            },
            compatibility: {
                mbharata_client: '1.0.0',
                dome_systems: ['spherical', 'fisheye'],
                boranko_format: '1.0.0'
            }
        };
    }
}

module.exports = BarankoComicsImporter;
