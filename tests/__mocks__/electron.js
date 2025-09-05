/**
 * Мок для Electron API в тестах
 */

module.exports = {
  ipcRenderer: {
    on: jest.fn(),
    invoke: jest.fn().mockImplementation((channel, ...args) => {
      // Мокаем различные IPC каналы
      switch (channel) {
        case 'import-comics':
          return Promise.resolve({
            success: true,
            count: 5,
            comics: [
              { id: 1, name: 'Test Comic 1', originalPath: '/test/path1' },
              { id: 2, name: 'Test Comic 2', originalPath: '/test/path2' }
            ]
          });
        case 'export-mbharata':
          return Promise.resolve({
            success: true,
            path: '/test/export.mbp',
            metadata: {
              fileSize: 1024000,
              fileSizeFormatted: '1.02 MB'
            }
          });
        case 'load-daga-file':
          return Promise.resolve({
            success: true,
            data: {
              audio: {
                id: 1,
                name: 'Test Audio'
              },
              spatial: {},
              anantasound: {}
            }
          });
        case 'save-daga-file':
          return Promise.resolve({
            success: true,
            path: '/test/save.daga'
          });
        case 'load-zelim-file':
          return Promise.resolve({
            success: true,
            data: {
              project: {
                id: 1,
                name: 'Test 3D Project'
              },
              scene: {},
              dome: {}
            }
          });
        case 'save-zelim-file':
          return Promise.resolve({
            success: true,
            path: '/test/save.zelim'
          });
        default:
          return Promise.resolve({ success: true });
      }
    }),
    send: jest.fn()
  },
  
  ipcMain: {
    handle: jest.fn(),
    on: jest.fn()
  },
  
  app: {
    getVersion: jest.fn(() => '1.0.0'),
    whenReady: jest.fn(() => Promise.resolve()),
    on: jest.fn(),
    setAsDefaultProtocolClient: jest.fn()
  },
  
  BrowserWindow: jest.fn().mockImplementation(() => ({
    loadFile: jest.fn(),
    show: jest.fn(),
    hide: jest.fn(),
    close: jest.fn(),
    on: jest.fn(),
    once: jest.fn(),
    webContents: {
      send: jest.fn(),
      openDevTools: jest.fn()
    }
  })),
  
  Menu: {
    buildFromTemplate: jest.fn(),
    setApplicationMenu: jest.fn()
  },
  
  dialog: {
    showOpenDialog: jest.fn().mockResolvedValue({
      canceled: false,
      filePaths: ['/test/path']
    }),
    showSaveDialog: jest.fn().mockResolvedValue({
      canceled: false,
      filePath: '/test/save/path'
    })
  }
};
