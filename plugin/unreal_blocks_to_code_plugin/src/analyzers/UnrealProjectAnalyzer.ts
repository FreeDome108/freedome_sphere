import * as fs from 'fs-extra';
import * as path from 'path';
import glob from 'glob';
import { promisify } from 'util';

const globAsync = promisify(glob);
import { AnalysisResult, ProjectIssue, OptimizationSuggestion } from '../types/AnalysisTypes';
import { ConfigFileAnalyzer } from './ConfigFileAnalyzer';

export class UnrealProjectAnalyzer {
    private readonly cppExtensions = ['.cpp', '.h', '.cpppp'];
    private readonly blueprintExtensions = ['.uasset', '.umap'];
    private readonly configExtensions = ['.uproject', '.uplugin', '.ini'];
    private readonly configAnalyzer: ConfigFileAnalyzer;

    constructor() {
        this.configAnalyzer = new ConfigFileAnalyzer();
    }

    async analyzeProject(
        projectPath: string, 
        progress?: (value: { increment: number; message: string }) => void,
        token?: { isCancellationRequested: boolean }
    ): Promise<AnalysisResult> {
        const issues: ProjectIssue[] = [];
        const suggestions: OptimizationSuggestion[] = [];

        // Проверяем, является ли это проектом Unreal Engine
        if (!await this.isUnrealProject(projectPath)) {
            throw new Error('Это не проект Unreal Engine');
        }

        progress?.({ increment: 10, message: "Анализ структуры проекта..." });
        if (token?.isCancellationRequested) throw new Error('Операция отменена');

        // Анализируем C++ файлы
        const cppFiles = await this.findCppFiles(projectPath);
        progress?.({ increment: 20, message: `Анализ ${cppFiles.length} C++ файлов...` });
        
        for (const file of cppFiles) {
            if (token?.isCancellationRequested) throw new Error('Операция отменена');
            
            const fileIssues = await this.analyzeCppFile(file);
            issues.push(...fileIssues);
        }

        // Анализируем Blueprint файлы
        const blueprintFiles = await this.findBlueprintFiles(projectPath);
        progress?.({ increment: 30, message: `Анализ ${blueprintFiles.length} Blueprint файлов...` });
        
        for (const file of blueprintFiles) {
            if (token?.isCancellationRequested) throw new Error('Операция отменена');
            
            const fileIssues = await this.analyzeBlueprintFile(file);
            issues.push(...fileIssues);
        }

        // Анализируем конфигурационные файлы
        progress?.({ increment: 40, message: "Анализ конфигурационных файлов..." });
        const configIssues = await this.configAnalyzer.analyzeConfigFiles(projectPath);
        issues.push(...configIssues);

        // Генерируем предложения по оптимизации
        progress?.({ increment: 50, message: "Генерация предложений по оптимизации..." });
        suggestions.push(...this.generateOptimizationSuggestions(issues));

        return {
            projectPath,
            totalFiles: cppFiles.length + blueprintFiles.length,
            issues,
            suggestions,
            analysisDate: new Date(),
            performanceScore: this.calculatePerformanceScore(issues)
        };
    }

    private async isUnrealProject(projectPath: string): Promise<boolean> {
        const uprojectFiles = await globAsync('**/*.uproject', { cwd: projectPath });
        return uprojectFiles.length > 0;
    }

    private async findCppFiles(projectPath: string): Promise<string[]> {
        const patterns = this.cppExtensions.map(ext => `**/*${ext}`);
        const files: string[] = [];
        
        for (const pattern of patterns) {
            const matches = await globAsync(pattern, { cwd: projectPath });
            files.push(...matches.map((file: string) => path.join(projectPath, file)));
        }
        
        return files;
    }

    private async findBlueprintFiles(projectPath: string): Promise<string[]> {
        const patterns = this.blueprintExtensions.map(ext => `**/*${ext}`);
        const files: string[] = [];
        
        for (const pattern of patterns) {
            const matches = await globAsync(pattern, { cwd: projectPath });
            files.push(...matches.map((file: string) => path.join(projectPath, file)));
        }
        
        return files;
    }

    private async analyzeCppFile(filePath: string): Promise<ProjectIssue[]> {
        const issues: ProjectIssue[] = [];
        
        try {
            const content = await fs.readFile(filePath, 'utf-8');
            const lines = content.split('\n');

            // Проверяем на неоптимальные паттерны
            for (let i = 0; i < lines.length; i++) {
                const line = lines[i];
                const lineNumber = i + 1;

                // Проверка на неэффективные циклы
                if (this.hasInefficientLoop(line)) {
                    issues.push({
                        type: 'performance',
                        severity: 'warning',
                        file: filePath,
                        line: lineNumber,
                        message: 'Неэффективный цикл - рассмотрите использование итераторов или алгоритмов STL',
                        suggestion: 'Используйте std::for_each, std::transform или range-based for loops'
                    });
                }

                // Проверка на неоптимальные строковые операции
                if (this.hasInefficientStringOperation(line)) {
                    issues.push({
                        type: 'performance',
                        severity: 'warning',
                        file: filePath,
                        line: lineNumber,
                        message: 'Неэффективная работа со строками',
                        suggestion: 'Используйте FString::Append или FString::Format для конкатенации'
                    });
                }

                // Проверка на отсутствие const
                if (this.missingConst(line)) {
                    issues.push({
                        type: 'code-quality',
                        severity: 'info',
                        file: filePath,
                        line: lineNumber,
                        message: 'Отсутствует const для неизменяемых переменных',
                        suggestion: 'Добавьте const для переменных, которые не изменяются'
                    });
                }

                // Проверка на неоптимальные UE макросы
                if (this.hasInefficientUEMacro(line)) {
                    issues.push({
                        type: 'performance',
                        severity: 'warning',
                        file: filePath,
                        line: lineNumber,
                        message: 'Неоптимальное использование UE макроса',
                        suggestion: 'Рассмотрите альтернативные подходы для лучшей производительности'
                    });
                }

                // Проверка на потенциальные утечки памяти
                if (this.hasPotentialMemoryLeak(line)) {
                    issues.push({
                        type: 'memory',
                        severity: 'error',
                        file: filePath,
                        line: lineNumber,
                        message: 'Потенциальная утечка памяти',
                        suggestion: 'Используйте умные указатели или убедитесь в правильном освобождении памяти'
                    });
                }

                // Проверка на неэффективное использование контейнеров
                if (this.hasInefficientContainerUsage(line)) {
                    issues.push({
                        type: 'performance',
                        severity: 'warning',
                        file: filePath,
                        line: lineNumber,
                        message: 'Неэффективное использование контейнеров',
                        suggestion: 'Рассмотрите предварительное выделение памяти или использование более эффективных методов'
                    });
                }

                // Проверка на небезопасное приведение типов
                if (this.hasUnsafeTypeCasting(line)) {
                    issues.push({
                        type: 'code-quality',
                        severity: 'warning',
                        file: filePath,
                        line: lineNumber,
                        message: 'Небезопасное приведение типов',
                        suggestion: 'Используйте безопасные методы приведения типов или проверяйте результат'
                    });
                }

                // Проверка на неэффективное использование делегатов
                if (this.hasInefficientDelegateUsage(line)) {
                    issues.push({
                        type: 'performance',
                        severity: 'info',
                        file: filePath,
                        line: lineNumber,
                        message: 'Неэффективное использование делегатов',
                        suggestion: 'Рассмотрите оптимизацию привязки делегатов'
                    });
                }

                // Проверка на анти-паттерны производительности
                if (this.hasPerformanceAntiPatterns(line)) {
                    issues.push({
                        type: 'performance',
                        severity: 'warning',
                        file: filePath,
                        line: lineNumber,
                        message: 'Анти-паттерн производительности',
                        suggestion: 'Оптимизируйте вызовы или переместите в более подходящее место'
                    });
                }
            }

            // Проверка на отсутствие include guards
            if (!this.hasIncludeGuard(content)) {
                issues.push({
                    type: 'code-quality',
                    severity: 'info',
                    file: filePath,
                    line: 1,
                    message: 'Отсутствует include guard',
                    suggestion: 'Добавьте #pragma once или традиционные include guards'
                });
            }

        } catch (error) {
            issues.push({
                type: 'error',
                severity: 'error',
                file: filePath,
                line: 0,
                message: `Ошибка чтения файла: ${error}`,
                suggestion: 'Проверьте права доступа к файлу'
            });
        }

        return issues;
    }

    private async analyzeBlueprintFile(filePath: string): Promise<ProjectIssue[]> {
        const issues: ProjectIssue[] = [];
        
        try {
            // Blueprint файлы бинарные, поэтому анализируем только метаданные
            const stats = await fs.stat(filePath);
            
            // Проверяем размер файла
            if (stats.size > 10 * 1024 * 1024) { // 10MB
                issues.push({
                    type: 'performance',
                    severity: 'warning',
                    file: filePath,
                    line: 0,
                    message: 'Blueprint файл очень большой',
                    suggestion: 'Рассмотрите разделение на несколько Blueprint или оптимизацию логики'
                });
            }

            // Проверяем имя файла на соответствие конвенциям
            const fileName = path.basename(filePath);
            if (!this.isValidBlueprintName(fileName)) {
                issues.push({
                    type: 'code-quality',
                    severity: 'info',
                    file: filePath,
                    line: 0,
                    message: 'Имя Blueprint не соответствует конвенциям именования',
                    suggestion: 'Используйте PascalCase для имен Blueprint файлов'
                });
            }

        } catch (error) {
            issues.push({
                type: 'error',
                severity: 'error',
                file: filePath,
                line: 0,
                message: `Ошибка анализа Blueprint: ${error}`,
                suggestion: 'Проверьте целостность файла'
            });
        }

        return issues;
    }


    private generateOptimizationSuggestions(issues: ProjectIssue[]): OptimizationSuggestion[] {
        const suggestions: OptimizationSuggestion[] = [];
        
        const performanceIssues = issues.filter(i => i.type === 'performance');
        if (performanceIssues.length > 0) {
            suggestions.push({
                type: 'performance',
                title: 'Оптимизация производительности',
                description: `Найдено ${performanceIssues.length} проблем с производительностью`,
                priority: 'high',
                estimatedImpact: 'significant'
            });
        }

        const memoryIssues = issues.filter(i => i.type === 'memory');
        if (memoryIssues.length > 0) {
            suggestions.push({
                type: 'memory',
                title: 'Оптимизация памяти',
                description: `Найдено ${memoryIssues.length} потенциальных утечек памяти`,
                priority: 'critical',
                estimatedImpact: 'critical'
            });
        }

        return suggestions;
    }

    private calculatePerformanceScore(issues: ProjectIssue[]): number {
        let score = 100;
        
        for (const issue of issues) {
            switch (issue.severity) {
                case 'error':
                    score -= 10;
                    break;
                case 'warning':
                    score -= 5;
                    break;
                case 'info':
                    score -= 1;
                    break;
            }
        }
        
        return Math.max(0, score);
    }

    // Вспомогательные методы для анализа кода
    private hasInefficientLoop(line: string): boolean {
        const patterns = [
            /for\s*\(\s*int\s+\w+\s*=\s*0\s*;\s*\w+\s*<\s*\w+\.size\(\)\s*;\s*\w+\+\+\s*\)/, // Классический неэффективный цикл
            /for\s*\(\s*int\s+\w+\s*=\s*0\s*;\s*\w+\s*<\s*\w+\.Num\(\)\s*;\s*\w+\+\+\s*\)/, // UE цикл с Num()
            /while\s*\(\s*\w+\s*<\s*\w+\.size\(\)\s*\)/, // While с size()
            /for\s*\(\s*auto\s+it\s*=\s*\w+\.begin\(\)\s*;\s*it\s*!=\s*\w+\.end\(\)\s*;\s*\+\+it\s*\)/ // Устаревший итератор
        ];
        return patterns.some(pattern => pattern.test(line));
    }

    private hasInefficientStringOperation(line: string): boolean {
        const patterns = [
            /FString.*\+.*FString/, // Конкатенация FString
            /TEXT\([^)]*\)\s*\+\s*TEXT\([^)]*\)/, // Конкатенация TEXT
            /FString::Printf.*%s.*%s/, // Множественные %s в Printf
            /FString::Format.*\{0\}.*\{1\}.*\{2\}/ // Сложная Format строка
        ];
        return patterns.some(pattern => pattern.test(line)) && !line.includes('FString::Format');
    }

    private missingConst(line: string): boolean {
        const patterns = [
            /^\s*(int|float|bool|FString|FVector|FRotator|FTransform|FQuat)\s+\w+\s*=/, // Локальные переменные
            /^\s*(int|float|bool|FString|FVector|FRotator|FTransform|FQuat)\s+\w+\s*\)/, // Параметры функций
            /^\s*const\s+(int|float|bool|FString|FVector|FRotator|FTransform|FQuat)\s+\w+\s*&/, // Ссылки без const
        ];
        return patterns.some(pattern => pattern.test(line)) && !line.includes('const');
    }

    private hasInefficientUEMacro(line: string): boolean {
        const patterns = [
            /GENERATED_BODY\(\)/, // Старый GENERATED_BODY
            /UPROPERTY\(\)/, // Пустой UPROPERTY
            /UFUNCTION\(\)/, // Пустой UFUNCTION
            /UCLASS\(\)/, // Пустой UCLASS
            /GENERATED_UCLASS_BODY\(\)/ // Устаревший макрос
        ];
        return patterns.some(pattern => pattern.test(line));
    }

    private hasPotentialMemoryLeak(line: string): boolean {
        const patterns = [
            /new\s+\w+\(\)/, // Raw new
            /malloc\s*\(/, // Malloc
            /calloc\s*\(/, // Calloc
            /realloc\s*\(/, // Realloc
            /CreateObject\s*\(/, // CreateObject без правильного управления
        ];
        return patterns.some(pattern => pattern.test(line)) && 
               !line.includes('MakeShared') && 
               !line.includes('MakeUnique') &&
               !line.includes('NewObject') &&
               !line.includes('delete');
    }

    private hasIncludeGuard(content: string): boolean {
        return content.includes('#pragma once') || 
               /#ifndef.*#define.*#endif/s.test(content) ||
               /#if\s+!defined.*#define.*#endif/s.test(content);
    }

    private hasDeprecatedModules(content: string): boolean {
        const deprecatedModules = [
            'Legacy', 'OldModule', 'Deprecated', 'UE4', 'UE3',
            'UMG', 'Slate', 'SlateCore', 'EditorStyle', 'UnrealEd'
        ];
        return deprecatedModules.some(module => content.includes(module));
    }

    private isValidBlueprintName(fileName: string): boolean {
        const patterns = [
            /^BP_[A-Z][a-zA-Z0-9]*\.uasset$/,  // BP_ClassName
            /^BP_[A-Z][a-zA-Z0-9]*_[A-Z][a-zA-Z0-9]*\.uasset$/,  // BP_BaseClass_ChildClass
            /^[A-Z][a-zA-Z0-9]*\.uasset$/,  // ClassName
            /^[A-Z][a-zA-Z0-9]*_[A-Z][a-zA-Z0-9]*\.uasset$/,  // BaseClass_ChildClass
            /^WBP_[A-Z][a-zA-Z0-9]*\.uasset$/,  // Widget Blueprint
            /^UMG_[A-Z][a-zA-Z0-9]*\.uasset$/  // UMG Widget
        ];
        return patterns.some(pattern => pattern.test(fileName));
    }

    // Новые методы для расширенного анализа
    private hasInefficientContainerUsage(line: string): boolean {
        const patterns = [
            /TArray.*\.Add.*\.Add.*\.Add/, // Множественные Add
            /TMap.*\.Find.*\.Find/, // Множественные Find
            /TSet.*\.Contains.*\.Contains/, // Множественные Contains
            /\.Reserve\s*\(\s*0\s*\)/, // Reserve(0)
            /\.Empty\s*\(\s*\)\s*;\s*\.Add/, // Empty() + Add
        ];
        return patterns.some(pattern => pattern.test(line));
    }

    private hasUnsafeTypeCasting(line: string): boolean {
        const patterns = [
            /static_cast.*\*/, // Static cast к указателю
            /reinterpret_cast.*\*/, // Reinterpret cast
            /\(.*\*\)\s*\w+/, // C-style cast к указателю
            /Cast<.*>\(.*\)\s*==\s*nullptr/, // Cast с проверкой на nullptr
        ];
        return patterns.some(pattern => pattern.test(line));
    }

    private hasInefficientDelegateUsage(line: string): boolean {
        const patterns = [
            /DECLARE_DELEGATE.*DECLARE_DELEGATE/, // Множественные DECLARE_DELEGATE
            /BindUObject.*BindUObject/, // Множественные BindUObject
            /AddDynamic.*AddDynamic/, // Множественные AddDynamic
            /RemoveDynamic.*RemoveDynamic/, // Множественные RemoveDynamic
        ];
        return patterns.some(pattern => pattern.test(line));
    }

    private hasPerformanceAntiPatterns(line: string): boolean {
        const patterns = [
            /GetWorld\(\)->GetTimeSeconds\(\)/, // GetTimeSeconds в цикле
            /GEngine->AddOnScreenDebugMessage/, // Debug сообщения в релизе
            /UE_LOG.*LogTemp.*Warning/, // Частые логи
            /IsValid.*IsValid/, // Множественные IsValid
            /GetActorLocation\(\)\.Distance/, // Distance вычисления
        ];
        return patterns.some(pattern => pattern.test(line));
    }
}
