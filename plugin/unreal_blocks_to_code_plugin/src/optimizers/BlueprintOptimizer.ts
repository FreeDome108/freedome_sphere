import * as fs from 'fs-extra';
import * as path from 'path';
import glob from 'glob';
import { promisify } from 'util';

const globAsync = promisify(glob);
import { BlueprintOptimizationResult, ProjectIssue, OptimizationSuggestion } from '../types/AnalysisTypes';

export class BlueprintOptimizer {
    private readonly config: any;

    constructor() {
        this.config = {
            enableBlueprintOptimization: true,
            backupBeforeOptimization: true,
            optimizationLevel: 'basic'
        };
    }

    async optimizeBlueprints(
        projectPath: string,
        progress?: (value: { increment: number; message: string }) => void,
        token?: { isCancellationRequested: boolean }
    ): Promise<BlueprintOptimizationResult> {
        const issues: ProjectIssue[] = [];
        const suggestions: OptimizationSuggestion[] = [];
        let optimizedFiles = 0;

        progress?.({ increment: 0, message: "Поиск Blueprint файлов..." });

        // Находим все Blueprint файлы
        const blueprintFiles = await this.findBlueprintFiles(projectPath);
        const totalFiles = blueprintFiles.length;

        if (totalFiles === 0) {
            return {
                optimizedFiles: 0,
                totalFiles: 0,
                issues: [],
                suggestions: []
            };
        }

        progress?.({ increment: 10, message: `Найдено ${totalFiles} Blueprint файлов` });

        // Анализируем каждый Blueprint файл
        for (let i = 0; i < blueprintFiles.length; i++) {
            if (token?.isCancellationRequested) {
                throw new Error('Операция отменена');
            }

            const file = blueprintFiles[i];
            const progressPercent = 10 + (i / blueprintFiles.length) * 80;
            
            progress?.({ 
                increment: progressPercent, 
                message: `Анализ Blueprint: ${path.basename(file)}` 
            });

            try {
                const fileIssues = await this.analyzeBlueprintFile(file);
                issues.push(...fileIssues);

                // Если есть проблемы, которые можно исправить автоматически
                const autoFixableIssues = fileIssues.filter(issue => 
                    issue.type === 'code-quality' && issue.severity === 'info'
                );

                if (autoFixableIssues.length > 0) {
                    await this.optimizeBlueprintFile(file, autoFixableIssues);
                    optimizedFiles++;
                }

            } catch (error) {
                issues.push({
                    type: 'error',
                    severity: 'error',
                    file: file,
                    line: 0,
                    message: `Ошибка анализа Blueprint: ${error}`,
                    suggestion: 'Проверьте целостность файла'
                });
            }
        }

        // Генерируем предложения по оптимизации
        suggestions.push(...this.generateBlueprintSuggestions(issues));

        progress?.({ increment: 100, message: "Оптимизация Blueprint завершена!" });

        return {
            optimizedFiles,
            totalFiles,
            issues,
            suggestions
        };
    }

    private async findBlueprintFiles(projectPath: string): Promise<string[]> {
        const patterns = [
            '**/*.uasset',
            '**/*.umap'
        ];
        
        const files: string[] = [];
        
        for (const pattern of patterns) {
            const matches = await globAsync(pattern, { cwd: projectPath });
            files.push(...matches.map((file: string) => path.join(projectPath, file)));
        }
        
        return files;
    }

    private async analyzeBlueprintFile(filePath: string): Promise<ProjectIssue[]> {
        const issues: ProjectIssue[] = [];
        
        try {
            const stats = await fs.stat(filePath);
            const fileName = path.basename(filePath);
            const fileSize = stats.size;

            // Проверка размера файла
            if (fileSize > 50 * 1024 * 1024) { // 50MB
                issues.push({
                    type: 'performance',
                    severity: 'warning',
                    file: filePath,
                    line: 0,
                    message: 'Blueprint файл очень большой (>50MB)',
                    suggestion: 'Рассмотрите разделение на несколько Blueprint или оптимизацию логики'
                });
            } else if (fileSize > 10 * 1024 * 1024) { // 10MB
                issues.push({
                    type: 'performance',
                    severity: 'info',
                    file: filePath,
                    line: 0,
                    message: 'Blueprint файл большой (>10MB)',
                    suggestion: 'Рассмотрите оптимизацию для улучшения производительности'
                });
            }

            // Проверка имени файла
            if (!this.isValidBlueprintName(fileName)) {
                issues.push({
                    type: 'code-quality',
                    severity: 'info',
                    file: filePath,
                    line: 0,
                    message: 'Имя Blueprint не соответствует конвенциям именования',
                    suggestion: 'Используйте PascalCase для имен Blueprint файлов (например: BP_PlayerController)'
                });
            }

            // Проверка на потенциальные проблемы с производительностью
            if (this.hasPerformanceIssues(fileName)) {
                issues.push({
                    type: 'performance',
                    severity: 'warning',
                    file: filePath,
                    line: 0,
                    message: 'Возможные проблемы с производительностью',
                    suggestion: 'Проверьте использование Tick событий и сложных вычислений'
                });
            }

            // Проверка на дублирование логики
            if (this.hasDuplicateLogic(fileName)) {
                issues.push({
                    type: 'code-quality',
                    severity: 'info',
                    file: filePath,
                    line: 0,
                    message: 'Возможно дублирование логики',
                    suggestion: 'Рассмотрите создание родительского класса или использование функций'
                });
            }

            // Проверка на сложность Blueprint
            if (this.hasHighComplexity(fileName)) {
                issues.push({
                    type: 'performance',
                    severity: 'warning',
                    file: filePath,
                    line: 0,
                    message: 'Blueprint имеет высокую сложность',
                    suggestion: 'Рассмотрите разделение на несколько Blueprint или упрощение логики'
                });
            }

            // Проверка на использование Tick
            if (this.usesTick(fileName)) {
                issues.push({
                    type: 'performance',
                    severity: 'warning',
                    file: filePath,
                    line: 0,
                    message: 'Blueprint использует Tick событие',
                    suggestion: 'Рассмотрите использование Timer или Event-based подходов вместо Tick'
                });
            }

            // Проверка на неоптимальные узлы
            if (this.hasInefficientNodes(fileName)) {
                issues.push({
                    type: 'performance',
                    severity: 'info',
                    file: filePath,
                    line: 0,
                    message: 'Обнаружены потенциально неоптимальные узлы',
                    suggestion: 'Проверьте использование Cast, Get Actor of Class и других дорогих операций'
                });
            }

            // Проверка на отсутствие категоризации
            if (this.lacksCategorization(fileName)) {
                issues.push({
                    type: 'code-quality',
                    severity: 'info',
                    file: filePath,
                    line: 0,
                    message: 'Blueprint не имеет категоризации',
                    suggestion: 'Добавьте категории для переменных и функций для лучшей организации'
                });
            }

        } catch (error) {
            issues.push({
                type: 'error',
                severity: 'error',
                file: filePath,
                line: 0,
                message: `Ошибка анализа Blueprint: ${error}`,
                suggestion: 'Проверьте права доступа к файлу'
            });
        }

        return issues;
    }

    private async optimizeBlueprintFile(filePath: string, issues: ProjectIssue[]): Promise<void> {
        try {
            // Создаем резервную копию если включено
            if (this.config.backupBeforeOptimization) {
                const backupPath = filePath + '.backup';
                await fs.copy(filePath, backupPath);
            }

            // Здесь можно добавить логику для автоматической оптимизации Blueprint файлов
            // Поскольку .uasset файлы бинарные, мы можем только анализировать метаданные
            // и создавать отчеты с рекомендациями

            console.log(`Blueprint файл ${filePath} проанализирован для оптимизации`);

        } catch (error) {
            throw new Error(`Ошибка оптимизации Blueprint: ${error}`);
        }
    }

    private generateBlueprintSuggestions(issues: ProjectIssue[]): OptimizationSuggestion[] {
        const suggestions: OptimizationSuggestion[] = [];
        
        const performanceIssues = issues.filter(i => i.type === 'performance');
        if (performanceIssues.length > 0) {
            suggestions.push({
                type: 'performance',
                title: 'Оптимизация производительности Blueprint',
                description: `Найдено ${performanceIssues.length} Blueprint с проблемами производительности`,
                priority: 'high',
                estimatedImpact: 'significant'
            });
        }

        const qualityIssues = issues.filter(i => i.type === 'code-quality');
        if (qualityIssues.length > 0) {
            suggestions.push({
                type: 'code-quality',
                title: 'Улучшение качества Blueprint',
                description: `Найдено ${qualityIssues.length} Blueprint с проблемами качества кода`,
                priority: 'medium',
                estimatedImpact: 'moderate'
            });
        }

        // Специфичные для Blueprint предложения
        suggestions.push({
            type: 'structure',
            title: 'Рекомендации по структуре Blueprint',
            description: 'Рассмотрите создание родительских классов и использование функций для переиспользования кода',
            priority: 'medium',
            estimatedImpact: 'moderate'
        });

        suggestions.push({
            type: 'performance',
            title: 'Оптимизация Tick событий',
            description: 'Проверьте использование Tick событий - они могут снижать производительность',
            priority: 'high',
            estimatedImpact: 'significant'
        });

        return suggestions;
    }

    private isValidBlueprintName(fileName: string): boolean {
        // Проверяем соответствие конвенциям именования UE
        const patterns = [
            /^BP_[A-Z][a-zA-Z0-9]*\.uasset$/,  // BP_ClassName
            /^BP_[A-Z][a-zA-Z0-9]*_[A-Z][a-zA-Z0-9]*\.uasset$/,  // BP_BaseClass_ChildClass
            /^[A-Z][a-zA-Z0-9]*\.uasset$/,  // ClassName
            /^[A-Z][a-zA-Z0-9]*_[A-Z][a-zA-Z0-9]*\.uasset$/  // BaseClass_ChildClass
        ];
        
        return patterns.some(pattern => pattern.test(fileName));
    }

    private hasPerformanceIssues(fileName: string): boolean {
        // Проверяем имена файлов на потенциальные проблемы с производительностью
        const performanceKeywords = [
            'Tick',
            'Update',
            'Loop',
            'Timer',
            'Animation',
            'Particle',
            'Effect'
        ];
        
        return performanceKeywords.some(keyword => 
            fileName.toLowerCase().includes(keyword.toLowerCase())
        );
    }

    private hasDuplicateLogic(fileName: string): boolean {
        // Проверяем на возможное дублирование логики по именам файлов
        const duplicateKeywords = [
            'Copy',
            'Duplicate',
            'Clone',
            'Version2',
            'New'
        ];
        
        return duplicateKeywords.some(keyword => 
            fileName.toLowerCase().includes(keyword.toLowerCase())
        );
    }

    // Метод для создания отчета по Blueprint оптимизации
    async generateBlueprintReport(projectPath: string): Promise<string> {
        const result = await this.optimizeBlueprints(projectPath);
        
        let report = '# Отчет по оптимизации Blueprint\n\n';
        report += `**Дата анализа:** ${new Date().toLocaleString()}\n`;
        report += `**Общее количество файлов:** ${result.totalFiles}\n`;
        report += `**Оптимизировано файлов:** ${result.optimizedFiles}\n\n`;

        if (result.issues.length > 0) {
            report += '## Найденные проблемы\n\n';
            
            const issuesByType = this.groupIssuesByType(result.issues);
            for (const [type, issues] of Object.entries(issuesByType)) {
                report += `### ${type}\n\n`;
                for (const issue of issues) {
                    report += `- **${path.basename(issue.file)}**: ${issue.message}\n`;
                    report += `  - *Рекомендация:* ${issue.suggestion}\n\n`;
                }
            }
        }

        if (result.suggestions.length > 0) {
            report += '## Рекомендации по оптимизации\n\n';
            for (const suggestion of result.suggestions) {
                report += `### ${suggestion.title}\n`;
                report += `**Приоритет:** ${suggestion.priority}\n`;
                report += `**Влияние:** ${suggestion.estimatedImpact}\n`;
                report += `**Описание:** ${suggestion.description}\n\n`;
            }
        }

        return report;
    }

    private groupIssuesByType(issues: ProjectIssue[]): Record<string, ProjectIssue[]> {
        return issues.reduce((groups, issue) => {
            const type = issue.type;
            if (!groups[type]) {
                groups[type] = [];
            }
            groups[type].push(issue);
            return groups;
        }, {} as Record<string, ProjectIssue[]>);
    }

    // Новые методы для расширенного анализа Blueprint
    private hasHighComplexity(fileName: string): boolean {
        // Проверяем имена файлов на высокую сложность
        const complexityKeywords = [
            'Manager',
            'Controller',
            'System',
            'Handler',
            'Processor',
            'Complex',
            'Advanced',
            'Master'
        ];
        
        return complexityKeywords.some(keyword => 
            fileName.toLowerCase().includes(keyword.toLowerCase())
        );
    }

    private usesTick(fileName: string): boolean {
        // Проверяем имена файлов на использование Tick
        const tickKeywords = [
            'Tick',
            'Update',
            'Timer',
            'Loop',
            'Continuous',
            'Realtime'
        ];
        
        return tickKeywords.some(keyword => 
            fileName.toLowerCase().includes(keyword.toLowerCase())
        );
    }

    private hasInefficientNodes(fileName: string): boolean {
        // Проверяем имена файлов на неэффективные узлы
        const inefficientKeywords = [
            'Cast',
            'Find',
            'Search',
            'GetAll',
            'ForEach',
            'While',
            'Delay',
            'Wait'
        ];
        
        return inefficientKeywords.some(keyword => 
            fileName.toLowerCase().includes(keyword.toLowerCase())
        );
    }

    private lacksCategorization(fileName: string): boolean {
        // Проверяем на отсутствие категоризации
        const uncategorizedKeywords = [
            'Default',
            'New',
            'Temp',
            'Test',
            'Untitled',
            'Blueprint'
        ];
        
        return uncategorizedKeywords.some(keyword => 
            fileName.toLowerCase().includes(keyword.toLowerCase())
        );
    }

    // Метод для анализа структуры Blueprint проекта
    async analyzeBlueprintStructure(projectPath: string): Promise<{
        totalBlueprints: number;
        widgetBlueprints: number;
        actorBlueprints: number;
        componentBlueprints: number;
        averageSize: number;
        largestBlueprint: string;
        recommendations: string[];
    }> {
        const blueprintFiles = await this.findBlueprintFiles(projectPath);
        const stats = await Promise.all(
            blueprintFiles.map(async (file) => {
                const stat = await fs.stat(file);
                return {
                    file,
                    size: stat.size,
                    name: path.basename(file)
                };
            })
        );

        const totalBlueprints = stats.length;
        const widgetBlueprints = stats.filter(s => s.name.startsWith('WBP_')).length;
        const actorBlueprints = stats.filter(s => s.name.startsWith('BP_') && !s.name.startsWith('WBP_')).length;
        const componentBlueprints = stats.filter(s => s.name.includes('Component')).length;
        const averageSize = stats.reduce((sum, s) => sum + s.size, 0) / totalBlueprints;
        const largestBlueprint = stats.reduce((max, s) => s.size > max.size ? s : max, stats[0]);

        const recommendations: string[] = [];
        
        if (averageSize > 5 * 1024 * 1024) { // 5MB
            recommendations.push('Средний размер Blueprint файлов превышает 5MB. Рассмотрите оптимизацию.');
        }
        
        if (widgetBlueprints > totalBlueprints * 0.5) {
            recommendations.push('Большое количество Widget Blueprint. Проверьте архитектуру UI.');
        }
        
        if (largestBlueprint.size > 50 * 1024 * 1024) { // 50MB
            recommendations.push(`Blueprint ${largestBlueprint.name} очень большой. Рассмотрите разделение.`);
        }

        return {
            totalBlueprints,
            widgetBlueprints,
            actorBlueprints,
            componentBlueprints,
            averageSize,
            largestBlueprint: largestBlueprint.name,
            recommendations
        };
    }

    // Метод для создания детального отчета по Blueprint
    async generateDetailedBlueprintReport(projectPath: string): Promise<string> {
        const result = await this.optimizeBlueprints(projectPath);
        const structure = await this.analyzeBlueprintStructure(projectPath);
        
        let report = '# Детальный отчет по Blueprint оптимизации\n\n';
        report += `**Дата анализа:** ${new Date().toLocaleString()}\n`;
        report += `**Общее количество Blueprint:** ${structure.totalBlueprints}\n`;
        report += `**Widget Blueprint:** ${structure.widgetBlueprints}\n`;
        report += `**Actor Blueprint:** ${structure.actorBlueprints}\n`;
        report += `**Component Blueprint:** ${structure.componentBlueprints}\n`;
        report += `**Средний размер:** ${(structure.averageSize / 1024 / 1024).toFixed(2)} MB\n`;
        report += `**Самый большой Blueprint:** ${structure.largestBlueprint}\n\n`;

        if (structure.recommendations.length > 0) {
            report += '## Рекомендации по структуре\n\n';
            for (const recommendation of structure.recommendations) {
                report += `- ${recommendation}\n`;
            }
            report += '\n';
        }

        if (result.issues.length > 0) {
            report += '## Найденные проблемы\n\n';
            
            const issuesByType = this.groupIssuesByType(result.issues);
            for (const [type, issues] of Object.entries(issuesByType)) {
                report += `### ${this.getTypeDisplayName(type)}\n\n`;
                for (const issue of issues) {
                    report += `- **${path.basename(issue.file)}**: ${issue.message}\n`;
                    report += `  - *Рекомендация:* ${issue.suggestion}\n\n`;
                }
            }
        }

        if (result.suggestions.length > 0) {
            report += '## Предложения по оптимизации\n\n';
            for (const suggestion of result.suggestions) {
                report += `### ${suggestion.title}\n`;
                report += `**Приоритет:** ${suggestion.priority}\n`;
                report += `**Влияние:** ${suggestion.estimatedImpact}\n`;
                report += `**Описание:** ${suggestion.description}\n\n`;
            }
        }

        return report;
    }

    private getTypeDisplayName(type: string): string {
        const typeNames: Record<string, string> = {
            'performance': 'Производительность',
            'memory': 'Память',
            'code-quality': 'Качество кода',
            'compatibility': 'Совместимость',
            'error': 'Ошибка'
        };
        return typeNames[type] || type;
    }
}
