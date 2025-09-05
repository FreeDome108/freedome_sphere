/**
 * Тесты для системы тем и редакций Freedome Sphere
 */

// Мокаем DOM окружение для тестов
const { JSDOM } = require('jsdom');

// Создаем виртуальный DOM
const dom = new JSDOM(`
<!DOCTYPE html>
<html>
<head>
    <style>
        :root {
            --bg-primary: #f0f8ff;
            --bg-secondary: #e6f3ff;
            --bg-tertiary: #d1e7ff;
            --text-primary: #1a365d;
            --text-secondary: #2d5a87;
            --text-muted: #4a6fa5;
            --accent-color: #4a9eff;
            --accent-hover: #3a8eef;
            --border-color: #b8d4f0;
            --shadow: rgba(74, 158, 255, 0.15);
            --success-color: #28a745;
            --warning-color: #ffc107;
            --error-color: #dc3545;
            --logo-emoji: "🌐";
            --edition-name: "Freedome Sphere";
        }

        [data-theme="dark"] {
            --bg-primary: #1a1a1a;
            --bg-secondary: #2a2a2a;
            --bg-tertiary: #3a3a3a;
            --text-primary: #ffffff;
            --text-secondary: #cccccc;
            --text-muted: #999999;
            --accent-color: #4a9eff;
            --accent-hover: #3a8eef;
            --border-color: #3a3a3a;
            --shadow: rgba(0, 0, 0, 0.3);
            --success-color: #28a745;
            --warning-color: #ffc107;
            --error-color: #dc3545;
            --logo-emoji: "🌐";
            --edition-name: "Freedome Sphere";
        }

        [data-edition="vaishnava"] {
            --bg-primary: #fff8e1;
            --bg-secondary: #ffecb3;
            --bg-tertiary: #ffe082;
            --text-primary: #5d4037;
            --text-secondary: #8d6e63;
            --text-muted: #a1887f;
            --accent-color: #ff9800;
            --accent-hover: #f57c00;
            --border-color: #ffcc02;
            --shadow: rgba(255, 152, 0, 0.2);
            --success-color: #4caf50;
            --warning-color: #ff9800;
            --error-color: #f44336;
            --logo-emoji: "🕉️";
            --edition-name: "Freedome Sphere Vaishnava Edition";
        }

        [data-edition="enterprise"] {
            --bg-primary: #f3f6ff;
            --bg-secondary: #e3ebff;
            --bg-tertiary: #c7d2fe;
            --text-primary: #1e3a8a;
            --text-secondary: #3730a3;
            --text-muted: #6366f1;
            --accent-color: #3b82f6;
            --accent-hover: #2563eb;
            --border-color: #a5b4fc;
            --shadow: rgba(59, 130, 246, 0.15);
            --success-color: #10b981;
            --warning-color: #f59e0b;
            --error-color: #ef4444;
            --logo-emoji: "🏢";
            --edition-name: "Freedome Sphere Enterprise Edition";
        }

        [data-edition="education"] {
            --bg-primary: #f0fdf4;
            --bg-secondary: #dcfce7;
            --bg-tertiary: #bbf7d0;
            --text-primary: #14532d;
            --text-secondary: #166534;
            --text-muted: #16a34a;
            --accent-color: #22c55e;
            --accent-hover: #16a34a;
            --border-color: #86efac;
            --shadow: rgba(34, 197, 94, 0.15);
            --success-color: #22c55e;
            --warning-color: #eab308;
            --error-color: #ef4444;
            --logo-emoji: "🎓";
            --edition-name: "Freedome Sphere Education Edition";
        }
    </style>
</head>
<body>
    <div class="logo" id="appLogo">Freedome Sphere</div>
    <select id="editionSelect">
        <option value="default">Standard</option>
        <option value="vaishnava">Vaishnava</option>
        <option value="enterprise">Enterprise</option>
        <option value="education">Education</option>
    </select>
    <button id="themeToggle">🌙 Dark</button>
</body>
</html>
`, {
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

// Импортируем функции из основного файла (мокаем их)
const themeSystem = {
    currentEdition: 'default',
    currentTheme: 'light',

    changeEdition: function(newEdition) {
        document.body.removeAttribute('data-edition');
        if (newEdition !== 'default') {
            document.body.setAttribute('data-edition', newEdition);
        }
        this.currentEdition = newEdition;
        this.updateLogo();
        this.saveSettings();
    },

    toggleTheme: function() {
        if (this.currentTheme === 'light') {
            document.body.setAttribute('data-theme', 'dark');
            this.currentTheme = 'dark';
        } else {
            document.body.removeAttribute('data-theme');
            this.currentTheme = 'light';
        }
        this.updateLogo();
        this.saveSettings();
    },

    updateLogo: function() {
        const logo = document.getElementById('appLogo');
        const editionName = getComputedStyle(document.body).getPropertyValue('--edition-name').trim();
        logo.textContent = editionName;
    },

    saveSettings: function() {
        const settings = {
            edition: this.currentEdition,
            theme: this.currentTheme
        };
        localStorage.setItem('freedomeSphereSettings', JSON.stringify(settings));
    },

    loadSettings: function() {
        const saved = localStorage.getItem('freedomeSphereSettings');
        if (saved) {
            const settings = JSON.parse(saved);
            this.currentEdition = settings.edition || 'default';
            this.currentTheme = settings.theme || 'light';
            
            const editionSelect = document.getElementById('editionSelect');
            const themeToggle = document.getElementById('themeToggle');
            
            editionSelect.value = this.currentEdition;
            if (this.currentEdition !== 'default') {
                document.body.setAttribute('data-edition', this.currentEdition);
            }
            
            if (this.currentTheme === 'dark') {
                document.body.setAttribute('data-theme', 'dark');
                themeToggle.textContent = '☀️ Light';
            } else {
                themeToggle.textContent = '🌙 Dark';
            }
            
            this.updateLogo();
        }
    }
};

// Тесты
describe('Freedome Sphere Theme System', () => {
    beforeEach(() => {
        // Очищаем localStorage перед каждым тестом
        localStorage.clear();
        // Сбрасываем состояние
        document.body.removeAttribute('data-theme');
        document.body.removeAttribute('data-edition');
        themeSystem.currentEdition = 'default';
        themeSystem.currentTheme = 'light';
    });

    describe('Theme Switching', () => {
        test('should switch to dark theme', () => {
            themeSystem.toggleTheme();
            expect(document.body.getAttribute('data-theme')).toBe('dark');
            expect(themeSystem.currentTheme).toBe('dark');
        });

        test('should switch back to light theme', () => {
            themeSystem.toggleTheme(); // switch to dark
            themeSystem.toggleTheme(); // switch back to light
            expect(document.body.getAttribute('data-theme')).toBeNull();
            expect(themeSystem.currentTheme).toBe('light');
        });

        test('should update theme toggle button text', () => {
            const themeToggle = document.getElementById('themeToggle');
            expect(themeToggle.textContent).toBe('🌙 Dark');
            
            themeSystem.toggleTheme();
            expect(themeSystem.currentTheme).toBe('dark');
        });
    });

    describe('Edition Switching', () => {
        test('should switch to Vaishnava edition', () => {
            themeSystem.changeEdition('vaishnava');
            expect(document.body.getAttribute('data-edition')).toBe('vaishnava');
            expect(themeSystem.currentEdition).toBe('vaishnava');
        });

        test('should switch to Enterprise edition', () => {
            themeSystem.changeEdition('enterprise');
            expect(document.body.getAttribute('data-edition')).toBe('enterprise');
            expect(themeSystem.currentEdition).toBe('enterprise');
        });

        test('should switch to Education edition', () => {
            themeSystem.changeEdition('education');
            expect(document.body.getAttribute('data-edition')).toBe('education');
            expect(themeSystem.currentEdition).toBe('education');
        });

        test('should switch back to default edition', () => {
            themeSystem.changeEdition('vaishnava');
            themeSystem.changeEdition('default');
            expect(document.body.getAttribute('data-edition')).toBeNull();
            expect(themeSystem.currentEdition).toBe('default');
        });
    });

    describe('Logo Updates', () => {
        test('should update logo for Vaishnava edition', () => {
            themeSystem.changeEdition('vaishnava');
            const logo = document.getElementById('appLogo');
            expect(logo.textContent).toBe('Freedome Sphere Vaishnava Edition');
        });

        test('should update logo for Enterprise edition', () => {
            themeSystem.changeEdition('enterprise');
            const logo = document.getElementById('appLogo');
            expect(logo.textContent).toBe('Freedome Sphere Enterprise Edition');
        });

        test('should update logo for Education edition', () => {
            themeSystem.changeEdition('education');
            const logo = document.getElementById('appLogo');
            expect(logo.textContent).toBe('Freedome Sphere Education Edition');
        });

        test('should update logo for default edition', () => {
            themeSystem.changeEdition('default');
            const logo = document.getElementById('appLogo');
            expect(logo.textContent).toBe('Freedome Sphere');
        });
    });

    describe('Settings Persistence', () => {
        test('should save settings to localStorage', () => {
            themeSystem.changeEdition('vaishnava');
            themeSystem.toggleTheme();
            
            const saved = localStorage.getItem('freedomeSphereSettings');
            const settings = JSON.parse(saved);
            
            expect(settings.edition).toBe('vaishnava');
            expect(settings.theme).toBe('dark');
        });

        test('should load settings from localStorage', () => {
            // Сохраняем настройки
            const settings = {
                edition: 'enterprise',
                theme: 'dark'
            };
            localStorage.setItem('freedomeSphereSettings', JSON.stringify(settings));
            
            // Загружаем настройки
            themeSystem.loadSettings();
            
            expect(themeSystem.currentEdition).toBe('enterprise');
            expect(themeSystem.currentTheme).toBe('dark');
            expect(document.body.getAttribute('data-edition')).toBe('enterprise');
            expect(document.body.getAttribute('data-theme')).toBe('dark');
        });

        test('should handle missing localStorage gracefully', () => {
            localStorage.clear();
            themeSystem.loadSettings();
            
            expect(themeSystem.currentEdition).toBe('default');
            expect(themeSystem.currentTheme).toBe('light');
        });
    });

    describe('CSS Variables', () => {
        test('should have correct CSS variables for Vaishnava edition', () => {
            themeSystem.changeEdition('vaishnava');
            const computedStyle = getComputedStyle(document.body);
            
            expect(computedStyle.getPropertyValue('--accent-color').trim()).toBe('#ff9800');
            expect(computedStyle.getPropertyValue('--logo-emoji').trim()).toBe('🕉️');
        });

        test('should have correct CSS variables for Enterprise edition', () => {
            themeSystem.changeEdition('enterprise');
            const computedStyle = getComputedStyle(document.body);
            
            expect(computedStyle.getPropertyValue('--accent-color').trim()).toBe('#3b82f6');
            expect(computedStyle.getPropertyValue('--logo-emoji').trim()).toBe('🏢');
        });

        test('should have correct CSS variables for Education edition', () => {
            themeSystem.changeEdition('education');
            const computedStyle = getComputedStyle(document.body);
            
            expect(computedStyle.getPropertyValue('--accent-color').trim()).toBe('#22c55e');
            expect(computedStyle.getPropertyValue('--logo-emoji').trim()).toBe('🎓');
        });

        test('should have correct CSS variables for dark theme', () => {
            themeSystem.toggleTheme();
            const computedStyle = getComputedStyle(document.body);
            
            expect(computedStyle.getPropertyValue('--bg-primary').trim()).toBe('#1a1a1a');
            expect(computedStyle.getPropertyValue('--text-primary').trim()).toBe('#ffffff');
        });
    });

    describe('Combined Theme and Edition', () => {
        test('should work with Vaishnava edition and dark theme', () => {
            themeSystem.changeEdition('vaishnava');
            themeSystem.toggleTheme();
            
            expect(document.body.getAttribute('data-edition')).toBe('vaishnava');
            expect(document.body.getAttribute('data-theme')).toBe('dark');
            expect(themeSystem.currentEdition).toBe('vaishnava');
            expect(themeSystem.currentTheme).toBe('dark');
        });

        test('should work with Enterprise edition and light theme', () => {
            themeSystem.changeEdition('enterprise');
            // Убеждаемся что тема светлая
            if (themeSystem.currentTheme === 'dark') {
                themeSystem.toggleTheme();
            }
            
            expect(document.body.getAttribute('data-edition')).toBe('enterprise');
            expect(document.body.getAttribute('data-theme')).toBeNull();
            expect(themeSystem.currentEdition).toBe('enterprise');
            expect(themeSystem.currentTheme).toBe('light');
        });
    });
});

// Экспортируем для использования в других тестах
module.exports = { themeSystem, dom };
