import * as vscode from 'vscode';

export interface ErrorInfo {
    code: string;
    message: string;
    severity: 'error' | 'warning' | 'info';
    source: string;
    timestamp: Date;
    details?: any;
}

export interface ValidationResult {
    isValid: boolean;
    errors: ErrorInfo[];
    warnings: ErrorInfo[];
    info: ErrorInfo[];
}

export class ErrorHandler {
    private static instance: ErrorHandler;
    private errorLog: ErrorInfo[] = [];
    private readonly maxLogSize = 1000;

    private constructor() {}

    public static getInstance(): ErrorHandler {
        if (!ErrorHandler.instance) {
            ErrorHandler.instance = new ErrorHandler();
        }
        return ErrorHandler.instance;
    }

    // Основной метод для обработки ошибок
    public handleError(error: Error, source: string, context?: any): void {
        const errorInfo: ErrorInfo = {
            code: this.generateErrorCode(error),
            message: error.message,
            severity: 'error',
            source: source,
            timestamp: new Date(),
            details: context
        };

        this.logError(errorInfo);
        this.showErrorToUser(errorInfo);
    }

    // Обработка предупреждений
    public handleWarning(message: string, source: string, context?: any): void {
        const warningInfo: ErrorInfo = {
            code: this.generateWarningCode(message),
            message: message,
            severity: 'warning',
            source: source,
            timestamp: new Date(),
            details: context
        };

        this.logError(warningInfo);
        this.showWarningToUser(warningInfo);
    }

    // Обработка информационных сообщений
    public handleInfo(message: string, source: string, context?: any): void {
        const infoInfo: ErrorInfo = {
            code: this.generateInfoCode(message),
            message: message,
            severity: 'info',
            source: source,
            timestamp: new Date(),
            details: context
        };

        this.logError(infoInfo);
        this.showInfoToUser(infoInfo);
    }

    // Валидация файла проекта
    public validateProjectFile(filePath: string): ValidationResult {
        const result: ValidationResult = {
            isValid: true,
            errors: [],
            warnings: [],
            info: []
        };

        try {
            // Проверка существования файла
            if (!filePath) {
                result.errors.push({
                    code: 'FILE_PATH_EMPTY',
                    message: 'Путь к файлу не указан',
                    severity: 'error',
                    source: 'FileValidator',
                    timestamp: new Date()
                });
                result.isValid = false;
                return result;
            }

            // Проверка расширения файла
            const validExtensions = ['.cpp', '.h', '.cpppp', '.uasset', '.umap', '.uproject', '.uplugin', '.ini'];
            const fileExtension = this.getFileExtension(filePath);
            
            if (!validExtensions.includes(fileExtension)) {
                result.warnings.push({
                    code: 'INVALID_FILE_EXTENSION',
                    message: `Неподдерживаемое расширение файла: ${fileExtension}`,
                    severity: 'warning',
                    source: 'FileValidator',
                    timestamp: new Date()
                });
            }

            // Проверка имени файла
            if (this.hasInvalidFileName(filePath)) {
                result.warnings.push({
                    code: 'INVALID_FILE_NAME',
                    message: 'Имя файла содержит недопустимые символы',
                    severity: 'warning',
                    source: 'FileValidator',
                    timestamp: new Date()
                });
            }

        } catch (error) {
            result.errors.push({
                code: 'VALIDATION_ERROR',
                message: `Ошибка валидации: ${error}`,
                severity: 'error',
                source: 'FileValidator',
                timestamp: new Date()
            });
            result.isValid = false;
        }

        return result;
    }

    // Валидация кода C++
    public validateCppCode(code: string, fileName: string): ValidationResult {
        const result: ValidationResult = {
            isValid: true,
            errors: [],
            warnings: [],
            info: []
        };

        try {
            const lines = code.split('\n');

            for (let i = 0; i < lines.length; i++) {
                const line = lines[i];
                const lineNumber = i + 1;

                // Проверка на синтаксические ошибки
                if (this.hasSyntaxError(line)) {
                    result.errors.push({
                        code: 'SYNTAX_ERROR',
                        message: `Синтаксическая ошибка в строке ${lineNumber}`,
                        severity: 'error',
                        source: 'CppValidator',
                        timestamp: new Date(),
                        details: { line: lineNumber, content: line }
                    });
                    result.isValid = false;
                }

                // Проверка на потенциальные проблемы
                if (this.hasPotentialIssue(line)) {
                    result.warnings.push({
                        code: 'POTENTIAL_ISSUE',
                        message: `Потенциальная проблема в строке ${lineNumber}`,
                        severity: 'warning',
                        source: 'CppValidator',
                        timestamp: new Date(),
                        details: { line: lineNumber, content: line }
                    });
                }

                // Проверка на рекомендации
                if (this.hasRecommendation(line)) {
                    result.info.push({
                        code: 'RECOMMENDATION',
                        message: `Рекомендация для строки ${lineNumber}`,
                        severity: 'info',
                        source: 'CppValidator',
                        timestamp: new Date(),
                        details: { line: lineNumber, content: line }
                    });
                }
            }

        } catch (error) {
            result.errors.push({
                code: 'VALIDATION_ERROR',
                message: `Ошибка валидации кода: ${error}`,
                severity: 'error',
                source: 'CppValidator',
                timestamp: new Date()
            });
            result.isValid = false;
        }

        return result;
    }

    // Валидация настроек плагина
    public validatePluginSettings(settings: any): ValidationResult {
        const result: ValidationResult = {
            isValid: true,
            errors: [],
            warnings: [],
            info: []
        };

        try {
            // Проверка обязательных настроек
            if (!settings.hasOwnProperty('enableAutoOptimization')) {
                result.warnings.push({
                    code: 'MISSING_SETTING',
                    message: 'Отсутствует настройка enableAutoOptimization',
                    severity: 'warning',
                    source: 'SettingsValidator',
                    timestamp: new Date()
                });
            }

            // Проверка корректности значений
            if (settings.optimizationLevel && !['basic', 'advanced', 'aggressive'].includes(settings.optimizationLevel)) {
                result.errors.push({
                    code: 'INVALID_OPTIMIZATION_LEVEL',
                    message: 'Некорректный уровень оптимизации',
                    severity: 'error',
                    source: 'SettingsValidator',
                    timestamp: new Date()
                });
                result.isValid = false;
            }

        } catch (error) {
            result.errors.push({
                code: 'VALIDATION_ERROR',
                message: `Ошибка валидации настроек: ${error}`,
                severity: 'error',
                source: 'SettingsValidator',
                timestamp: new Date()
            });
            result.isValid = false;
        }

        return result;
    }

    // Получение лога ошибок
    public getErrorLog(): ErrorInfo[] {
        return [...this.errorLog];
    }

    // Очистка лога ошибок
    public clearErrorLog(): void {
        this.errorLog = [];
    }

    // Экспорт лога ошибок
    public exportErrorLog(): string {
        return JSON.stringify(this.errorLog, null, 2);
    }

    // Приватные методы
    private logError(errorInfo: ErrorInfo): void {
        this.errorLog.push(errorInfo);
        
        // Ограничиваем размер лога
        if (this.errorLog.length > this.maxLogSize) {
            this.errorLog = this.errorLog.slice(-this.maxLogSize);
        }
    }

    private showErrorToUser(errorInfo: ErrorInfo): void {
        vscode.window.showErrorMessage(`[${errorInfo.source}] ${errorInfo.message}`);
    }

    private showWarningToUser(warningInfo: ErrorInfo): void {
        vscode.window.showWarningMessage(`[${warningInfo.source}] ${warningInfo.message}`);
    }

    private showInfoToUser(infoInfo: ErrorInfo): void {
        vscode.window.showInformationMessage(`[${infoInfo.source}] ${infoInfo.message}`);
    }

    private generateErrorCode(error: Error): string {
        return `ERR_${error.name.toUpperCase()}_${Date.now()}`;
    }

    private generateWarningCode(message: string): string {
        return `WARN_${message.substring(0, 10).toUpperCase().replace(/\s/g, '_')}_${Date.now()}`;
    }

    private generateInfoCode(message: string): string {
        return `INFO_${message.substring(0, 10).toUpperCase().replace(/\s/g, '_')}_${Date.now()}`;
    }

    private getFileExtension(filePath: string): string {
        const lastDotIndex = filePath.lastIndexOf('.');
        return lastDotIndex !== -1 ? filePath.substring(lastDotIndex) : '';
    }

    private hasInvalidFileName(filePath: string): boolean {
        const fileName = filePath.split('/').pop() || filePath.split('\\').pop() || '';
        const invalidChars = /[<>:"|?*\x00-\x1f]/;
        return invalidChars.test(fileName);
    }

    private hasSyntaxError(line: string): boolean {
        // Простые проверки на синтаксические ошибки
        const syntaxErrors = [
            /[{}]\s*[{}]/, // Двойные скобки
            /;\s*;/, // Двойные точки с запятой
            /\/\*.*\*\/.*\*\//, // Неправильные комментарии
            /#include\s*<[^>]*[^>]$/, // Незакрытые include
        ];
        
        return syntaxErrors.some(pattern => pattern.test(line));
    }

    private hasPotentialIssue(line: string): boolean {
        // Проверки на потенциальные проблемы
        const potentialIssues = [
            /delete\s+\w+;/, // Raw delete
            /malloc\s*\(/, // Malloc
            /free\s*\(/, // Free
            /goto\s+\w+/, // Goto
        ];
        
        return potentialIssues.some(pattern => pattern.test(line));
    }

    private hasRecommendation(line: string): boolean {
        // Проверки на рекомендации
        const recommendations = [
            /\/\/\s*TODO/, // TODO комментарии
            /\/\/\s*FIXME/, // FIXME комментарии
            /\/\/\s*HACK/, // HACK комментарии
            /\/\/\s*NOTE/, // NOTE комментарии
        ];
        
        return recommendations.some(pattern => pattern.test(line));
    }

    // Метод для создания отчета об ошибках
    public generateErrorReport(): string {
        let report = '# Отчет об ошибках и предупреждениях\n\n';
        report += `**Дата создания:** ${new Date().toLocaleString()}\n`;
        report += `**Всего записей:** ${this.errorLog.length}\n\n`;

        const errors = this.errorLog.filter(e => e.severity === 'error');
        const warnings = this.errorLog.filter(e => e.severity === 'warning');
        const info = this.errorLog.filter(e => e.severity === 'info');

        if (errors.length > 0) {
            report += '## Ошибки\n\n';
            for (const error of errors) {
                report += `### ${error.code}\n`;
                report += `**Сообщение:** ${error.message}\n`;
                report += `**Источник:** ${error.source}\n`;
                report += `**Время:** ${error.timestamp.toLocaleString()}\n\n`;
            }
        }

        if (warnings.length > 0) {
            report += '## Предупреждения\n\n';
            for (const warning of warnings) {
                report += `### ${warning.code}\n`;
                report += `**Сообщение:** ${warning.message}\n`;
                report += `**Источник:** ${warning.source}\n`;
                report += `**Время:** ${warning.timestamp.toLocaleString()}\n\n`;
            }
        }

        if (info.length > 0) {
            report += '## Информационные сообщения\n\n';
            for (const infoItem of info) {
                report += `### ${infoItem.code}\n`;
                report += `**Сообщение:** ${infoItem.message}\n`;
                report += `**Источник:** ${infoItem.source}\n`;
                report += `**Время:** ${infoItem.timestamp.toLocaleString()}\n\n`;
            }
        }

        return report;
    }
}


