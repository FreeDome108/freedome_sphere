const { app, BrowserWindow, Menu, ipcMain, dialog } = require('electron');
const path = require('path');
const Store = require('electron-store');
const fs = require('fs');

// Импорт модулей freedome_sphere
const BarankoComicsImporter = require('./importers/barankoComicsImporter');
const MbharataClientExporter = require('./exporters/mbharataClientExporter');
const AnAntaSoundManager = require('./core/anAntaSoundManager');
const Zelim3DImporter = require('./importers/zelim3DImporter');

// Инициализация хранилища настроек
const store = new Store();

// Инициализация модулей
const comicsImporter = new BarankoComicsImporter();
const mbharataExporter = new MbharataClientExporter();
const anAntaSoundManager = new AnAntaSoundManager();
const zelim3DImporter = new Zelim3DImporter();

let mainWindow;

function createWindow() {
  // Создание главного окна
  mainWindow = new BrowserWindow({
    width: 1400,
    height: 900,
    minWidth: 1200,
    minHeight: 800,
    webPreferences: {
      nodeIntegration: true,
      contextIsolation: false,
      enableRemoteModule: true
    },
    icon: path.join(__dirname, '../assets/icon.png'),
    titleBarStyle: 'hiddenInset',
    show: false
  });

  // Загрузка HTML файла
  mainWindow.loadFile('src/index.html');

  // Показать окно когда готово
  mainWindow.once('ready-to-show', () => {
    mainWindow.show();
  });

  // Открыть DevTools в режиме разработки
  if (process.env.NODE_ENV === 'development') {
    mainWindow.webContents.openDevTools();
  }

  // Обработка закрытия окна
  mainWindow.on('closed', () => {
    mainWindow = null;
  });
}

// Создание меню приложения
function createMenu() {
  const template = [
    {
      label: 'File',
      submenu: [
        {
          label: 'New Project',
          accelerator: 'CmdOrCtrl+N',
          click: () => {
            mainWindow.webContents.send('menu-new-project');
          }
        },
        {
          label: 'Open Project',
          accelerator: 'CmdOrCtrl+O',
          click: async () => {
            const result = await dialog.showOpenDialog(mainWindow, {
              properties: ['openFile'],
              filters: [
                { name: 'Freedome Sphere Projects', extensions: ['fsp'] },
                { name: 'All Files', extensions: ['*'] }
              ]
            });
            
            if (!result.canceled) {
              mainWindow.webContents.send('menu-open-project', result.filePaths[0]);
            }
          }
        },
        {
          label: 'Save Project',
          accelerator: 'CmdOrCtrl+S',
          click: () => {
            mainWindow.webContents.send('menu-save-project');
          }
        },
        { type: 'separator' },
        {
          label: 'Import',
          submenu: [
            {
              label: 'Baranko Comics',
              click: async () => {
                const result = await dialog.showOpenDialog(mainWindow, {
                  properties: ['openDirectory'],
                  title: 'Select Comics Folder'
                });
                
                if (!result.canceled) {
                  mainWindow.webContents.send('menu-import-comics', result.filePaths[0]);
                }
              }
            },
            {
              label: 'Unreal Engine Scene',
              click: async () => {
                const result = await dialog.showOpenDialog(mainWindow, {
                  properties: ['openFile'],
                  filters: [
                    { name: 'Unreal Engine', extensions: ['uasset', 'umap'] },
                    { name: 'All Files', extensions: ['*'] }
                  ]
                });
                
                if (!result.canceled) {
                  mainWindow.webContents.send('menu-import-unreal', result.filePaths[0]);
                }
              }
            },
            {
              label: 'Blender Model',
              click: async () => {
                const result = await dialog.showOpenDialog(mainWindow, {
                  properties: ['openFile'],
                  filters: [
                    { name: 'Blender Files', extensions: ['blend', 'fbx', 'obj', 'gltf', 'glb'] },
                    { name: 'All Files', extensions: ['*'] }
                  ]
                });
                
                if (!result.canceled) {
                  mainWindow.webContents.send('menu-import-blender', result.filePaths[0]);
                }
              }
            },
            { type: 'separator' },
            {
              label: 'Load .zelim File',
              click: async () => {
                const result = await dialog.showOpenDialog(mainWindow, {
                  properties: ['openFile'],
                  filters: [
                    { name: 'Zelim 3D Files', extensions: ['zelim'] },
                    { name: 'All Files', extensions: ['*'] }
                  ]
                });
                
                if (!result.canceled) {
                  mainWindow.webContents.send('menu-load-zelim', result.filePaths[0]);
                }
              }
            },
            {
              label: 'Save as .zelim',
              click: async () => {
                const result = await dialog.showSaveDialog(mainWindow, {
                  filters: [
                    { name: 'Zelim 3D Files', extensions: ['zelim'] },
                    { name: 'All Files', extensions: ['*'] }
                  ]
                });
                
                if (!result.canceled) {
                  mainWindow.webContents.send('menu-save-zelim', result.filePath);
                }
              }
            }
          ]
        },
        {
          label: 'Export',
          submenu: [
            {
              label: 'mbharata_client',
              click: async () => {
                const result = await dialog.showSaveDialog(mainWindow, {
                  filters: [
                    { name: 'mbharata_client Package', extensions: ['mbp'] },
                    { name: 'All Files', extensions: ['*'] }
                  ]
                });
                
                if (!result.canceled) {
                  mainWindow.webContents.send('menu-export-mbharata', result.filePath);
                }
              }
            },
            {
              label: 'Dome Projection',
              click: async () => {
                const result = await dialog.showSaveDialog(mainWindow, {
                  filters: [
                    { name: 'Dome Projection', extensions: ['dome'] },
                    { name: 'All Files', extensions: ['*'] }
                  ]
                });
                
                if (!result.canceled) {
                  mainWindow.webContents.send('menu-export-dome', result.filePath);
                }
              }
            }
          ]
        },
        { type: 'separator' },
        {
          role: 'quit'
        }
      ]
    },
    {
      label: 'Edit',
      submenu: [
        { role: 'undo' },
        { role: 'redo' },
        { type: 'separator' },
        { role: 'cut' },
        { role: 'copy' },
        { role: 'paste' }
      ]
    },
    {
      label: 'View',
      submenu: [
        { role: 'reload' },
        { role: 'forceReload' },
        { role: 'toggleDevTools' },
        { type: 'separator' },
        { role: 'resetZoom' },
        { role: 'zoomIn' },
        { role: 'zoomOut' },
        { type: 'separator' },
        { role: 'togglefullscreen' }
      ]
    },
    {
      label: 'Audio',
      submenu: [
        {
          label: 'anAntaSound Setup',
          click: () => {
            mainWindow.webContents.send('menu-anantasound-setup');
          }
        },
        {
          label: '3D Audio Positioning',
          click: () => {
            mainWindow.webContents.send('menu-3d-audio');
          }
        },
        { type: 'separator' },
        {
          label: 'Load .daga File',
          click: async () => {
            const result = await dialog.showOpenDialog(mainWindow, {
              properties: ['openFile'],
              filters: [
                { name: 'Daga Audio Files', extensions: ['daga'] },
                { name: 'All Files', extensions: ['*'] }
              ]
            });
            
            if (!result.canceled) {
              mainWindow.webContents.send('menu-load-daga', result.filePaths[0]);
            }
          }
        },
        {
          label: 'Save as .daga',
          click: async () => {
            const result = await dialog.showSaveDialog(mainWindow, {
              filters: [
                { name: 'Daga Audio Files', extensions: ['daga'] },
                { name: 'All Files', extensions: ['*'] }
              ]
            });
            
            if (!result.canceled) {
              mainWindow.webContents.send('menu-save-daga', result.filePath);
            }
          }
        }
      ]
    },
    {
      label: 'Help',
      submenu: [
        {
          label: 'Documentation',
          click: () => {
            mainWindow.webContents.send('menu-documentation');
          }
        },
        {
          label: 'About',
          click: () => {
            mainWindow.webContents.send('menu-about');
          }
        }
      ]
    }
  ];

  const menu = Menu.buildFromTemplate(template);
  Menu.setApplicationMenu(menu);
}

// Обработчики IPC
ipcMain.handle('get-app-version', () => {
  return app.getVersion();
});

ipcMain.handle('get-store-value', (event, key) => {
  return store.get(key);
});

ipcMain.handle('set-store-value', (event, key, value) => {
  store.set(key, value);
});

// Обработчик импорта комиксов
ipcMain.handle('import-comics', async (event, folderPath) => {
  try {
    console.log(`📚 Импорт комиксов из: ${folderPath}`);
    const result = await comicsImporter.importFromFolder(folderPath);
    
    if (result.success) {
      console.log(`✅ Импортировано ${result.count} комиксов`);
    } else {
      console.error(`❌ Ошибка импорта: ${result.error}`);
    }
    
    return result;
  } catch (error) {
    console.error('❌ Критическая ошибка импорта комиксов:', error);
    return {
      success: false,
      error: error.message,
      message: 'Критическая ошибка при импорте комиксов'
    };
  }
});

// Обработчик экспорта для mbharata_client
ipcMain.handle('export-mbharata', async (event, projectData, outputPath) => {
  try {
    console.log(`📱 Экспорт проекта в mbharata_client: ${outputPath}`);
    
    // Валидация данных проекта
    if (!projectData || !outputPath) {
      throw new Error('Отсутствуют данные проекта или путь для экспорта');
    }
    
    // Экспорт через MbharataClientExporter
    const result = await mbharataExporter.exportProject(projectData, outputPath);
    
    if (result.success) {
      console.log(`✅ Проект экспортирован: ${result.path}`);
      console.log(`📊 Размер файла: ${result.metadata.fileSizeFormatted}`);
    } else {
      console.error(`❌ Ошибка экспорта: ${result.error}`);
    }
    
    return result;
  } catch (error) {
    console.error('❌ Критическая ошибка экспорта:', error);
    return {
      success: false,
      error: error.message,
      message: 'Критическая ошибка при экспорте проекта'
    };
  }
});

// События приложения
app.whenReady().then(() => {
  createWindow();
  createMenu();

  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
      createWindow();
    }
  });
});

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

// Обработчик загрузки .daga файла
ipcMain.handle('load-daga-file', async (event, filePath) => {
  try {
    console.log(`🎵 Загрузка .daga файла: ${filePath}`);
    const result = await anAntaSoundManager.loadDagaFile(filePath);
    
    return {
      success: true,
      data: result,
      message: 'Daga файл загружен успешно'
    };
  } catch (error) {
    console.error('❌ Ошибка загрузки .daga файла:', error);
    return {
      success: false,
      error: error.message,
      message: 'Ошибка загрузки .daga файла'
    };
  }
});

// Обработчик сохранения .daga файла
ipcMain.handle('save-daga-file', async (event, audioData, outputPath) => {
  try {
    console.log(`💾 Сохранение .daga файла: ${outputPath}`);
    const result = await anAntaSoundManager.saveAsDaga(audioData, outputPath);
    
    return result;
  } catch (error) {
    console.error('❌ Ошибка сохранения .daga файла:', error);
    return {
      success: false,
      error: error.message,
      message: 'Ошибка сохранения .daga файла'
    };
  }
});

// Обработчик загрузки .zelim файла
ipcMain.handle('load-zelim-file', async (event, filePath) => {
  try {
    console.log(`🎮 Загрузка .zelim файла: ${filePath}`);
    const result = await zelim3DImporter.loadFromZelim(filePath);
    
    return {
      success: true,
      data: result,
      message: 'Zelim файл загружен успешно'
    };
  } catch (error) {
    console.error('❌ Ошибка загрузки .zelim файла:', error);
    return {
      success: false,
      error: error.message,
      message: 'Ошибка загрузки .zelim файла'
    };
  }
});

// Обработчик сохранения .zelim файла
ipcMain.handle('save-zelim-file', async (event, content3D, outputPath) => {
  try {
    console.log(`💾 Сохранение .zelim файла: ${outputPath}`);
    const result = await zelim3DImporter.saveAsZelim(content3D, outputPath);
    
    return result;
  } catch (error) {
    console.error('❌ Ошибка сохранения .zelim файла:', error);
    return {
      success: false,
      error: error.message,
      message: 'Ошибка сохранения .zelim файла'
    };
  }
});

// Обработка протокола для открытия файлов
app.setAsDefaultProtocolClient('freedome-sphere');
