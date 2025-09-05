module.exports = {
  // Тестовая среда
  testEnvironment: 'jsdom',
  
  // Папки с тестами
  testMatch: [
    '**/tests/**/*.test.js',
    '**/__tests__/**/*.js'
  ],
  
  // Папки для покрытия
  collectCoverageFrom: [
    'src/**/*.js',
    '!src/main.js', // Исключаем main.js так как это Electron процесс
    '!**/node_modules/**'
  ],
  
  // Пороги покрытия
  coverageThreshold: {
    global: {
      branches: 70,
      functions: 70,
      lines: 70,
      statements: 70
    }
  },
  
  // Настройки для покрытия
  coverageReporters: [
    'text',
    'lcov',
    'html'
  ],
  
  // Настройки для jsdom
  setupFilesAfterEnv: ['<rootDir>/tests/setup.js'],
  
  // Игнорируемые файлы
  testPathIgnorePatterns: [
    '/node_modules/',
    '/dist/'
  ],
  
  // Трансформация файлов
  transform: {
    '^.+\\.js$': 'babel-jest'
  },
  
  // Модули для моков
  moduleNameMapping: {
    '^electron$': '<rootDir>/tests/__mocks__/electron.js'
  },
  
  // Настройки для отображения результатов
  verbose: true,
  clearMocks: true,
  restoreMocks: true
};
