import * as path from 'path';
import { AnalysisResult, ProjectIssue, OptimizationSuggestion } from '../types/AnalysisTypes';

export class ReportGenerator {
    
    async generateAnalysisReport(analysisResult: AnalysisResult): Promise<string> {
        let report = '# Отчет анализа проекта Unreal Engine\n\n';
        
        // Заголовок и общая информация
        report += this.generateHeader(analysisResult);
        
        // Сводка по проблемам
        report += this.generateIssuesSummary(analysisResult.issues);
        
        // Детальный анализ проблем
        report += this.generateDetailedIssues(analysisResult.issues);
        
        // Предложения по оптимизации
        report += this.generateOptimizationSuggestions(analysisResult.suggestions);
        
        // Рекомендации по улучшению
        report += this.generateRecommendations(analysisResult);
        
        // Заключение
        report += this.generateConclusion(analysisResult);
        
        return report;
    }

    async generateOptimizationReport(analysisResult: AnalysisResult): Promise<string> {
        let report = '# Отчет по оптимизации проекта Unreal Engine\n\n';
        
        // Заголовок
        report += this.generateHeader(analysisResult);
        
        // Оценка производительности
        report += this.generatePerformanceAssessment(analysisResult);
        
        // План оптимизации
        report += this.generateOptimizationPlan(analysisResult.suggestions);
        
        // Приоритетные задачи
        report += this.generatePriorityTasks(analysisResult.issues);
        
        // Ожидаемые улучшения
        report += this.generateExpectedImprovements(analysisResult);
        
        return report;
    }

    private generateHeader(analysisResult: AnalysisResult): string {
        let header = `**Проект:** ${path.basename(analysisResult.projectPath)}\n`;
        header += `**Путь:** ${analysisResult.projectPath}\n`;
        header += `**Дата анализа:** ${analysisResult.analysisDate.toLocaleString()}\n`;
        header += `**Всего файлов:** ${analysisResult.totalFiles}\n`;
        header += `**Оценка производительности:** ${analysisResult.performanceScore}/100\n\n`;
        
        // Индикатор качества
        const qualityLevel = this.getQualityLevel(analysisResult.performanceScore);
        header += `**Уровень качества:** ${qualityLevel}\n\n`;
        
        return header;
    }

    private generateIssuesSummary(issues: ProjectIssue[]): string {
        let summary = '## Сводка по проблемам\n\n';
        
        const issuesByType = this.groupIssuesByType(issues);
        const issuesBySeverity = this.groupIssuesBySeverity(issues);
        
        summary += '### По типам проблем:\n';
        for (const [type, typeIssues] of Object.entries(issuesByType)) {
            summary += `- **${this.getTypeDisplayName(type)}**: ${typeIssues.length} проблем\n`;
        }
        
        summary += '\n### По серьезности:\n';
        for (const [severity, severityIssues] of Object.entries(issuesBySeverity)) {
            summary += `- **${this.getSeverityDisplayName(severity)}**: ${severityIssues.length} проблем\n`;
        }
        
        summary += '\n';
        return summary;
    }

    private generateDetailedIssues(issues: ProjectIssue[]): string {
        if (issues.length === 0) {
            return '## Детальный анализ\n\n**Отлично!** Проблем не найдено.\n\n';
        }

        let detailed = '## Детальный анализ проблем\n\n';
        
        const issuesByType = this.groupIssuesByType(issues);
        
        for (const [type, typeIssues] of Object.entries(issuesByType)) {
            detailed += `### ${this.getTypeDisplayName(type)}\n\n`;
            
            for (const issue of typeIssues) {
                detailed += `#### ${path.basename(issue.file)}:${issue.line}\n`;
                detailed += `**Проблема:** ${issue.message}\n\n`;
                detailed += `**Рекомендация:** ${issue.suggestion}\n\n`;
                detailed += `**Серьезность:** ${this.getSeverityDisplayName(issue.severity)}\n\n`;
                detailed += '---\n\n';
            }
        }
        
        return detailed;
    }

    private generateOptimizationSuggestions(suggestions: OptimizationSuggestion[]): string {
        if (suggestions.length === 0) {
            return '## Предложения по оптимизации\n\n**Нет предложений по оптимизации.**\n\n';
        }

        let suggestionsText = '## Предложения по оптимизации\n\n';
        
        // Группируем по приоритету
        const suggestionsByPriority = this.groupSuggestionsByPriority(suggestions);
        
        for (const [priority, prioritySuggestions] of Object.entries(suggestionsByPriority)) {
            suggestionsText += `### ${this.getPriorityDisplayName(priority)}\n\n`;
            
            for (const suggestion of prioritySuggestions) {
                suggestionsText += `#### ${suggestion.title}\n`;
                suggestionsText += `**Описание:** ${suggestion.description}\n\n`;
                suggestionsText += `**Тип:** ${this.getTypeDisplayName(suggestion.type)}\n`;
                suggestionsText += `**Влияние:** ${this.getImpactDisplayName(suggestion.estimatedImpact)}\n\n`;
                suggestionsText += '---\n\n';
            }
        }
        
        return suggestionsText;
    }

    private generateRecommendations(analysisResult: AnalysisResult): string {
        let recommendations = '## Рекомендации по улучшению\n\n';
        
        // Общие рекомендации на основе анализа
        if (analysisResult.performanceScore < 70) {
            recommendations += '### Критические улучшения\n';
            recommendations += '- Рекомендуется немедленно устранить все ошибки и предупреждения\n';
            recommendations += '- Проведите рефакторинг кода для улучшения производительности\n';
            recommendations += '- Рассмотрите использование профилировщика Unreal Engine\n\n';
        } else if (analysisResult.performanceScore < 85) {
            recommendations += '### Рекомендуемые улучшения\n';
            recommendations += '- Устраните предупреждения для улучшения качества кода\n';
            recommendations += '- Проведите оптимизацию критических участков кода\n\n';
        } else {
            recommendations += '### Дополнительные улучшения\n';
            recommendations += '- Код находится в хорошем состоянии\n';
            recommendations += '- Рекомендуется периодический анализ для поддержания качества\n\n';
        }
        
        // Специфичные рекомендации
        const issuesByType = this.groupIssuesByType(analysisResult.issues);
        
        if (issuesByType.performance) {
            recommendations += '### Оптимизация производительности\n';
            recommendations += '- Используйте профилировщик для выявления узких мест\n';
            recommendations += '- Рассмотрите использование многопоточности для тяжелых вычислений\n';
            recommendations += '- Оптимизируйте работу с памятью и контейнерами\n\n';
        }
        
        if (issuesByType.memory) {
            recommendations += '### Управление памятью\n';
            recommendations += '- Используйте умные указатели вместо raw указателей\n';
            recommendations += '- Проверьте на утечки памяти с помощью инструментов UE\n';
            recommendations += '- Рассмотрите использование object pooling для часто создаваемых объектов\n\n';
        }
        
        if (issuesByType['code-quality']) {
            recommendations += '### Качество кода\n';
            recommendations += '- Следуйте конвенциям именования Unreal Engine\n';
            recommendations += '- Добавляйте комментарии к сложной логике\n';
            recommendations += '- Используйте const где это возможно\n\n';
        }
        
        return recommendations;
    }

    private generateConclusion(analysisResult: AnalysisResult): string {
        let conclusion = '## Заключение\n\n';
        
        const qualityLevel = this.getQualityLevel(analysisResult.performanceScore);
        const totalIssues = analysisResult.issues.length;
        
        if (totalIssues === 0) {
            conclusion += '**Отличная работа!** Ваш проект Unreal Engine находится в отличном состоянии.\n\n';
        } else if (totalIssues < 10) {
            conclusion += `**Хорошее состояние.** Найдено ${totalIssues} проблем, которые можно легко исправить.\n\n`;
        } else if (totalIssues < 50) {
            conclusion += `**Требует внимания.** Найдено ${totalIssues} проблем, рекомендуется их устранение.\n\n`;
        } else {
            conclusion += `**Критическое состояние.** Найдено ${totalIssues} проблем, требуется немедленное исправление.\n\n`;
        }
        
        conclusion += `**Общая оценка:** ${qualityLevel} (${analysisResult.performanceScore}/100)\n\n`;
        
        conclusion += '### Следующие шаги:\n';
        conclusion += '1. Устраните критические ошибки (если есть)\n';
        conclusion += '2. Исправьте предупреждения производительности\n';
        conclusion += '3. Улучшите качество кода\n';
        conclusion += '4. Повторите анализ после внесения изменений\n\n';
        
        return conclusion;
    }

    private generatePerformanceAssessment(analysisResult: AnalysisResult): string {
        let assessment = '## Оценка производительности\n\n';
        
        const score = analysisResult.performanceScore;
        const level = this.getQualityLevel(score);
        
        assessment += `**Текущая оценка:** ${score}/100 (${level})\n\n`;
        
        // Прогресс-бар
        const filledBars = Math.floor(score / 10);
        const emptyBars = 10 - filledBars;
        const progressBar = '█'.repeat(filledBars) + '░'.repeat(emptyBars);
        assessment += `**Визуальная оценка:** [${progressBar}] ${score}%\n\n`;
        
        // Анализ по категориям
        const issuesByType = this.groupIssuesByType(analysisResult.issues);
        
        assessment += '### Анализ по категориям:\n\n';
        assessment += `- **Производительность:** ${issuesByType.performance?.length || 0} проблем\n`;
        assessment += `- **Память:** ${issuesByType.memory?.length || 0} проблем\n`;
        assessment += `- **Качество кода:** ${issuesByType['code-quality']?.length || 0} проблем\n`;
        assessment += `- **Совместимость:** ${issuesByType.compatibility?.length || 0} проблем\n\n`;
        
        return assessment;
    }

    private generateOptimizationPlan(suggestions: OptimizationSuggestion[]): string {
        let plan = '## План оптимизации\n\n';
        
        if (suggestions.length === 0) {
            plan += '**План оптимизации не требуется.**\n\n';
            return plan;
        }
        
        const suggestionsByPriority = this.groupSuggestionsByPriority(suggestions);
        
        plan += '### Этап 1: Критические проблемы\n';
        const criticalSuggestions = suggestionsByPriority.critical || [];
        for (const suggestion of criticalSuggestions) {
            plan += `- [ ] ${suggestion.title}\n`;
        }
        
        plan += '\n### Этап 2: Высокий приоритет\n';
        const highSuggestions = suggestionsByPriority.high || [];
        for (const suggestion of highSuggestions) {
            plan += `- [ ] ${suggestion.title}\n`;
        }
        
        plan += '\n### Этап 3: Средний приоритет\n';
        const mediumSuggestions = suggestionsByPriority.medium || [];
        for (const suggestion of mediumSuggestions) {
            plan += `- [ ] ${suggestion.title}\n`;
        }
        
        plan += '\n### Этап 4: Низкий приоритет\n';
        const lowSuggestions = suggestionsByPriority.low || [];
        for (const suggestion of lowSuggestions) {
            plan += `- [ ] ${suggestion.title}\n`;
        }
        
        plan += '\n';
        return plan;
    }

    private generatePriorityTasks(issues: ProjectIssue[]): string {
        let tasks = '## Приоритетные задачи\n\n';
        
        const criticalIssues = issues.filter(i => i.severity === 'error');
        const warningIssues = issues.filter(i => i.severity === 'warning');
        
        if (criticalIssues.length > 0) {
            tasks += '### 🚨 Критические задачи (требуют немедленного внимания)\n';
            for (const issue of criticalIssues.slice(0, 5)) { // Показываем только первые 5
                tasks += `- [ ] **${path.basename(issue.file)}:${issue.line}** - ${issue.message}\n`;
            }
            tasks += '\n';
        }
        
        if (warningIssues.length > 0) {
            tasks += '### ⚠️ Важные задачи\n';
            for (const issue of warningIssues.slice(0, 5)) { // Показываем только первые 5
                tasks += `- [ ] **${path.basename(issue.file)}:${issue.line}** - ${issue.message}\n`;
            }
            tasks += '\n';
        }
        
        return tasks;
    }

    private generateExpectedImprovements(analysisResult: AnalysisResult): string {
        let improvements = '## Ожидаемые улучшения\n\n';
        
        const currentScore = analysisResult.performanceScore;
        const issuesBySeverity = this.groupIssuesBySeverity(analysisResult.issues);
        
        const errorCount = issuesBySeverity.error?.length || 0;
        const warningCount = issuesBySeverity.warning?.length || 0;
        const infoCount = issuesBySeverity.info?.length || 0;
        
        // Расчет потенциального улучшения
        const potentialImprovement = (errorCount * 10) + (warningCount * 5) + (infoCount * 1);
        const maxPossibleScore = Math.min(100, currentScore + potentialImprovement);
        
        improvements += `**Текущая оценка:** ${currentScore}/100\n`;
        improvements += `**Потенциальная оценка:** ${maxPossibleScore}/100\n`;
        improvements += `**Возможное улучшение:** +${maxPossibleScore - currentScore} баллов\n\n`;
        
        improvements += '### Ожидаемые результаты:\n';
        if (errorCount > 0) {
            improvements += `- Устранение ${errorCount} критических ошибок улучшит стабильность\n`;
        }
        if (warningCount > 0) {
            improvements += `- Исправление ${warningCount} предупреждений повысит производительность\n`;
        }
        if (infoCount > 0) {
            improvements += `- Улучшение ${infoCount} рекомендаций повысит качество кода\n`;
        }
        
        improvements += '\n';
        return improvements;
    }

    // Вспомогательные методы
    private getQualityLevel(score: number): string {
        if (score >= 90) return 'Отлично';
        if (score >= 80) return 'Хорошо';
        if (score >= 70) return 'Удовлетворительно';
        if (score >= 60) return 'Требует улучшения';
        return 'Критично';
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

    private getSeverityDisplayName(severity: string): string {
        const severityNames: Record<string, string> = {
            'error': 'Ошибка',
            'warning': 'Предупреждение',
            'info': 'Информация'
        };
        return severityNames[severity] || severity;
    }

    private getPriorityDisplayName(priority: string): string {
        const priorityNames: Record<string, string> = {
            'critical': 'Критический',
            'high': 'Высокий',
            'medium': 'Средний',
            'low': 'Низкий'
        };
        return priorityNames[priority] || priority;
    }

    private getImpactDisplayName(impact: string): string {
        const impactNames: Record<string, string> = {
            'critical': 'Критическое',
            'significant': 'Значительное',
            'moderate': 'Умеренное',
            'minor': 'Незначительное'
        };
        return impactNames[impact] || impact;
    }

    private groupIssuesByType(issues: ProjectIssue[]): Record<string, ProjectIssue[]> {
        return issues.reduce((groups, issue) => {
            if (!groups[issue.type]) {
                groups[issue.type] = [];
            }
            groups[issue.type].push(issue);
            return groups;
        }, {} as Record<string, ProjectIssue[]>);
    }

    private groupIssuesBySeverity(issues: ProjectIssue[]): Record<string, ProjectIssue[]> {
        return issues.reduce((groups, issue) => {
            if (!groups[issue.severity]) {
                groups[issue.severity] = [];
            }
            groups[issue.severity].push(issue);
            return groups;
        }, {} as Record<string, ProjectIssue[]>);
    }

    private groupSuggestionsByPriority(suggestions: OptimizationSuggestion[]): Record<string, OptimizationSuggestion[]> {
        return suggestions.reduce((groups, suggestion) => {
            if (!groups[suggestion.priority]) {
                groups[suggestion.priority] = [];
            }
            groups[suggestion.priority].push(suggestion);
            return groups;
        }, {} as Record<string, OptimizationSuggestion[]>);
    }
}
