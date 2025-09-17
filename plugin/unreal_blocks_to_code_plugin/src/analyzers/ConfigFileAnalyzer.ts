import * as fs from 'fs-extra';
import * as path from 'path';
import { ProjectIssue, OptimizationSuggestion } from '../types/AnalysisTypes';

export class ConfigFileAnalyzer {
    private readonly configExtensions = ['.ini', '.uplugin', '.uproject'];

    async analyzeConfigFiles(projectPath: string): Promise<ProjectIssue[]> {
        const issues: ProjectIssue[] = [];
        
        try {
            // Анализируем .uproject файлы
            const uprojectIssues = await this.analyzeUProjectFiles(projectPath);
            issues.push(...uprojectIssues);

            // Анализируем .uplugin файлы
            const upluginIssues = await this.analyzeUPluginFiles(projectPath);
            issues.push(...upluginIssues);

            // Анализируем .ini файлы
            const iniIssues = await this.analyzeIniFiles(projectPath);
            issues.push(...iniIssues);

        } catch (error) {
            issues.push({
                type: 'error',
                severity: 'error',
                file: projectPath,
                line: 0,
                message: `Ошибка анализа конфигурационных файлов: ${error}`,
                suggestion: 'Проверьте структуру проекта и права доступа к файлам'
            });
        }

        return issues;
    }

    private async analyzeUProjectFiles(projectPath: string): Promise<ProjectIssue[]> {
        const issues: ProjectIssue[] = [];
        
        try {
            const uprojectFiles = await this.findFilesByExtension(projectPath, '.uproject');
            
            for (const file of uprojectFiles) {
                const content = await fs.readFile(file, 'utf-8');
                const fileIssues = this.analyzeUProjectContent(content, file);
                issues.push(...fileIssues);
            }
        } catch (error) {
            issues.push({
                type: 'error',
                severity: 'error',
                file: projectPath,
                line: 0,
                message: `Ошибка анализа .uproject файлов: ${error}`,
                suggestion: 'Проверьте корректность .uproject файлов'
            });
        }

        return issues;
    }

    private async analyzeUPluginFiles(projectPath: string): Promise<ProjectIssue[]> {
        const issues: ProjectIssue[] = [];
        
        try {
            const upluginFiles = await this.findFilesByExtension(projectPath, '.uplugin');
            
            for (const file of upluginFiles) {
                const content = await fs.readFile(file, 'utf-8');
                const fileIssues = this.analyzeUPluginContent(content, file);
                issues.push(...fileIssues);
            }
        } catch (error) {
            issues.push({
                type: 'error',
                severity: 'error',
                file: projectPath,
                line: 0,
                message: `Ошибка анализа .uplugin файлов: ${error}`,
                suggestion: 'Проверьте корректность .uplugin файлов'
            });
        }

        return issues;
    }

    private async analyzeIniFiles(projectPath: string): Promise<ProjectIssue[]> {
        const issues: ProjectIssue[] = [];
        
        try {
            const iniFiles = await this.findFilesByExtension(projectPath, '.ini');
            
            for (const file of iniFiles) {
                const content = await fs.readFile(file, 'utf-8');
                const fileIssues = this.analyzeIniContent(content, file);
                issues.push(...fileIssues);
            }
        } catch (error) {
            issues.push({
                type: 'error',
                severity: 'error',
                file: projectPath,
                line: 0,
                message: `Ошибка анализа .ini файлов: ${error}`,
                suggestion: 'Проверьте корректность .ini файлов'
            });
        }

        return issues;
    }

    private analyzeUProjectContent(content: string, filePath: string): ProjectIssue[] {
        const issues: ProjectIssue[] = [];
        const lines = content.split('\n');

        for (let i = 0; i < lines.length; i++) {
            const line = lines[i];
            const lineNumber = i + 1;

            // Проверка на устаревшие модули
            if (this.hasDeprecatedModules(line)) {
                issues.push({
                    type: 'compatibility',
                    severity: 'warning',
                    file: filePath,
                    line: lineNumber,
                    message: 'Обнаружен устаревший модуль',
                    suggestion: 'Обновите модуль до актуальной версии или замените на современный аналог'
                });
            }

            // Проверка на устаревшую версию движка
            if (this.hasDeprecatedEngineVersion(line)) {
                issues.push({
                    type: 'compatibility',
                    severity: 'warning',
                    file: filePath,
                    line: lineNumber,
                    message: 'Используется устаревшая версия движка',
                    suggestion: 'Обновите EngineAssociation до актуальной версии'
                });
            }

            // Проверка на отсутствие необходимых модулей
            if (this.missingEssentialModules(line)) {
                issues.push({
                    type: 'code-quality',
                    severity: 'info',
                    file: filePath,
                    line: lineNumber,
                    message: 'Отсутствует рекомендуемый модуль',
                    suggestion: 'Добавьте модуль для улучшения функциональности'
                });
            }
        }

        return issues;
    }

    private analyzeUPluginContent(content: string, filePath: string): ProjectIssue[] {
        const issues: ProjectIssue[] = [];
        const lines = content.split('\n');

        for (let i = 0; i < lines.length; i++) {
            const line = lines[i];
            const lineNumber = i + 1;

            // Проверка на устаревшие плагины
            if (this.hasDeprecatedPlugins(line)) {
                issues.push({
                    type: 'compatibility',
                    severity: 'warning',
                    file: filePath,
                    line: lineNumber,
                    message: 'Обнаружен устаревший плагин',
                    suggestion: 'Обновите плагин или найдите альтернативу'
                });
            }

            // Проверка на отсутствие версии плагина
            if (this.missingPluginVersion(line)) {
                issues.push({
                    type: 'code-quality',
                    severity: 'info',
                    file: filePath,
                    line: lineNumber,
                    message: 'Отсутствует версия плагина',
                    suggestion: 'Добавьте поле Version для лучшего управления зависимостями'
                });
            }

            // Проверка на отсутствие описания плагина
            if (this.missingPluginDescription(line)) {
                issues.push({
                    type: 'code-quality',
                    severity: 'info',
                    file: filePath,
                    line: lineNumber,
                    message: 'Отсутствует описание плагина',
                    suggestion: 'Добавьте поле Description для документации'
                });
            }
        }

        return issues;
    }

    private analyzeIniContent(content: string, filePath: string): ProjectIssue[] {
        const issues: ProjectIssue[] = [];
        const lines = content.split('\n');

        for (let i = 0; i < lines.length; i++) {
            const line = lines[i];
            const lineNumber = i + 1;

            // Проверка на устаревшие настройки
            if (this.hasDeprecatedSettings(line)) {
                issues.push({
                    type: 'compatibility',
                    severity: 'warning',
                    file: filePath,
                    line: lineNumber,
                    message: 'Обнаружена устаревшая настройка',
                    suggestion: 'Обновите настройку до актуальной версии'
                });
            }

            // Проверка на неоптимальные настройки производительности
            if (this.hasPerformanceIssues(line)) {
                issues.push({
                    type: 'performance',
                    severity: 'warning',
                    file: filePath,
                    line: lineNumber,
                    message: 'Неоптимальная настройка производительности',
                    suggestion: 'Оптимизируйте настройку для лучшей производительности'
                });
            }

            // Проверка на отсутствие комментариев
            if (this.missingComments(line)) {
                issues.push({
                    type: 'code-quality',
                    severity: 'info',
                    file: filePath,
                    line: lineNumber,
                    message: 'Отсутствует комментарий к настройке',
                    suggestion: 'Добавьте комментарий для лучшего понимания настройки'
                });
            }
        }

        return issues;
    }

    private async findFilesByExtension(projectPath: string, extension: string): Promise<string[]> {
        const files: string[] = [];
        
        try {
            const entries = await fs.readdir(projectPath, { withFileTypes: true });
            
            for (const entry of entries) {
                const fullPath = path.join(projectPath, entry.name);
                
                if (entry.isDirectory()) {
                    // Рекурсивно ищем в подпапках
                    const subFiles = await this.findFilesByExtension(fullPath, extension);
                    files.push(...subFiles);
                } else if (entry.isFile() && entry.name.endsWith(extension)) {
                    files.push(fullPath);
                }
            }
        } catch (error) {
            // Игнорируем ошибки доступа к папкам
        }

        return files;
    }

    // Вспомогательные методы для анализа
    private hasDeprecatedModules(line: string): boolean {
        const deprecatedModules = [
            'Legacy',
            'OldModule',
            'Deprecated',
            'UE4',
            'UE3',
            'UMG',
            'Slate',
            'SlateCore',
            'EditorStyle',
            'UnrealEd'
        ];
        return deprecatedModules.some(module => line.includes(module));
    }

    private hasDeprecatedEngineVersion(line: string): boolean {
        const deprecatedVersions = ['4.', '3.', '2.', '1.'];
        return line.includes('EngineAssociation') && 
               deprecatedVersions.some(version => line.includes(version));
    }

    private missingEssentialModules(line: string): boolean {
        const essentialModules = ['Core', 'CoreUObject', 'Engine'];
        return line.includes('"Name"') && 
               !essentialModules.some(module => line.includes(module));
    }

    private hasDeprecatedPlugins(line: string): boolean {
        const deprecatedPlugins = [
            'Legacy',
            'OldPlugin',
            'Deprecated',
            'UE4',
            'UE3'
        ];
        return deprecatedPlugins.some(plugin => line.includes(plugin));
    }

    private missingPluginVersion(line: string): boolean {
        return line.includes('"Name"') && !line.includes('"Version"');
    }

    private missingPluginDescription(line: string): boolean {
        return line.includes('"Name"') && !line.includes('"Description"');
    }

    private hasDeprecatedSettings(line: string): boolean {
        const deprecatedSettings = [
            'bUseLegacy',
            'bOldStyle',
            'bDeprecated',
            'LegacyMode',
            'OldFormat'
        ];
        return deprecatedSettings.some(setting => line.includes(setting));
    }

    private hasPerformanceIssues(line: string): boolean {
        const performanceIssues = [
            'bUseHighQuality',
            'bEnableDebug',
            'bVerboseLogging',
            'MaxQuality',
            'UltraSettings'
        ];
        return performanceIssues.some(issue => line.includes(issue));
    }

    private missingComments(line: string): boolean {
        return line.includes('=') && !line.includes(';') && !line.includes('//');
    }

    // Метод для генерации предложений по оптимизации конфигурации
    generateConfigOptimizationSuggestions(issues: ProjectIssue[]): OptimizationSuggestion[] {
        const suggestions: OptimizationSuggestion[] = [];
        
        const compatibilityIssues = issues.filter(i => i.type === 'compatibility');
        if (compatibilityIssues.length > 0) {
            suggestions.push({
                type: 'compatibility',
                title: 'Обновление конфигурации',
                description: `Найдено ${compatibilityIssues.length} проблем совместимости в конфигурационных файлах`,
                priority: 'high',
                estimatedImpact: 'significant'
            });
        }

        const performanceIssues = issues.filter(i => i.type === 'performance');
        if (performanceIssues.length > 0) {
            suggestions.push({
                type: 'performance',
                title: 'Оптимизация настроек производительности',
                description: `Найдено ${performanceIssues.length} неоптимальных настроек производительности`,
                priority: 'medium',
                estimatedImpact: 'moderate'
            });
        }

        return suggestions;
    }
}


