/**
 * Настройка тестовой среды для Freedome Sphere
 */

// Мокаем Electron API
global.require = function(module) {
  if (module === 'electron') {
    return {
      ipcRenderer: {
        on: jest.fn(),
        invoke: jest.fn().mockResolvedValue({ success: true }),
        send: jest.fn()
      }
    };
  }
  if (module === 'path') {
    return {
      basename: jest.fn((path) => path.split('/').pop())
    };
  }
  return {};
};

// Мокаем console методы для тестов
global.console = {
  ...console,
  log: jest.fn(),
  error: jest.fn(),
  warn: jest.fn(),
  info: jest.fn()
};

// Настройка таймаутов для тестов
jest.setTimeout(10000);

// Глобальные утилиты для тестов
global.testUtils = {
  // Создание мока элемента DOM
  createMockElement: (tagName, attributes = {}) => {
    const element = document.createElement(tagName);
    Object.keys(attributes).forEach(key => {
      element.setAttribute(key, attributes[key]);
    });
    return element;
  },
  
  // Создание мока события
  createMockEvent: (type, properties = {}) => {
    return new Event(type, { bubbles: true, ...properties });
  },
  
  // Ожидание следующего тика
  nextTick: () => new Promise(resolve => setTimeout(resolve, 0)),
  
  // Очистка DOM
  cleanupDOM: () => {
    document.body.innerHTML = '';
    document.head.innerHTML = '';
  }
};

// Очистка после каждого теста
afterEach(() => {
  jest.clearAllMocks();
  localStorage.clear();
});
