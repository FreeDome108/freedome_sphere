/**
 * Интеграционные тесты для Freedome Sphere
 */

const { JSDOM } = require('jsdom');
const fs = require('fs');
const path = require('path');

// Читаем основной HTML файл
const htmlContent = fs.readFileSync(path.join(__dirname, '../src/index.html'), 'utf8');

// Создаем DOM из реального HTML файла
const dom = new JSDOM(htmlContent, {
    url: 'http://localhost',
    pretendToBeVisual: true,
    resources: 'usable'
});

// Устанавливаем глобальные переменные
global.window = dom.window;
global.document = dom.window.document;
global.localStorage = {
    store: {},
    getItem: function(key) { return this.store[key] || null; },
    setItem: function(key, value) { this.store[key] = value; },
    removeItem: function(key) { delete this.store[key]; },
    clear: function() { this.store = {}; }
};

// Мокаем Electron API
global.require = function(module) {
    if (module === 'electron') {
        return {
            ipcRenderer: {
                on: jest.fn(),
                invoke: jest.fn(),
                send: jest.fn()
            }
        };
    }
    return {};
};

describe('Freedome Sphere Integration Tests', () => {
    let appContainer, sidebar, mainContent, toolbar;

    beforeEach(() => {
        // Очищаем localStorage
        localStorage.clear();
        
        // Получаем основные элементы
        appContainer = document.querySelector('.app-container');
        sidebar = document.querySelector('.sidebar');
        mainContent = document.querySelector('.main-content');
        toolbar = document.querySelector('.toolbar');
    });

    describe('DOM Structure', () => {
        test('should have main app container', () => {
            expect(appContainer).toBeTruthy();
            expect(appContainer.classList.contains('app-container')).toBe(true);
        });

        test('should have sidebar with logo', () => {
            expect(sidebar).toBeTruthy();
            const logo = document.getElementById('appLogo');
            expect(logo).toBeTruthy();
            expect(logo.textContent).toBe('Freedome Sphere');
        });

        test('should have main content area', () => {
            expect(mainContent).toBeTruthy();
            expect(mainContent.classList.contains('main-content')).toBe(true);
        });

        test('should have toolbar with controls', () => {
            expect(toolbar).toBeTruthy();
            expect(toolbar.classList.contains('toolbar')).toBe(true);
        });

        test('should have edition selector', () => {
            const editionSelect = document.getElementById('editionSelect');
            expect(editionSelect).toBeTruthy();
            expect(editionSelect.tagName).toBe('SELECT');
        });

        test('should have theme toggle button', () => {
            const themeToggle = document.getElementById('themeToggle');
            expect(themeToggle).toBeTruthy();
            expect(themeToggle.tagName).toBe('BUTTON');
        });
    });

    describe('CSS Classes and Styling', () => {
        test('should have proper CSS classes for all major components', () => {
            expect(document.querySelector('.sidebar')).toBeTruthy();
            expect(document.querySelector('.main-content')).toBeTruthy();
            expect(document.querySelector('.toolbar')).toBeTruthy();
            expect(document.querySelector('.viewport')).toBeTruthy();
            expect(document.querySelector('.status-bar')).toBeTruthy();
            expect(document.querySelector('.panel')).toBeTruthy();
        });

        test('should have button styles', () => {
            const buttons = document.querySelectorAll('.button');
            expect(buttons.length).toBeGreaterThan(0);
            
            buttons.forEach(button => {
                expect(button.classList.contains('button')).toBe(true);
            });
        });

        test('should have project info section', () => {
            const projectInfo = document.getElementById('projectInfo');
            expect(projectInfo).toBeTruthy();
            expect(projectInfo.classList.contains('project-info')).toBe(true);
        });
    });

    describe('Interactive Elements', () => {
        test('should have all project buttons', () => {
            const newProjectBtn = document.querySelector('button[onclick="newProject()"]');
            const openProjectBtn = document.querySelector('button[onclick="openProject()"]');
            const saveProjectBtn = document.querySelector('button[onclick="saveProject()"]');
            
            expect(newProjectBtn).toBeTruthy();
            expect(openProjectBtn).toBeTruthy();
            expect(saveProjectBtn).toBeTruthy();
        });

        test('should have import buttons', () => {
            const importComicsBtn = document.querySelector('button[onclick="importComics()"]');
            const importUnrealBtn = document.querySelector('button[onclick="importUnreal()"]');
            const importBlenderBtn = document.querySelector('button[onclick="importBlender()"]');
            
            expect(importComicsBtn).toBeTruthy();
            expect(importUnrealBtn).toBeTruthy();
            expect(importBlenderBtn).toBeTruthy();
        });

        test('should have audio control buttons', () => {
            const anantaSoundBtn = document.querySelector('button[onclick="setupAnantaSound()"]');
            const audio3DBtn = document.querySelector('button[onclick="audio3D()"]');
            const loadDagaBtn = document.querySelector('button[onclick="loadDagaFile()"]');
            
            expect(anantaSoundBtn).toBeTruthy();
            expect(audio3DBtn).toBeTruthy();
            expect(loadDagaBtn).toBeTruthy();
        });

        test('should have export buttons', () => {
            const exportMbharataBtn = document.querySelector('button[onclick="exportMbharata()"]');
            const exportDomeBtn = document.querySelector('button[onclick="exportDome()"]');
            
            expect(exportMbharataBtn).toBeTruthy();
            expect(exportDomeBtn).toBeTruthy();
        });

        test('should have preview controls', () => {
            const playBtn = document.querySelector('button[onclick="playPreview()"]');
            const stopBtn = document.querySelector('button[onclick="stopPreview()"]');
            const resetBtn = document.querySelector('button[onclick="resetView()"]');
            
            expect(playBtn).toBeTruthy();
            expect(stopBtn).toBeTruthy();
            expect(resetBtn).toBeTruthy();
        });
    });

    describe('Form Elements', () => {
        test('should have dome radius slider', () => {
            const domeRadius = document.getElementById('domeRadius');
            expect(domeRadius).toBeTruthy();
            expect(domeRadius.type).toBe('range');
        });

        test('should have projection type selector', () => {
            const projectionType = document.getElementById('projectionType');
            expect(projectionType).toBeTruthy();
            expect(projectionType.tagName).toBe('SELECT');
        });

        test('should have edition selector with all options', () => {
            const editionSelect = document.getElementById('editionSelect');
            const options = editionSelect.querySelectorAll('option');
            
            expect(options.length).toBe(4);
            expect(options[0].value).toBe('default');
            expect(options[1].value).toBe('vaishnava');
            expect(options[2].value).toBe('enterprise');
            expect(options[3].value).toBe('education');
        });
    });

    describe('Status and Indicators', () => {
        test('should have status indicator', () => {
            const statusIndicator = document.getElementById('statusIndicator');
            expect(statusIndicator).toBeTruthy();
            expect(statusIndicator.classList.contains('status-indicator')).toBe(true);
        });

        test('should have status text', () => {
            const statusText = document.getElementById('statusText');
            expect(statusText).toBeTruthy();
            expect(statusText.textContent).toBe('Ready');
        });

        test('should have loading indicator', () => {
            const loadingIndicator = document.getElementById('loadingIndicator');
            expect(loadingIndicator).toBeTruthy();
            expect(loadingIndicator.classList.contains('loading')).toBe(true);
        });
    });

    describe('Dynamic Content Areas', () => {
        test('should have imported files list', () => {
            const importedFiles = document.getElementById('importedFiles');
            const filesList = document.getElementById('filesList');
            
            expect(importedFiles).toBeTruthy();
            expect(filesList).toBeTruthy();
        });

        test('should have audio controls section', () => {
            const audioControls = document.getElementById('audioControls');
            const audioSources = document.getElementById('audioSources');
            
            expect(audioControls).toBeTruthy();
            expect(audioSources).toBeTruthy();
        });

        test('should have 3D viewport', () => {
            const viewport3d = document.getElementById('viewport3d');
            expect(viewport3d).toBeTruthy();
            expect(viewport3d.classList.contains('viewport-3d')).toBe(true);
        });
    });

    describe('CSS Variables Integration', () => {
        test('should have CSS custom properties defined', () => {
            const rootStyles = getComputedStyle(document.documentElement);
            
            // Проверяем основные переменные
            expect(rootStyles.getPropertyValue('--bg-primary')).toBeTruthy();
            expect(rootStyles.getPropertyValue('--bg-secondary')).toBeTruthy();
            expect(rootStyles.getPropertyValue('--text-primary')).toBeTruthy();
            expect(rootStyles.getPropertyValue('--accent-color')).toBeTruthy();
        });

        test('should have edition-specific CSS variables', () => {
            // Проверяем что CSS переменные для редакций определены
            const style = document.querySelector('style');
            expect(style).toBeTruthy();
            expect(style.textContent).toContain('[data-edition="vaishnava"]');
            expect(style.textContent).toContain('[data-edition="enterprise"]');
            expect(style.textContent).toContain('[data-edition="education"]');
        });

        test('should have theme-specific CSS variables', () => {
            const style = document.querySelector('style');
            expect(style.textContent).toContain('[data-theme="dark"]');
        });
    });

    describe('JavaScript Functions', () => {
        test('should have all required global functions defined', () => {
            // Проверяем что функции определены в глобальной области
            expect(typeof window.newProject).toBe('function');
            expect(typeof window.openProject).toBe('function');
            expect(typeof window.saveProject).toBe('function');
            expect(typeof window.importComics).toBe('function');
            expect(typeof window.exportMbharata).toBe('function');
            expect(typeof window.playPreview).toBe('function');
            expect(typeof window.changeEdition).toBe('function');
            expect(typeof window.toggleTheme).toBe('function');
        });
    });

    describe('Responsive Design', () => {
        test('should have proper flex layout', () => {
            expect(appContainer.style.display).toBe('flex');
            expect(sidebar.style.width).toBe('300px');
        });

        test('should have proper viewport meta tag', () => {
            const viewport = document.querySelector('meta[name="viewport"]');
            expect(viewport).toBeTruthy();
            expect(viewport.getAttribute('content')).toContain('width=device-width');
        });
    });
});

module.exports = { dom };
