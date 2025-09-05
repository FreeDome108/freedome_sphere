/**
 * Менеджер системы anAntaSound для freedome_sphere
 * Обеспечивает 3D пространственное аудио для купольного отображения
 */
class AnAntaSoundManager {
    constructor() {
        this.audioContext = null;
        this.audioSources = [];
        this.spatialSettings = {
            domeRadius: 10,
            listenerPosition: { x: 0, y: 0, z: 0 },
            listenerOrientation: { x: 0, y: 0, z: 1 },
            reverbSettings: {
                enabled: true,
                roomSize: 0.5,
                damping: 0.5,
                wet: 0.3
            }
        };
        this.isInitialized = false;
    }

    /**
     * Инициализация anAntaSound системы
     * @returns {Promise<boolean>} Успешность инициализации
     */
    async initialize() {
        try {
            console.log('🔊 Инициализация anAntaSound системы...');

            // Создание Web Audio API контекста
            this.audioContext = new (window.AudioContext || window.webkitAudioContext)();
            
            // Настройка пространственного аудио
            await this.setupSpatialAudio();
            
            // Инициализация реверберации
            await this.setupReverb();
            
            this.isInitialized = true;
            console.log('✅ anAntaSound система инициализирована');
            
            return true;

        } catch (error) {
            console.error('❌ Ошибка инициализации anAntaSound:', error);
            return false;
        }
    }

    /**
     * Настройка пространственного аудио
     */
    async setupSpatialAudio() {
        if (!this.audioContext) return;

        // Создание PannerNode для пространственного аудио
        this.pannerNode = this.audioContext.createPanner();
        this.pannerNode.panningModel = 'HRTF';
        this.pannerNode.distanceModel = 'exponential';
        this.pannerNode.rolloffFactor = 1;
        this.pannerNode.coneInnerAngle = 360;
        this.pannerNode.coneOuterAngle = 0;
        this.pannerNode.coneOuterGain = 0;

        // Подключение к выходу
        this.pannerNode.connect(this.audioContext.destination);
    }

    /**
     * Настройка реверберации
     */
    async setupReverb() {
        if (!this.audioContext) return;

        // Создание ConvolverNode для реверберации
        this.convolverNode = this.audioContext.createConvolver();
        
        // Создание импульсного отклика для купольного пространства
        const impulseResponse = this.createDomeImpulseResponse();
        this.convolverNode.buffer = impulseResponse;
        
        // Подключение к выходу
        this.convolverNode.connect(this.audioContext.destination);
    }

    /**
     * Создание импульсного отклика для купольного пространства
     * @returns {AudioBuffer} Импульсный отклик
     */
    createDomeImpulseResponse() {
        const sampleRate = this.audioContext.sampleRate;
        const length = sampleRate * 2; // 2 секунды
        const impulse = this.audioContext.createBuffer(2, length, sampleRate);
        
        const leftChannel = impulse.getChannelData(0);
        const rightChannel = impulse.getChannelData(1);
        
        // Создание купольного реверберационного эффекта
        for (let i = 0; i < length; i++) {
            const decay = Math.exp(-i / (sampleRate * 0.5));
            const noise = (Math.random() * 2 - 1) * 0.1;
            
            leftChannel[i] = noise * decay;
            rightChannel[i] = noise * decay * 0.8; // Небольшая разница между каналами
        }
        
        return impulse;
    }

    /**
     * Добавление аудио источника
     * @param {Object} audioSource - Данные аудио источника
     * @returns {Promise<Object>} Созданный источник
     */
    async addAudioSource(audioSource) {
        try {
            if (!this.isInitialized) {
                await this.initialize();
            }

            console.log(`🎵 Добавление аудио источника: ${audioSource.name}`);

            const source = {
                id: audioSource.id || Date.now() + Math.random(),
                name: audioSource.name,
                type: audioSource.type || 'ambient',
                position: audioSource.position || { x: 0, y: 0, z: 0 },
                volume: audioSource.volume || 0.8,
                loop: audioSource.loop || false,
                audioBuffer: null,
                sourceNode: null,
                pannerNode: null,
                gainNode: null,
                isPlaying: false
            };

            // Загрузка аудио файла
            if (audioSource.file) {
                source.audioBuffer = await this.loadAudioFile(audioSource.file);
            }

            // Создание аудио узлов
            source.gainNode = this.audioContext.createGain();
            source.pannerNode = this.audioContext.createPanner();
            
            // Настройка пространственного позиционирования
            this.setSourcePosition(source, source.position);
            this.setSourceVolume(source, source.volume);

            // Подключение узлов
            source.gainNode.connect(source.pannerNode);
            source.pannerNode.connect(this.convolverNode);

            this.audioSources.push(source);
            
            console.log(`✅ Аудио источник добавлен: ${source.name}`);
            return source;

        } catch (error) {
            console.error('❌ Ошибка добавления аудио источника:', error);
            throw error;
        }
    }

    /**
     * Загрузка аудио файла
     * @param {string} filePath - Путь к аудио файлу
     * @returns {Promise<AudioBuffer>} Аудио буфер
     */
    async loadAudioFile(filePath) {
        try {
            const response = await fetch(filePath);
            const arrayBuffer = await response.arrayBuffer();
            return await this.audioContext.decodeAudioData(arrayBuffer);
        } catch (error) {
            console.error('❌ Ошибка загрузки аудио файла:', error);
            throw error;
        }
    }

    /**
     * Установка позиции аудио источника
     * @param {Object} source - Аудио источник
     * @param {Object} position - Позиция {x, y, z}
     */
    setSourcePosition(source, position) {
        if (source.pannerNode) {
            source.pannerNode.positionX.value = position.x;
            source.pannerNode.positionY.value = position.y;
            source.pannerNode.positionZ.value = position.z;
            source.position = position;
        }
    }

    /**
     * Установка громкости аудио источника
     * @param {Object} source - Аудио источник
     * @param {number} volume - Громкость (0-1)
     */
    setSourceVolume(source, volume) {
        if (source.gainNode) {
            source.gainNode.gain.value = volume;
            source.volume = volume;
        }
    }

    /**
     * Воспроизведение аудио источника
     * @param {string} sourceId - ID источника
     * @returns {Promise<boolean>} Успешность воспроизведения
     */
    async playSource(sourceId) {
        try {
            const source = this.audioSources.find(s => s.id === sourceId);
            if (!source || !source.audioBuffer) {
                throw new Error('Аудио источник не найден или не загружен');
            }

            if (source.isPlaying) {
                this.stopSource(sourceId);
            }

            // Создание нового источника
            source.sourceNode = this.audioContext.createBufferSource();
            source.sourceNode.buffer = source.audioBuffer;
            source.sourceNode.loop = source.loop;
            
            // Подключение к gain node
            source.sourceNode.connect(source.gainNode);
            
            // Воспроизведение
            source.sourceNode.start();
            source.isPlaying = true;

            console.log(`▶️ Воспроизведение: ${source.name}`);
            return true;

        } catch (error) {
            console.error('❌ Ошибка воспроизведения аудио:', error);
            return false;
        }
    }

    /**
     * Остановка аудио источника
     * @param {string} sourceId - ID источника
     */
    stopSource(sourceId) {
        const source = this.audioSources.find(s => s.id === sourceId);
        if (source && source.sourceNode && source.isPlaying) {
            source.sourceNode.stop();
            source.sourceNode.disconnect();
            source.sourceNode = null;
            source.isPlaying = false;
            console.log(`⏹️ Остановка: ${source.name}`);
        }
    }

    /**
     * Остановка всех аудио источников
     */
    stopAllSources() {
        this.audioSources.forEach(source => {
            this.stopSource(source.id);
        });
    }

    /**
     * Обновление позиции слушателя
     * @param {Object} position - Позиция {x, y, z}
     * @param {Object} orientation - Ориентация {x, y, z}
     */
    updateListener(position, orientation) {
        if (this.audioContext && this.audioContext.listener) {
            this.audioContext.listener.positionX.value = position.x;
            this.audioContext.listener.positionY.value = position.y;
            this.audioContext.listener.positionZ.value = position.z;
            
            this.audioContext.listener.forwardX.value = orientation.x;
            this.audioContext.listener.forwardY.value = orientation.y;
            this.audioContext.listener.forwardZ.value = orientation.z;
            
            this.spatialSettings.listenerPosition = position;
            this.spatialSettings.listenerOrientation = orientation;
        }
    }

    /**
     * Обновление настроек купола
     * @param {Object} domeSettings - Настройки купола
     */
    updateDomeSettings(domeSettings) {
        this.spatialSettings.domeRadius = domeSettings.radius || 10;
        
        // Обновление реверберации для нового размера купола
        if (domeSettings.radius !== this.spatialSettings.domeRadius) {
            this.setupReverb();
        }
    }

    /**
     * Получение списка аудио источников
     * @returns {Array} Список источников
     */
    getAudioSources() {
        return this.audioSources;
    }

    /**
     * Удаление аудио источника
     * @param {string} sourceId - ID источника
     */
    removeAudioSource(sourceId) {
        const index = this.audioSources.findIndex(s => s.id === sourceId);
        if (index !== -1) {
            this.stopSource(sourceId);
            this.audioSources.splice(index, 1);
            console.log(`🗑️ Аудио источник удален: ${sourceId}`);
        }
    }

    /**
     * Экспорт настроек anAntaSound для mbharata_client
     * @returns {Object} Настройки для экспорта
     */
    exportSettings() {
        return {
            spatialSettings: this.spatialSettings,
            audioSources: this.audioSources.map(source => ({
                id: source.id,
                name: source.name,
                type: source.type,
                position: source.position,
                volume: source.volume,
                loop: source.loop
            })),
            domeSettings: {
                radius: this.spatialSettings.domeRadius,
                reverb: this.spatialSettings.reverbSettings
            }
        };
    }

    /**
     * Очистка ресурсов
     */
    cleanup() {
        this.stopAllSources();
        this.audioSources = [];
        
        if (this.audioContext) {
            this.audioContext.close();
            this.audioContext = null;
        }
        
        this.isInitialized = false;
        console.log('🧹 anAntaSound ресурсы очищены');
    }
}

module.exports = AnAntaSoundManager;
